# Phalanx Engine Performance Analysis

## Executive Summary

The current Phalanx engine is well-suited for its design parameters (10x10 grid, ~20 units). The `Diplomacy` engine has O(n) complexity per iteration with worst-case O(n) iterations for cascading conflicts. Real-world performance concerns are minimal at current scale; bottlenecks would emerge at 100+ units or 50+ concurrent games per node.

---

## 1. Order Resolution Complexity

### Current Engine: `Phalanx.Engine.Diplomacy`

The engine executes in recursive passes until no conflicts remain:

```elixir
execute_orders(state, orders)
  -> populate_hold_orders     # O(u) where u = unit count
  -> get_unit_movements       # O(u)
  -> detect_conflicts         # O(u)
  -> if conflicts:
       convert_conflicts_to_holds  # O(u)
       execute_orders(state, valid_orders)  # recurse
     else:
       apply_orders_to_state  # O(u)
```

#### Complexity Analysis

| Operation | Time Complexity | Space Complexity |
|-----------|-----------------|------------------|
| `populate_hold_orders` | O(u) | O(u) - creates new map |
| `get_unit_movements` | O(u) | O(u) - list of tuples |
| `detect_conflicts` | O(u) | O(u) - MapSet |
| `convert_conflicts_to_holds` | O(u) | O(u) - new map |
| `apply_orders_to_state` | O(u) | O(u) - new units map |

**Per-iteration**: O(u)

**Worst-case iterations**: O(u) - theoretical cascade where each pass resolves one conflict

**Total worst-case**: O(u²)

**Practical case**: 1-3 iterations. Simultaneous conflicts are rare; most turns resolve in 1 pass.

#### Current Scale (u=20)

- Worst case: 400 operations per turn
- Typical case: 60 operations per turn (3 passes)
- **Verdict**: Negligible. Sub-millisecond execution.

### Missing Phases (Per MECHANICS.md Reference)

The current engine implements simplified conflict detection. Full 13-phase resolution with:
- Group detection (flood fill)
- Strength calculation (neighbor counting)
- Combat resolution

Would add:

| Phase | Complexity |
|-------|------------|
| Group detection (flood fill) | O(u) per group, O(u²) worst case for many small groups |
| Strength calculation | O(u × 6) = O(u) - check 6 neighbors per unit |
| Combat/damage resolution | O(conflicts) typically O(u) |

**Full engine estimate**: O(u²) worst case, O(u) typical

---

## 2. State Size Analysis

### Game State Struct

```elixir
%Phalanx.Game{
  id: "ABCD1234",           # ~8 bytes (binary)
  status: :playing,         # 8 bytes (atom)
  turn: 0,                  # 8 bytes (integer)
  players: [...],           # ~200 bytes/player
  units: %{...},            # ~100 bytes/unit
  map_dimensions: {10, 10}, # 24 bytes
}
```

#### Memory Estimates

| Component | Size | Notes |
|-----------|------|-------|
| Base struct | ~100 bytes | Headers, atom keys |
| Per unit | ~100 bytes | Map entry + unit map |
| Per player | ~200 bytes | Name string, token |
| Map dimensions | 24 bytes | Tuple of 2 integers |

**Total per game (2 players, 20 units)**: ~2.5 KB

**GenServer overhead**: ~300 bytes (process heap minimum)

**Total per game process**: ~3 KB

#### Concurrent Games Capacity

| Concurrent Games | Memory |
|------------------|--------|
| 100 | 300 KB |
| 1,000 | 3 MB |
| 10,000 | 30 MB |
| 100,000 | 300 MB |

**Verdict**: Memory is not a bottleneck. A single node with 1GB RAM allocated to game processes could run 300K+ concurrent games.

---

## 3. PubSub Load

### Current Implementation

```elixir
# Single broadcast per turn
Phoenix.PubSub.broadcast(Phalanx.PubSub, "game-state:#{id}", {:state, state})
```

#### Message Characteristics

