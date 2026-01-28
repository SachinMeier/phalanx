# Grouping/Stacking Alternatives Analysis

**Context**: Phalanx is a simultaneous-turn tactical game simulating ancient Greek warfare. The core question: how should the game represent "units fighting as a group"?

---

## Historical Background

Understanding the real phalanx informs design choices.

### Depth as Strength

Greek phalanxes were typically 8 men deep. The Macedonians used 16. The first 3-5 ranks could project spears forward; rear ranks added "pushing power" (othismos) and replaced fallen soldiers.

Epaminondas at Leuctra (371 BC) massed 50 ranks deep on one wing, demonstrating that depth concentration could break a line. This was revolutionary: depth became a tactical variable, not just a formation constant.

**Design implication**: Depth should matter. A column of 3 units behind each other should fight differently than a line of 3 units abreast.

### Width as Coverage

The phalanx's weakness: flanks. A wider formation covered more ground but thinned the line. Breaking through the center was nearly impossible due to shield overlap and coordinated advance.

**Design implication**: Width provides mutual protection but exposes ends. Formation shape matters.

### The Push (Othismos)

Rear ranks didn't just wait. They pushed forward, adding momentum. If your rear gets attacked, you lose that push.

**Design implication**: Support from behind should be a distinct bonus, and it should be disruptable.

---

## Option 1: Adjacency Bonuses (No Explicit Groups)

**Current spec recommendation.**

### Description

- No group entity exists
- Each turn, calculate bonus per unit based on neighbors
- +1 strength per adjacent ally with same facing
- +1 strength if unit directly behind is pushing same direction
- Movement is still per-unit (but see atomicity question below)

### Strength Calculation Example

```
       [A]
   [B] [C] [D]      All facing East
       [E]

Unit C gets:
- +2 from B and D (flanking allies, same facing)
- +1 from E (rear support, if E ordered to push same direction)
- Total: base 1 + 3 = 4 strength
```

### Pros

| Aspect | Assessment |
|--------|------------|
| Implementation | Simple. Count neighbors. |
| State | No new entities. |
| Player burden | Zero. Bonus is automatic. |
| Tactical depth | Positioning is everything. |
| Historical feel | Phalanx was a discipline, not a command. |

### Cons

| Aspect | Assessment |
|--------|------------|
| Width vs Depth | Both treated identically (+1 per neighbor). |
| Line cohesion | No penalty for spreading out. |
| Movement | Each unit independent; formations drift. |
| "Phalanx" identity | Abstract. No clear group boundary. |

### Open Questions

1. **Should width and depth bonuses differ?**
   - Historical: rear ranks push, flank neighbors overlap shields
   - Current spec: both are +1
   - Alternative: flank = +1, rear support = +0.5 (or conditional on movement)

2. **What prevents deathball formations?**
   - 7-hex cluster (center + 6 neighbors) = center unit at +6 strength
   - Is this overpowered or fine?
   - Historical: blobs weren't used because they have no front

---

## Option 2: Explicit Group Declaration

### Description

- Players issue "form phalanx" orders to declare specific units as a group
- Group persists until disbanded or broken
- Group moves atomically (one order for whole group)
- Group has aggregate strength calculation

### Order Types Required

```elixir
%Order{type: :form_group, positions: [{1,2}, {1,3}, {1,4}]}
%Order{type: :disband_group, group_id: "abc"}
%Order{type: :group_move, group_id: "abc", direction: :east}
```

### Strength Calculation

Option A: Sum all unit strengths (group of 3 = 3 strength)
Option B: Diminishing returns (1 + 0.7 + 0.5 = 2.2)
Option C: Fixed bonus per member (+0.5 per additional member)

### Pros

| Aspect | Assessment |
|--------|------------|
| Player agency | Explicit control over what's grouped |
| Identity | Clear "this is my phalanx" |
| Atomicity | Natural: group = one unit for movement |
| Strategic depth | Commitment to formations |

### Cons

