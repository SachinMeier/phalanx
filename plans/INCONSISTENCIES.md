# Phalanx Spec Inconsistencies Report

Generated: 2026-01-29

This document catalogs contradictions, logical dilemmas, and dependency gaps found across the plans/ spec files. Issues are grouped by severity and domain.

---

## Recently Resolved

### Game Mode System (2026-01-31)

The following inconsistencies are now resolved by the new game mode system:

| Issue | Resolution |
|-------|------------|
| Win conditions location | Win conditions are now part of GameMode definitions. See `plans/game-modes/spec.md` |
| Game status values | Standardized to `:waiting | :playing | :finished`. See `plans/engine/state-machine.md` |
| Win condition checking | Added as Phase 11 in engine pipeline. See `plans/engine/spec.md` |

New documentation:
- `plans/game-modes/spec.md` - Game mode system architecture
- Updated `plans/win-conditions.md` - Now reference doc only
- Updated `plans/architecture.md` - Game struct with game_mode fields
- Updated `plans/engine/spec.md` - Win condition check phase added
- Updated `plans/engine/state-machine.md` - Game mode lifecycle

---

## Critical: Fundamental Mechanic Conflicts

These contradictions affect core game rules and would produce different gameplay depending on which spec is followed.

### 1. Flanking: Strength Bonus vs Damage Only

**RESOLVED (2026-01-31)**: Flanking affects DAMAGE only, not strength.

| Attack Angle | Damage |
|--------------|--------|
| Frontal | 0 HP |
| Flank | 1 HP |
| Rear | 2 HP |

Strength determines who wins. Attack angle determines how much damage the loser takes. Defender keeps all formation bonuses regardless of attack direction.

Updated files: `combat/spec.md`, `strength/spec.md`, `strength/flanking-analysis.md`, `strength/design-decisions-summary.md`, `MECHANICS.md`

### 2. Combined Attacks: Add Forces vs Resolve Separately

**RESOLVED (2026-01-31)**: When multiple friendly units attack the same hex, forces ADD together. Resolved as single combat.

| Aspect | Rule |
|--------|------|
| Force calculation | Sum of all friendly attackers' forces |
| Lead unit | First-ordered unit moves into hex upon victory |
| Other attackers | Hold their original positions (supported, not moved) |
| Retreat direction | Determined by lead attacker only |
| Resolution | Single combat, not multiple sequential fights |

Updated files: `combat/resolution-order.md`, `strength/flanking-analysis.md`

### 3. Damage Stacking: Additive vs Angle-Only vs Dislodge-Only

**RESOLVED (2026-01-31)**: Damage stacks. Dislodge costs 1 HP plus angle-based bonus damage.

| Source | HP Lost |
|--------|---------|
| Dislodge | 1 HP |
| Frontal angle bonus | +0 (shields block) |
| Flank angle bonus | +1 |
| Rear angle bonus | +2 |

**Total on dislodge**: Frontal = 1 HP, Flank = 2 HP, Rear = 3 HP.

Updated files: `MECHANICS.md`, `combat/spec.md`, `combat/resolution-order.md`, `strength/spec.md`, `strength/flanking-analysis.md`, `strength/design-decisions-summary.md`, `engine/spec.md`

### 4. Retreat: Deterministic vs Random

**RESOLVED (2026-01-31)**: Deterministic retreat in the same direction as the attack.

**Retreat algorithm**:
1. Primary retreat: hex in the same direction as the attack (e.g., attacked from NE → retreat NE)
2. Fallback: adjacent backward direction based on defender's facing
3. If both blocked: unit destroyed

Updated files: `combat/spec.md`, `strength/design-decisions-summary.md`, `strength/spec.md`, `combat/edge-cases-combat.md`

### 5. Rotation on Balk: Applies vs Fails

**RESOLVED (2026-01-31)**: Orders are atomic. If move fails (balk), rotation also fails.

**Rule**:
- Move order + rotation: if move balks, rotation does NOT apply
- Hold order + rotation: rotation DOES apply (no move to fail)
- Successful move + rotation: rotation applies

Updated files: `combat/resolution-order.md`, `engine/spec.md`, `architecture.md`

---

## High: Bonus Cap Contradictions

### 6. Formation Bonus Cap: None vs +4

**RESOLVED (2026-01-31)**: No formation bonus cap. Bonuses are self-balancing.

