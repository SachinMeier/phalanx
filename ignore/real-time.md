# Real-Time Engine Design

A real-time alternative to the simultaneous turn-based resolution model. Orders execute instantly with unit cooldowns creating tactical rhythm.

## Core Concept

**Current Model (Simultaneous)**:
- Both players collect orders
- All orders execute at once
- New turn begins

**Proposed Model (Real-Time with Cooldowns)**:
- Player issues order to unit(s)
- Engine executes immediately
- Affected units enter cooldown (cannot receive new orders)
- No turns—continuous play

## Why Cooldowns?

Without cooldowns, the game becomes a click-speed contest or a chase game where faster APM always wins. Cooldowns create:

| Effect | Result |
|--------|--------|
| **Commitment** | Moving a unit locks it in place temporarily |
| **Vulnerability windows** | Units on cooldown are sitting targets |
| **Stagger incentive** | Issuing all orders at once = all units frozen simultaneously |
| **Equalizer** | Slower players can still compete if they time orders well |

---

## Core Mechanics

### Order Execution

1. Player selects unit(s)
2. Player issues movement/rotation command
3. Engine validates immediately
4. If valid: execute, apply cooldown
5. If invalid: reject, no cooldown

**Instant execution** means no queuing, no prediction, no "will this collide?" uncertainty—what you command is what happens (if legal).

### Cooldown Rules

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| **Movement cooldown** | 2.5 seconds | Long enough to matter, short enough to feel responsive |
| **Rotation cooldown** | 1.5 seconds | Pivoting is faster than marching |
| **Both in same order** | 3.0 seconds | Slight discount for combined action |
| **Attacked while cooling** | Extends by 1.0s | Panic/disruption when hit |

**Cooldown starts after execution**, not after command issued.

### Movement Validation (Instant)

When unit A moves to hex X:
- **Empty hex**: A moves to X
- **Occupied by friendly**: Blocked, no movement, no cooldown
- **Occupied by enemy**: Combat triggered (see Combat section)

No collision ambiguity—first to move claims the hex.

### Group Orders

Select multiple units → issue single command → all execute simultaneously → all enter cooldown.

**Constraint**: Only units with same rotation can receive group movement orders (phalanx requirement). Mixed-rotation selections can only rotate together, not move.

---

## Combat in Real-Time

### Attack Execution

When unit A moves into hex occupied by enemy B:

1. Calculate A's attack strength (base + formation at moment of attack)
2. Calculate B's defense strength (base + formation at moment of attack)
3. Compare: attacker needs strength > defender to dislodge
4. Apply damage based on attack angle
5. Execute retreat if dislodged
6. Attacker moves into hex (if dislodge successful)

**Formation bonuses frozen at attack moment**: allies must be in position *when you attack*, not after.

### Flanking in Real-Time

The flanking advantage becomes more tactical:
- Move unit A to flank position
- A enters cooldown
- Enemy can respond before you attack
- OR: coordinate two units—one flanks while other attacks

This creates **commitment tension**: positioning for flank takes time, during which enemy can react.

### Simultaneous Attacks

If two units attack same target within 100ms window: combine forces (sum strengths), share dislodge, lead attacker determined by timestamp.

Outside 100ms: sequential resolution. First attack might dislodge, second attack hits empty hex.

---

## Formation Bonuses (Real-Time)

### Side Cohesion
**Unchanged**: +1 per adjacent ally with same rotation.

But now dynamic—allies moving away break your bonus mid-fight.

### Depth Bonus
**Unchanged**: +1 per rear ally with same rotation.

Movement breaks depth chains. Strategic choice: keep depth or advance?

### Attack Angle Bonus
**Unchanged**: +1 flank, +2 rear.

Real-time makes flanking maneuvers visible to opponent. Race to reposition.

---

## Energy System Integration

Energy regenerates during cooldown (unit is "resting"):

| State | Energy Change |
|-------|---------------|
| Moving | -1 on execution |
| On cooldown (not attacked) | +0.4/second |
| On cooldown (attacked) | +0 |
| Holding position (no cooldown) | +0.2/second |

This creates a natural attrition curve: aggressive play drains energy, defensive holding regenerates.

**Zero energy while on cooldown**: unit takes 1 HP damage from exhaustion, cooldown extended by 1s.

---

## Technical Architecture

### State Model

```elixir
%Unit{
  position: {col, row},
  rotation: 0..5,  # 0=E, 1=NE, 2=NW, 3=W, 4=SW, 5=SE
  health: integer,
  energy: float,
  cooldown_until: DateTime | nil,
  last_action: :move | :rotate | :both | nil
}
```