| Aspect | Assessment |
|--------|------------|
| Implementation | Complex. New struct, new orders, lifecycle management. |
| Edge cases | Death of member? Unit forced out by attack? Rotation disagreement? |
| UI burden | Need group selection, visualization, commands |
| Historical accuracy | Greeks didn't "declare" formations mid-battle |

### Critical Edge Cases

1. **Member death**: Does group shrink or dissolve?
2. **Forced movement**: Enemy pushes one unit out of position. Group broken?
3. **Mixed orders**: What if Player A moves unit X left while group is moving right?
4. **Rotation**: Can a group contain units with different facing?

---

## Option 3: Stacking (Multiple Units Per Hex)

### Description

- 2-3 units can occupy the same hex
- Combined strength for attacks/defense
- Single target for enemy attacks
- Represents depth literally (front rank + rear ranks)

### Stack Mechanics

| Stack Size | Strength | Vulnerability |
|------------|----------|---------------|
| 1 unit | 1 | Normal |
| 2 units | 1.5-2? | Single hex to attack |
| 3 units | 1.75-2.5? | Area attacks devastating |

### Historical Accuracy

This most directly models the actual phalanx: 8-16 ranks deep, occupying effectively one position on the battlefield.

### Comparison to Wargame Tradition

Traditional hex wargames use stacking limits (e.g., "max 3 units per hex"). Stacking:
- Concentrates force
- Creates high-value targets
- Trades flexibility for power

From tabletop wargame analysis: "Stacks draw heavier casualties from Density Fire Modifier" and "Moving a stack forward attracts Automated Defensive Fire."

### Pros

| Aspect | Assessment |
|--------|------------|
| Historical accuracy | Phalanx WAS stacked |
| Simplicity of position | Fewer hexes to track |
| Natural depth | Rear ranks literally behind |
| Combat focus | Attack one hex = attack the formation |

### Cons

| Aspect | Assessment |
|--------|------------|
| Departure from Diplomacy | Diplomacy = 1 unit/territory |
| Flanking | How does flanking work? Attack from side = hit whole stack? |
| Damage distribution | Who takes damage first? Front rank? Split? |
| Map feel | Fewer pieces visible, less "army on the field" feeling |

### Critical Design Questions

1. **Damage distribution in stack**
   - Option A: Front unit takes all damage (shield for rear)
   - Option B: Damage split proportionally
   - Option C: Damage to stack HP pool, deaths assigned when threshold crossed

2. **Flanking stacks**
   - If attacked from side, does the "flank" bonus apply?
   - Historical: yes, phalanx was vulnerable to flank cavalry

3. **Retreating from stacks**
   - Can one unit leave? Or all-or-nothing?

### Advance Wars Comparison

Advance Wars allows unit "joining" (combining):
- Two damaged units merge into one
- HP, fuel, ammo combined
- Excess HP converted to funds

This is unit consolidation, not tactical stacking, but shows a precedent.

---

## Option 4: Front/Rear Rank System

### Description

- Each hex has up to 2 "layers": Front and Rear
- Front unit fights
- Rear unit provides support bonus
- Rear unit absorbs casualties when front dies

### Mechanics

```
Hex (3,2):
  Front: Unit A (fights, takes damage)
  Rear:  Unit B (+1 support, replaces A if A dies)
```

### Movement

- Front and Rear move together (atomic for that hex)
- Or: Front can move forward, Rear can "step up" to become Front

### Strength Calculation

| Configuration | Front Unit Strength |
|---------------|---------------------|
| Front only | Base 1 |
| Front + Rear | Base 1 + 1 (support) |
| Adjacent Front + Rear | +1 from flank + 1 from rear = +2 |

### Pros

| Aspect | Assessment |
|--------|------------|
| Explicit depth | Clear "this unit is supporting" |
| Replacement | Rear fills in, no retreat needed |
| Limited stacking | Cap at 2 prevents deathballs |
| Distinct roles | Front = fighter, Rear = support |

### Cons