- Side bonus: capped at +2 by geometry (one neighbor on each side)
- Rear bonus: uncapped (deep formations are powerful but flankable)
- No artificial cap needed; the game self-balances

### 7. Rear Bonus Cap: None vs +2 vs Geometry-Limited

**RESOLVED (2026-01-31)**: Rear bonus is uncapped. Since all phalanx units move in the same direction, each unit has exactly one unit directly behind it in the movement direction. Deep formations provide +1 per rear ally with no cap.

### 8. Side Neighbor Count: 2 vs 4

**RESOLVED (2026-01-31)**: Side neighbors = 2 (one on each side). The "4 side neighbors" references were mistakes. A unit has exactly two side-by-side neighbors in a hex grid.

---

## High: Phase Numbering Errors

### 9. Duplicate Phase Numbers in engine/spec.md

**RESOLVED** (2026-01-31): Phase numbering standardized to 13 phases across all specs:
1. Snapshot, 2. Order Expansion, 3. Order Validation, 4. Conflict Detection, 5. Support Calculation, 6. Strength Calculation, 7. Combat Resolution, 8. Movement Execution, 9. Damage & Retreat, 10. Phalanx Lifecycle, 11. Win Condition Check, 12. Rotation Application, 13. Energy & Cleanup

### 10. Phase Count Mismatch Across Files