| Metric | Value |
|--------|-------|
| Messages per turn | 1 broadcast |
| Payload size | ~2.5 KB (full state) |
| Subscribers per game | 2 players (typical) |
| Fan-out | O(subscribers) |

#### Spectator Scaling

| Spectators | Bandwidth/Turn | Notes |
|------------|---------------|-------|
| 2 | 5 KB | Baseline (2 players) |
| 10 | 25 KB | Small audience |
| 100 | 250 KB | Moderate streaming |
| 1,000 | 2.5 MB | Large audience |
| 10,000 | 25 MB | Esports scale - problematic |

**Bottleneck point**: ~1,000 spectators per game. Phoenix PubSub will serialize broadcasts, and network egress becomes limiting.

#### Optimization Opportunities

1. **Differential state updates**: Send only changed units
   - Typical turn changes ~2-4 units
   - Payload reduction: 90%+

2. **Binary serialization**: Replace Elixir term format with compact binary
   - ~50% size reduction

3. **Spectator tiers**: High-latency viewers receive batched updates

---

## 4. LiveView Rendering

### Current Implementation

```elixir
# Hex grid: nested loops
<%= for y <- 0..(@y_ct-1) do %>
  <%= for x <- 0..(@x_ct-1) do %>
    <.hex_tile ... />
  <% end %>
<% end %>
```

#### DOM Characteristics

| Element Type | Count (10x10 grid) |
|--------------|-------------------|
| Hex tile divs | 100 |
| Unit SVGs | 20 |
| SVG paths per unit | 3-4 (health bars) |
| Total DOM nodes | ~350-400 |

#### Rendering Performance

**Initial render**: 350 DOM nodes is trivial for modern browsers. Sub-10ms.

**LiveView diff**: Phoenix LiveView diffs at the template level. Each `hex_tile` component re-renders independently.

**Per-turn updates**:
- Changed tiles: typically 2-8 (moving units + vacated positions)
- DOM operations: ~20-50 nodes updated
- Time: sub-5ms

#### SVG Animation

Current rotation uses CSS classes:
```elixir
defp rotation_class(rotation) do
  case rotation do
    0 -> "rotate-0"
    60 -> "rotate-60"
    ...
  end
end
```

**CSS transforms**: GPU-accelerated, essentially free.

**Potential issue**: CSS transitions between rotation states may not interpolate correctly (e.g., 300° to 60° goes the long way).

---

## 5. Potential Bottlenecks

### Near-Term (Current Architecture)

| Concern | Likelihood | Impact | Mitigation |
|---------|------------|--------|------------|
| Cascading conflicts | Low | Med | Cap iterations; detect cycles |
| State broadcast size | Low | Low | Already small enough |
| GenServer message queue | Low | High | Add timeout handling |

### Future Scale (100+ units, 50+ games)

| Concern | Likelihood | Impact | Mitigation |
|---------|------------|--------|------------|
| Group detection | High | Med | Pre-compute adjacency graph |
| Strength calculation | Med | Low | Cache formation bonuses |
| Spectator broadcasts | High | High | Differential updates |
| CPU contention | Med | Med | Distribute games across nodes |

### Group Detection (Flood Fill)

When implemented, flood fill for formation detection will be:

```elixir
# Pseudocode
def find_group(unit_position, units, visited) do
  if visited?(unit_position), do: []

  neighbors = get_adjacent_same_team(unit_position, units)
  [unit_position | Enum.flat_map(neighbors, &find_group(&1, units, visited))]
end
```

**Complexity**: O(u) per group, but called for each unit. Naive implementation: O(u²).

**Optimization**: Single pass with union-find structure: O(u × α(u)) ≈ O(u).

---

## 6. Optimization Recommendations

### Priority 1: Pre-compute Neighbor Relationships

```elixir
# At game start or map change
def build_adjacency_map(map_dimensions) do
  for x <- 0..(elem(map_dimensions, 0) - 1),
      y <- 0..(elem(map_dimensions, 1) - 1),
      into: %{} do
    {{x, y}, compute_neighbors({x, y}, map_dimensions)}
  end
end
```