| Aspect | Assessment |
|--------|------------|
| New position type | "Rear" position is novel concept |
| UI complexity | Must show front vs rear in each hex |
| Limited depth | Only 2 ranks, not 8-50 |
| Movement | Awkward: what if Rear wants to leave? |

---

## Option 5: Auto-Detected Formation Templates

### Description

- Engine detects predefined shapes (line of 3, wedge, etc.)
- Applies bonuses when shape matched
- No player declaration needed

### Example Templates

| Formation | Shape | Bonus |
|-----------|-------|-------|
| Line | 3+ units in straight row | +1 per flank neighbor |
| Wedge | Arrow shape | +1 push, flanks defended |
| Square | 2x2 or 3x3 | +2 defense, reduced mobility |
| Echelon | Diagonal line | +1 advance, flank exposed |

### Detection Algorithm

```elixir
def detect_formations(units) do
  units
  |> find_lines()
  |> find_wedges()
  |> find_squares()
  |> assign_bonuses()
end
```

### Pros

| Aspect | Assessment |
|--------|------------|
| Rich tactics | Specific formations for specific situations |
| Historical flavor | Named formations are evocative |
| Automatic | No player orders needed |
| Clear bonuses | "You're in a wedge, you get +X" |

### Cons

| Aspect | Assessment |
|--------|------------|
| Complexity | Many templates, detection code |
| Rigidity | Must match exact shape or no bonus |
| Balance | How to balance wedge vs line vs square? |
| Discovery | Players must learn templates |

---

## Comparison Matrix

| Criterion | Adjacency | Explicit Group | Stacking | Front/Rear | Templates |
|-----------|-----------|----------------|----------|------------|-----------|
| Implementation | Simple | Complex | Moderate | Moderate | Complex |
| Historical accuracy | Medium | Low | High | High | Medium |
| Player burden | None | High | Low | Low | Learning curve |
| Tactical depth | High | High | Medium | Medium | High |
| Movement atomicity | No* | Yes | Yes | Partial | No |
| Width vs Depth | Equal | N/A | Depth only | Depth only | Template-specific |
| Flanking clarity | High | Medium | Low | Medium | Template-specific |

*Adjacency can have optional atomicity (see current spec)

---

## Flanking Analysis by Option

Flanking (attacking from the side) should be devastating. How each option handles it:

### Adjacency Bonuses

- Clear: enemy attacks from hex not in your "front"
- Unit rotation defines front
- Flank attack = no defensive bonus from that side

### Explicit Groups

- Ambiguous: group has a "facing" but members might face differently
- Edge members define flanks
- Need rule for "group is flanked if any member is flanked"

### Stacking

- Problematic: stack has one position, surrounded by 6 hexes
- All 6 are equally adjacent
- Must define "front" of stack separately from unit facing
- Or: flanking negates ALL support (devastating)

### Front/Rear

- Interesting: front unit faces enemy, rear is protected
- Flank attack bypasses front, hits rear directly?
- Or: flank attack hits front but ignores rear support

### Templates

- Template-defined: "line flanks are exposed, square flanks are covered"
- Clear but rigid

---

## Simplicity vs Depth Tradeoff

### Most Simple: Adjacency Bonuses

- Count neighbors, apply bonus
- Atomic movement optional (propagate balks)
- No new entities

### Most Historical: Stacking

- Depth represented literally
- One position = one phalanx
- BUT: flanking ambiguity, damage distribution complexity

### Most Strategic: Explicit Groups

- Player chooses formations
- Commitment matters
- BUT: edge case explosion, UI burden

### Best Compromise: Adjacency + Atomic Movement

Current spec recommendation. Why:

1. **Implicit detection**: Group emerges from positioning
2. **Atomic movement**: One balk = all balk (phalanx holds together)
3. **Flank bonus from neighbors**: Encourages lines
4. **Rear support distinct**: +1 if pushing same direction
5. **No new entities**: State remains simple

---

## Recommendation: Adjacency Bonuses with Atomic Movement

### Why Not Stacking

Stacking most accurately models the historical phalanx (multiple ranks in one "position"). However:

1. **Flanking becomes ambiguous**: A stack has 6 adjacent hexes. Which is "flanked"? Must add stack-facing concept.
2. **Damage distribution is complex**: Who takes the hit? New mechanic needed.
3. **Diplomacy divergence**: The game builds on Diplomacy's 1-unit-per-territory. Stacking is a fundamental departure.
4. **Visual sparseness**: Fewer units on board looks less like an army.

### Why Adjacency Works

1. **Lines emerge naturally**: To maximize bonus, form lines. That's a phalanx.
2. **Flanks are clear**: Unit facing defines front. Side hexes are flanks.
3. **Depth via rear support**: Unit behind pushing = +1. Distinct from flank cohesion.
4. **Atomic movement preserves formation**: If one unit in a group balks, all balk. No accordion effect.
5. **No new entities**: Recompute groups each turn from position + facing.

### Handling the Width vs Depth Question

The current spec treats all neighbors equally (+1 each). Consider:

**Option A: Keep equal** (simpler)
- +1 per same-facing adjacent ally
- +1 if rear unit pushing same direction
- Flank and rear are the same bonus

**Option B: Differentiate** (more historical)
- Flank neighbors: +1 strength (shield overlap)
- Rear support: +1 push power (affects movement contests only?)
- Or: rear support adds to offense, flank adds to defense

**Recommendation**: Start with Option A. Playtest. If lines don't form or depth doesn't matter, add differentiation.

---

## Implementation Notes

### Group Detection Algorithm

```elixir
def detect_groups(units) do
  units
  |> Enum.group_by(fn {_pos, unit} -> {unit.color, unit.rotation} end)
  |> Enum.flat_map(fn {_key, same_facing_units} ->
    flood_fill_connected(same_facing_units)
  end)
end

defp flood_fill_connected(units) do
  # Standard connected-components on hex adjacency
  # Returns list of MapSets (each MapSet = one group)
end
```

### Atomic Movement Integration

In `Engine.Diplomacy.execute_orders/2`:

```elixir
def execute_orders(state, orders) do
  groups = Grouping.detect_groups(state.units)
  orders = populate_hold_orders(state, orders)
  movements = get_unit_movements(state, orders)
  conflicts = detect_conflicts(movements)

  # NEW: Propagate balks to entire group
  expanded_conflicts = propagate_to_groups(conflicts, groups)

  if expanded_conflicts == MapSet.new() do
    apply_orders_to_state(state, orders)
  else
    valid_orders = convert_conflicts_to_holds(orders, expanded_conflicts)
    execute_orders(state, valid_orders)
  end
end
```

### Strength Calculation

```elixir
def formation_strength(units, position) do
  unit = Map.get(units, position)
  if unit do
    neighbors = all_hex_neighbors(position)
    count = Enum.count(neighbors, fn neighbor_pos ->
      neighbor = Map.get(units, neighbor_pos)
      neighbor && neighbor.color == unit.color && neighbor.rotation == unit.rotation
    end)
    count
  else
    0
  end
end
```

---

## Sources

Historical:
- [Phalanx - Britannica](https://www.britannica.com/topic/phalanx-military-formation)
- [The Greek Phalanx - World History Encyclopedia](https://www.worldhistory.org/article/110/the-greek-phalanx/)
- [Battle of Leuctra - History Tools](https://www.historytools.org/stories/the-battle-of-leuctra-a-turning-point-in-ancient-greek-history)
- [Oblique Order - Wikipedia](https://en.wikipedia.org/wiki/Oblique_order)

Game Design:
- [Diplomacy Rules - Support Mechanics](https://en.wikibooks.org/wiki/Diplomacy/Rules)
- [Fire Emblem Pair Up - Fandom](https://fireemblem.fandom.com/wiki/Pair_Up)
- [Advance Wars Units - Fandom](https://advancewars.fandom.com/wiki/Unit)
- [Wargame Stacking Discussion](https://forum.wargameds.com/viewtopic.php?t=1751)
- [Hex Map - Wikipedia](https://en.wikipedia.org/wiki/Hex_map)
