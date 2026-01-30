# Phalanx Engine Design: Overnight Work Summary

**Date**: 2026-01-26 to 2026-01-27

This document summarizes all design work completed for the Phalanx combat engine system.

---

## Document Inventory

### Core Specifications

| Document | Location | Summary |
|----------|----------|---------|
| Force Calculation Spec | `spec-260126-force/spec.md` | Strength calculation from base + formation + flanking bonuses |
| Grouping Mechanics Spec | `spec-260126-group/spec.md` | Phalanx detection via flood-fill, majority-rule balking, atomic movement |
| Combat Resolution Spec | `spec-260126-combat/spec.md` | Dislodge resolution, damage application, retreat execution |
| **Unified Engine Spec** | `spec-260126-engine/spec.md` | Complete 10-phase resolution algorithm integrating all systems |

### Edge Case Analysis

| Document | Location | Summary |
|----------|----------|---------|
| Movement Edge Cases | `spec-260126-combat/edge-cases-movement.md` | Collision cascades, swap detection, cycle handling |
| Combat Edge Cases | `spec-260126-combat/edge-cases-combat.md` | Multiple attackers, support cutting, retreat cascades |
| Formation Edge Cases | `spec-260126-force/edge-cases-formation.md` | Bonus cap enforcement, mixed rotations, diagonal lines |

### Design Analysis

| Document | Location | Summary |
|----------|----------|---------|
| Strength Formulas | `spec-260126-force/strength-formulas.md` | Mathematical analysis of all force calculation formulas |
| Flanking Analysis | `spec-260126-force/flanking-analysis.md` | Attack angle classification, direction-based bonus breakdown |
| Combat Model Alternatives | `spec-260126-combat/alternative-models.md` | Evaluated: Pure Diplomacy, Pure HP, Hybrid (chose Simplified Hybrid) |
| Grouping Alternatives | `spec-260126-group/alternatives-grouping.md` | Evaluated: Implicit vs Explicit vs Hybrid grouping (chose Implicit) |
| Balance Analysis | `spec-260126-force/balance-analysis.md` | Formation strength vs flanking effectiveness tradeoffs |
| Historical Accuracy | `spec-260126-force/historical-accuracy.md` | How design choices reflect historical phalanx tactics |

### Implementation Planning

| Document | Location | Summary |
|----------|----------|---------|
| Resolution Order | `spec-260126-combat/resolution-order.md` | Detailed 10-phase algorithm with state transitions |
| Test Scenarios | `spec-260126-combat/test-scenarios.md` | 44 test cases covering movement, formation, combat, and integration |
| Design Decisions Summary | `spec-260126-force/design-decisions-summary.md` | All design choices with rationale (base strength, bonuses, caps, etc.) |
| **Implementation Guide** | `spec-260126-engine/implementation-guide.ex` | Complete idiomatic Elixir code for all modules |

### Supporting Systems

| Document | Location | Summary |
|----------|----------|---------|
| State Machine | `spec-260126-engine/state-machine.md` | Game lifecycle states, turn phases, transition tables |
| Multiplayer Sync | `spec-260126-engine/multiplayer-sync.md` | Turn timer, order locking, resolution broadcast, disconnect handling |
| Database Schema | `spec-260126-engine/database-schema.md` | Optional persistence: players, games, turns tables with Ecto schemas |

### Not Created (Files Listed But Missing)

The following documents were listed in the request but do not exist:
- `spec-260126-engine/energy-system.md`
- `spec-260126-engine/win-conditions.md`
- `spec-260126-engine/ux-feedback.md`
- `spec-260126-engine/exploit-analysis.md`

---

## Key Design Decisions

### Force Calculation

| Decision | Choice | Max Value |
|----------|--------|-----------|
| Base strength | Uniform 1 for all units | 1 |
| Side cohesion | +1 per adjacent same-facing ally | +2 (capped) |
| Depth bonus | +1 per rear same-facing ally | +2 (capped) |
| Support | +1 per ally moving same direction | +2 (capped) |
| Flanking | +1 (flank attack), +2 (rear attack) | +2 |
| **Max attack strength** | 1 + 2 + 2 + 2 + 2 | **9** |
| **Max defense strength** | 1 + 2 + 2 | **5** |

### Grouping System

| Decision | Choice |
|----------|--------|
| Detection model | Implicit (flood-fill each turn) |
| Minimum group size | 2 adjacent same-facing allies |
| Movement atomicity | Majority rule (>50% balk = all balk) |
| Mixed orders | Converted to holds |
| Same facing | Exact rotation match required |

### Combat System

| Decision | Choice |
|----------|--------|
| Combat model | Simplified Hybrid (Diplomacy dislodge + minimal HP) |
| Dislodge damage | -1 HP on dislodge |
| Collision type | Destination-only (existing Diplomacy behavior) |
| Tie resolution | Defender wins (neither moves) |
| Retreat selection | Random from valid hexes |
| No retreat | Unit destroyed |

### Resolution Order (10 Phases)