### Game Process Changes

Current: GenServer holds state, processes turn batches.

Real-time: GenServer becomes a **continuous state machine**:

```elixir
defmodule Phalanx.Game.Realtime do
  use GenServer

  # No batching—immediate execution
  def handle_cast({:order, player_token, unit_name, order}, state) do
    with :ok <- validate_player_owns_unit(state, player_token, unit_name),
         :ok <- validate_unit_not_cooling(state, unit_name),
         {:ok, new_state} <- execute_order(state, unit_name, order) do
      broadcast_state_delta(state.id, new_state)
      {:noreply, new_state}
    else
      {:error, reason} ->
        notify_player(player_token, {:order_rejected, reason})
        {:noreply, state}
    end
  end

  # Cooldown expiry ticker
  def handle_info(:tick, state) do
    now = DateTime.utc_now()
    {expired, still_cooling} = partition_cooldowns(state.units, now)

    new_state =
      state
      |> clear_cooldowns(expired)
      |> update_energy_regen(now)

    if expired != [] do
      broadcast_cooldown_expired(state.id, expired)
    end

    schedule_tick()
    {:noreply, new_state}
  end
end
```

### Tick Rate

**Server tick**: 100ms (10 Hz)
- Checks cooldown expirations
- Updates energy regeneration
- Broadcasts state deltas

**Client render**: 60 fps with interpolation
- Smooth unit movement animations
- Cooldown progress bars update continuously

### Network Model

**Optimistic client execution**: Client shows movement immediately, server confirms/rejects.

**Latency handling**: Orders include client timestamp. Server uses timestamp for 100ms simultaneous-attack window but executes at server time.

**Reconnection**: Full state sync on reconnect. Cooldowns stored server-side, client reconstructs.

---

## UX/UI Design

### Unit Selection

**Current**: Keyboard hotkeys (Y/U/I/O/P for red, H/J/K/L/M for purple).

**Real-time enhancement**:
- Click unit to select
- Shift+click for multi-select
- Drag-box selection
- Hotkeys still work for speed
- Tab cycles through ready units (not on cooldown)

### Order Input

**Movement**: WASD or hex direction keys (same as current).

**Rotation**: Q/R (same as current).

**No Enter required**: Orders execute on keypress.

### Cooldown Visualization

```
┌─────────────────────────────────────────┐
│                                         │
│     [Unit Y]        [Unit U]            │
│     ████████░░      ░░░░░░░░░░          │
│     1.2s left       READY               │
│                                         │
│     [Unit I]        [Unit O]            │
│     ██░░░░░░░░      █████████░          │
│     0.4s left       2.1s left           │
│                                         │
└─────────────────────────────────────────┘
```

**On-hex indicators**:
- Pulsing ring: ready for orders
- Grayed overlay: on cooldown
- Progress arc: time remaining
- Red flash: cooldown extended (attacked)

### Combat Feedback

When attack executes:
- Attack line drawn between hexes
- Damage number floats up
- Hit unit flashes
- Retreat arrow shows direction
- Sound cue (clash for frontal, crunch for flank)

### Group Selection Feedback

When selecting multiple units:
- Formation outline shows which units share rotation
- Invalid group (mixed rotation) shows warning
- Valid group highlights movement options

### Minimap / Tactical View

For 10x10 grid, full view should suffice. But if grid grows:
- Picture-in-picture overview
- Cooldown status of all units at a glance
- Hotspots where combat is occurring

---

## Balance Analysis

### Speed Advantage

**Concern**: Fast players dominate.

**Mitigations**:
1. **Cooldowns equalize**: Once units move, speed doesn't help until cooldowns expire
2. **Stagger penalty**: Moving all units = all frozen = vulnerable window
3. **Prediction rewards**: Slow players who anticipate can pre-position
4. **Diminishing returns**: After ~5-10 orders, both players are waiting on cooldowns

**Remaining advantage**: Initial positioning phase, emergency reactions. Acceptable—rewards engagement.

### Chase Prevention

**Concern**: Retreating player kites endlessly.

**Mitigations**:
1. **Movement restrictions**: Can't move perpendicular to facing. Rotation costs time.
2. **Energy drain**: Moving costs energy. Constant running = exhaustion.
3. **Map boundaries**: 10x10 grid limits running room.
4. **Flanking speed**: Two units can corner one faster than one can flee.

**Design choice**: Forward movement costs energy (-1), backward costs nothing but is slower (same cooldown). Retreat is sustainable but not advantageous.