**Benefit**: O(1) neighbor lookup vs O(1) with computation. Marginal gain, but cleaner code.

### Priority 2: Differential State Updates

```elixir
def broadcast_diff(old_state, new_state) do
  changed_units =
    Map.merge(old_state.units, new_state.units, fn _k, v1, v2 ->
      if v1 == v2, do: :unchanged, else: {:changed, v2}
    end)
    |> Enum.reject(fn {_, v} -> v == :unchanged end)
    |> Map.new(fn {k, {:changed, v}} -> {k, v} end)

  Phoenix.PubSub.broadcast(topic, {:diff, changed_units, new_state.turn})
end
```

**Benefit**: 90% reduction in broadcast size for typical turns.

### Priority 3: Conflict Resolution Cycle Detection

```elixir
def execute_orders(state, orders, iteration \\ 0) do
  if iteration > length(Map.keys(state.units)) do
    Logger.error("Conflict resolution cycle detected")
    apply_orders_to_state(state, convert_all_to_holds(orders))
  else
    # ... normal logic with iteration + 1
  end
end
```

**Benefit**: Prevents infinite loops from implementation bugs.

### Priority 4: Formation Caching (Future)

Cache group membership and strength values per turn:
- Invalidate on unit movement/damage
- Recompute only affected groups

---

## 7. Scaling Considerations

### Single Node Capacity

| Resource | Estimate |
|----------|----------|
| Concurrent games | 10,000+ |
| Concurrent WebSocket connections | 50,000 (Phoenix default) |
| CPU usage per turn | ~0.1ms |
| Memory per game | ~3 KB |

**Single beefy node (8 cores, 32GB RAM)**: Could handle 10K concurrent games with 100K connected clients.

### Distributed Architecture (When Needed)

1. **Consistent hashing**: Route game IDs to nodes
2. **Horde/libcluster**: Distributed Registry for game lookup
3. **PubSub adapter**: Redis or Phoenix.PubSub.PG2 for cross-node broadcasts

**When to distribute**:
- >50K concurrent games
- Geographic latency requirements
- High availability needs

---

## 8. Benchmarking Approach

### Micro-benchmarks (Engine)

```elixir
# In test file or iex
{time, _} = :timer.tc(fn ->
  Enum.each(1..1000, fn _ ->
    Phalanx.Engine.Diplomacy.execute_orders(state, random_orders())
  end)
end)
IO.puts("Avg: #{time / 1000}μs per resolution")
```

**Target**: <100μs per resolution

### Load Testing (Concurrent Games)

```elixir
# Script to spawn N games with simulated players
1..1000
|> Task.async_stream(fn _ ->
  {:ok, game_id} = create_game()
  Enum.each(1..100, fn _ ->
    Game.handle_orders(game_id, random_orders())
    Process.sleep(100)
  end)
end, max_concurrency: 100)
|> Stream.run()
```

**Metrics to capture**:
- GenServer message queue depth
- Response latency (p50, p95, p99)
- Memory growth over time
- CPU utilization

### Profiling Hotspots

```elixir
:fprof.apply(&Phalanx.Engine.Diplomacy.execute_orders/2, [state, orders])
:fprof.profile()
:fprof.analyse(dest: 'analysis.txt')
```

Or with `mix profile.eprof`:
```bash
mix profile.eprof -e "Phalanx.Engine.Diplomacy.execute_orders(state, orders)"
```

---

## Conclusion

The Phalanx engine is architecturally sound for its current scale. Key observations:

1. **Current complexity is O(u²) worst case, O(u) typical** - acceptable for 20 units
2. **Memory usage is trivial** - thousands of games per node
3. **PubSub is the scaling bottleneck** - differential updates recommended for spectator support
4. **LiveView rendering is efficient** - SVG/CSS approach is performant

**Recommended immediate actions**:
1. Add iteration cap to conflict resolution (safety)
2. Implement differential state broadcasts (spectator scaling)

**Defer until needed**:
- Pre-computed adjacency
- Formation caching
- Distributed architecture