1. **Snapshot**: Capture state, detect groups
2. **Order Validation**: Populate holds, reject invalid moves, enforce group movement
3. **Support Calculation**: Build support graph, identify cut supports
4. **Conflict Detection**: Destination conflicts, attacks, swaps, cycles
5. **Strength Calculation**: Base + formation + support + flanking
6. **Combat Resolution**: Compare strengths, apply majority rule
7. **Movement Execution**: Move winning units to destinations
8. **Damage & Retreat**: Apply HP loss, execute retreats
9. **Rotation Application**: Apply rotation orders
10. **Energy & Cleanup**: Update energy, remove dead units, increment turn

---

## Open Questions Requiring User Input

### High Priority

1. **Retreat Selection**: Random or player choice?
   - Random: simpler, no async phase needed
   - Player choice: more tactical depth, requires turn sub-phases
   - **Current recommendation**: Random (for MVP)

2. **Multiple Attackers Same Target**: Do forces combine?
   - Current spec: Resolve separately (each attack independent)
   - Alternative: Combine forces against shared defender
   - **Needs decision** if this comes up in playtesting

3. **Stalemate Frequency**: Equal forces may cause frequent standoffs
   - Options: turn limits, objectives, momentum mechanics
   - **Defer to playtesting**

### Lower Priority

4. **Support Chain Validation**: If A supports B, and A is attacked, does A's support count?
   - Current spec: No, attacked supporters are cut
   - **Resolved in spec**, but verify during implementation

5. **Rotation Timing**: Which facing determines force calculation?
   - Current spec: Pre-rotation (snapshot at turn start)
   - **Resolved in spec**

6. **Snowball Dynamics**: First dislodge creates HP advantage that compounds
   - May need morale/momentum mechanics if too harsh
   - **Defer to playtesting**

---

## Recommended Reading Order

### For Understanding the System (30 minutes)

1. `spec-260126-engine/spec.md` - Start here for complete overview
2. `spec-260126-force/design-decisions-summary.md` - Understand all choices made

### For Implementation (2 hours)

1. `spec-260126-engine/spec.md` - Resolution algorithm
2. `spec-260126-engine/implementation-guide.ex` - Working Elixir code
3. `spec-260126-combat/test-scenarios.md` - 44 test cases to implement

### For Deep Dives

- Formation mechanics: `spec-260126-force/spec.md` + `strength-formulas.md`
- Combat mechanics: `spec-260126-combat/spec.md` + `resolution-order.md`
- Grouping mechanics: `spec-260126-group/spec.md` + `alternatives-grouping.md`
- Multiplayer: `state-machine.md` + `multiplayer-sync.md`

---

## Areas Needing Review

### Potential Issues

1. **Blob Formation Dominance**: Interior units with +4 formation bonus (strength 5) may be too strong. Mitigation relies on flanking, but single flanker (strength 2) cannot dislodge. Consider:
   - Map design with flanking routes
   - Objectives that force spreading out
   - Special flanking rules for outnumbered defenders

2. **Missing Energy System**: The energy system is referenced in specs but `energy-system.md` does not exist. Current spec mentions:
   - Forward move: -1 energy
   - Backward/sideways: 0 energy
   - Hold (not attacked): +1 energy
   - Hold (attacked): 0 energy
   - Zero energy: -1 HP
   - **Needs full spec before implementation**

3. **Missing Win Conditions**: `win-conditions.md` does not exist. Options mentioned:
   - Elimination (all enemy units destroyed)
   - Rout (losses exceed threshold)
   - Turn limit with scoring
   - **Needs spec before game is playable**

4. **Support Cutting Ambiguity**: If A supports B, and C attacks A, when is A's support cut?
   - Before strength calculation? (A never contributes)
   - After A's attack resolves? (A contributes if A wins)
   - **Current spec says "attacked = cut" but timing unclear**

### Implementation Notes

1. **Implementation Guide** (`implementation-guide.ex`) provides complete working code for:
   - Hex utilities
   - Unit struct
   - Group detection
   - Force calculation
   - Combat resolution
   - Retreat logic
   - Engine integration

2. **Test Scenarios** (`test-scenarios.md`) provides 44 test cases organized by:
   - Movement (12 tests): collisions, chains, cycles, map boundaries
   - Formation (12 tests): side cohesion, depth, caps, mixed rotations
   - Combat (15 tests): strength comparison, flanking, retreats, multi-attacker
   - Integration (5 tests): full turn resolution, energy, rotation timing

3. **PR Roadmap** in unified spec suggests 11 PRs, but could be consolidated:
   - PR 1-2: Foundation (Unit, Moves)
   - PR 3-4: Grouping + Force
   - PR 5-8: Combat modules
   - PR 9-11: Engine + UI

---

## Summary Statistics

| Category | Count |
|----------|-------|
| Core specs | 4 |
| Edge case docs | 3 |
| Design analysis docs | 6 |
| Implementation docs | 4 |
| Supporting system docs | 3 |
| **Total documents created** | **20** |
| Test scenarios defined | 44 |
| PRs in roadmap | 11 |
| Open questions | 6 |

---

## Next Steps

1. **User Review**: Resolve open questions (especially retreat selection, multiple attackers)
2. **Energy System Spec**: Create missing `energy-system.md`
3. **Win Conditions Spec**: Create missing `win-conditions.md`
4. **Begin Implementation**: Start with PR #1 (Unit struct) from roadmap
5. **Playtesting Setup**: Prepare test harness for 44 test scenarios