### Formation Value

**Concern**: Real-time breaks formation coordination (can't move together).

**Mitigations**:
1. **Group orders**: Select multiple, move together, share cooldown.
2. **Formation snapshot**: Bonuses calculated at attack moment, not continuously.
3. **Holding advantage**: Standing formation regenerates energy faster than moving.

**New dynamic**: Formations are valuable but rigid. Breaking formation to flank creates temporary vulnerability.

### First-Mover Advantage

**Concern**: Whoever attacks first wins (no simultaneous defense).

**Mitigations**:
1. **Defender bonus**: Unit being attacked gets formation bonuses for defense.
2. **Attack requires movement**: Attacker spends cooldown approaching.
3. **Counterattack window**: After attack resolves, defender's allies can respond.

**Acceptable asymmetry**: Attackers choose when and where. Defenders get positional advantage. Historical.

### Comeback Mechanics

**Concern**: Losing player gets snowballed.

**Mitigations**:
1. **No death spiral**: Fewer units = shorter attention span = faster reactions possible.
2. **Formation bonuses scale down gracefully**: Losing one unit doesn't collapse entire line.
3. **Flanking opportunities**: Winning player advancing creates own flank vulnerabilities.

---

## Comparison: Simultaneous vs Real-Time

| Aspect | Simultaneous | Real-Time |
|--------|--------------|-----------|
| **Skill expression** | Prediction, reading opponent | Reaction, timing, multitasking |
| **Pace** | Deliberate, chess-like | Intense, RTS-like |
| **Formation coordination** | Natural (all move at once) | Requires group selection |
| **Spectator experience** | Clear turn boundaries | Continuous action |
| **Accessibility** | Lower APM requirement | Higher APM ceiling |
| **Mind games** | Bluffing, feints via order timing | Baiting cooldowns |
| **Implementation complexity** | Simpler (batch processing) | More complex (real-time sync) |

### Which Preserves the Ethos Better?

**Simultaneous**: More faithful to Diplomacy heritage. Emphasizes prediction and positioning. Formation play emerges naturally.

**Real-Time**: More visceral. Flanking maneuvers feel tactical. But risks becoming micro-heavy APM contest.

**Recommendation**: Real-time is viable if:
1. Cooldowns are long enough (2.5s+) to prevent click-spam dominance
2. Group orders make formation play practical
3. UI makes cooldown status crystal clear

---

## Hybrid Option: Real-Time Planning, Batch Execution

A middle ground:

1. **Planning phase** (10 seconds): Both players issue orders freely
2. **Execution phase** (instant): All orders execute simultaneously
3. **Cooldown phase** (5 seconds): Units that moved cannot be ordered
4. **Repeat**

This preserves simultaneous resolution while adding real-time tension during planning.

**Downside**: Loses the "instant feedback" appeal of pure real-time.

---

## Implementation Phases

### Phase 1: Core Loop
- Single-unit immediate execution
- Basic cooldown timer
- No combat (movement only)
- Collision = blocked

### Phase 2: Combat
- Attack on move-into-enemy
- Strength calculation (base only)
- Dislodge and retreat
- Damage application

### Phase 3: Formations
- Side cohesion bonus
- Depth bonus
- Group selection and orders
- Formation visualization

### Phase 4: Polish
- Energy system
- Attack angle damage
- Combat animations
- Sound design

### Phase 5: Balance
- Cooldown tuning
- Energy rate tuning
- Playtesting
- APM analysis

---

## Open Questions

1. **Pause/timeout**: Allow pausing in casual games? Tournament rules?

2. **Simultaneous attacks**: 100ms window too small? Too large? Should be configurable?

3. **Retreat timing**: Does retreating unit get cooldown? (Probably yes—prevents instant counter-retreat)

4. **Rotation during cooldown**: Can unit rotate while movement-cooling? (Probably no—simplicity)

5. **Observer mode**: How to spectate real-time games? Delay to prevent coaching?

---

## Summary

Real-time execution with cooldowns transforms Phalanx from a prediction game to a timing/reaction game while preserving formation-based tactical depth. The key insight: **cooldowns create commitment**, preventing the game from degenerating into either a click-spam contest or an endless chase.

Success depends on:
- Long enough cooldowns (2.5s movement)
- Clear cooldown visualization
- Practical group selection for formations
- Energy drain preventing pure kiting

The core ethos—flanking wins, formations protect, depth pushes—remains intact. The expression changes from "predict enemy orders" to "exploit enemy cooldowns."