**RESOLVED** (2026-01-31): All files now consistently reference 13 phases:
- `engine/spec.md` - 13 phases
- `architecture.md` - 13 phases
- `engine/architecture.md` - 13-phase turn resolution
- `combat/resolution-order.md` - 11 phases (subset, doesn't include win condition check as separate phase)

---

## Medium: Data Model Conflicts

### 11. Energy Type: Integer vs Float

**NOT AN ISSUE**: `real-time.md` was a speculative ideation document (now removed). The authoritative source is `energy-system.md` which uses `energy: integer()`.

### 13. Rotation 0 Direction Mapping

| Source | Rotation 0 = |
|--------|--------------|
| `strength/spec.md:261` | NW (idx 2) |
| `strength/strength-formulas.md:13` | East |
| `strength/edge-cases-formation.md:35` | E |

**Impact**: Strength spec uses different coordinate system than other files. (Note: `real-time.md` was removed as a speculative ideation doc.)

---

## Medium: Module/Struct Naming Conflicts

### 14. Strength Module Location

| Source | Module |
|--------|--------|
| `combat/spec.md:197` | `Phalanx.Combat.Strength` at `lib/phalanx/combat/strength.ex` |
| `engine/architecture.md:58` | `Strength` at `lib/phalanx/strength.ex` |
| `strength/spec.md` | `Phalanx.Strength` |

**Impact**: Two different modules for same functionality.

### 15. Group vs Phalanx Struct

**RESOLVED**: Groups and Phalanxes are now two separate concepts:
- `Phalanx.Group` at `lib/phalanx/group.ex` - organizational, created in pre-game planning
- `Phalanx.Phalanx` at `lib/phalanx/phalanx.ex` - tactical formation, declared during battle
- `Phalanx.Formation` module handles phalanx validation and creation

See `group/spec.md` for the current design.

---

## Medium: Rule Ambiguities

### 16. Zero Energy Penalty: Decided vs TBD

| Source | Status |
|--------|--------|
| `MECHANICS.md` | "Having 0 E = -1 Health" (definitive) |
| `energy-system.md` | "Zero-Energy Penalty (UNDECIDED)" with 5 options |
| `combat/resolution-order.md:893` | "TBD (see Open Questions)" |
| `combat/test-scenarios.md:1459` | Tests assume -1 HP as fact |

### 17. Support Mechanic: Exists vs Doesn't Exist

**RESOLVED (2026-01-31)**: Support and Formation are two separate concepts that both contribute to strength.

| Bonus Type | Source | Max | Can Be Cut? |
|------------|--------|-----|-------------|
| **Formation** | Adjacent allies in same declared phalanx | No cap (side +2 geometry) | NEVER |
| **Support** | Friendly units attacking same hex | +2 | YES (if supporter attacked) |

**Strength formula**:
- Attacker: Base(1) + Formation + Support(0-2)
- Defender: Base(1) + Formation

Updated files: `strength/spec.md`, `combat/resolution-order.md`

### 18. Formation Bonus Requirements: Same Movement or Not

**RESOLVED**: Phalanxes are now explicitly declared (not auto-detected). Formation bonus applies to units in the same declared phalanx. No "same movement direction" requirement—phalanx members move atomically together. See `group/spec.md` for current design.

---

## Medium: State Machine Conflicts

### 19. Game Status Values

**RESOLVED**: Standardized to `:waiting | :playing | :finished`. The `:running` value was a typo.

### 20. Turn Phase Names

| Source | Phases |
|--------|--------|
| `engine/multiplayer-sync.md:27` | `planning, locked, resolution` |
| `engine/state-machine.md:77` | `:order_collect, :order_pending, :resolving, :turn_complete` |

---

## Lower: Missing Updates / Stale References

### 21. Terrain System Breaks Move Signature

**NOT APPLICABLE**: Terrain is future work. V1 uses a uniform flat grid with no terrain.
The `move/4` signature is correct for V1. When terrain is added (future), signatures will be updated then.
See `plans/engine/terrain-system.md` (marked as future work).


### 23. Performance Analysis Uses Old Phase Count

`engine/performance-analysis.md` analyzes simplified phases, not current 13-phase structure.

### 24. Starting Positions Conflict

| Source | Purple Start | Red Start |
|--------|--------------|-----------|
| `win-conditions.md` | Rows 0-1 | Rows 8-9 |
| `.claude/CLAUDE.md` | Row 7 | Row 2 |

---

## Lower: Internal Document Contradictions

### 25. Phalanx Shape: Rectangular vs Any Connected

**RESOLVED**: Shape is irrelevant. The requirement is: **same group** + **connected** + **same facing**. L-shapes, diagonals, and irregular shapes are all valid phalanxes. The "rectangular" language was historical context, not a game rule.

### 26. Same-Team Cycle Resolution

`combat/edge-cases-movement.md`:
- 2-unit swap: "A moves, B balks"
- 3-unit rotation: "All balk"

No explanation for why 2-unit and 3-unit cases differ.

### 27. Depth Definition: Single Hex vs Chain

| Source | Rear Definition |
|--------|-----------------|
| `strength/edge-cases-formation.md:130` | "ONLY the single hex directly behind" |
| `strength/spec.md:67` | Diagram shows `[REAR] [REAR] [REAR]...` chain |

---

## Recommended Resolution Priority

~~1. **Flanking mechanics**~~ - RESOLVED: Damage only, not strength
~~2. **Damage model**~~ - RESOLVED: Stacking (dislodge 1 HP + angle bonus)
~~3. **Combined attacks**~~ - RESOLVED: Forces add, lead unit moves in
~~4. **Bonus caps**~~ - RESOLVED: No cap (side max +2 by geometry, rear uncapped)
~~5. **Rotation on balk**~~ - RESOLVED: Orders atomic, balk = no rotation
~~6. **Retreat determinism**~~ - RESOLVED: Same direction as attack
~~7. **Side neighbor geometry**~~ - RESOLVED: 2 side positions (one each side)
~~8. **Phase numbering**~~ - RESOLVED: 13 phases standardized across all specs
9. **Module naming** - Choose Phalanx.Strength vs Combat.Strength
~~10. **Support mechanic**~~ - RESOLVED: Support (combined attack) + Formation (phalanx) are separate bonuses

---

## Files Analyzed

### Combat Domain
- `combat/spec.md`
- `combat/resolution-order.md`
- `combat/edge-cases-combat.md`
- `combat/edge-cases-movement.md`
- `combat/alternative-models.md`
- `combat/test-scenarios.md`

### Strength Domain
- `strength/spec.md`
- `strength/strength-formulas.md`
- `strength/balance-analysis.md`
- `strength/edge-cases-formation.md`
- `strength/flanking-analysis.md`
- `strength/historical-accuracy.md`
- `strength/design-decisions-summary.md`

### Group Domain
- `group/spec.md`
- `group/alternatives-grouping.md`
- `group/user-groups-vs-phalanx.md`

### Engine Domain
- `engine/spec.md`
- `engine/architecture.md`
- `engine/state-machine.md`
- `engine/multiplayer-sync.md`
- `engine/terrain-system.md` (future work - not in V1 scope)
- `engine/performance-analysis.md`
- `engine/tutorial-design.md`

### Standalone
- `energy-system.md`
- `win-conditions.md`
- `exploit-analysis.md`
- `ux-feedback.md`

Note: `real-time.md` was a speculative ideation document and has been removed from scope.
