# Phalanx Design Documents Index

This index catalogs all design documents created for the Phalanx combat engine.

**Base Path**: `plans/`

---

## Core Specs

| Document | Path | Description | Status |
|----------|------|-------------|--------|
| Force Calculation | `spec-260126-force/spec.md` | Strength calculation: base (1) + side cohesion (+2) + depth (+2) + support (+2) + flanking (+2) | Complete |
| Grouping Mechanics | `spec-260126-group/spec.md` | Phalanx detection via flood-fill; majority-rule balking; atomic group movement | Complete |
| Combat Resolution | `spec-260126-combat/spec.md` | Dislodge mechanics with HP damage (-1 per dislodge); retreat to opposite hex or die | Complete |
| Unified Engine | `spec-260126-engine/spec.md` | 10-phase resolution algorithm integrating force, grouping, and combat systems | Complete |

---

## Edge Case Analysis

| Document | Path | Description | Status |
|----------|------|-------------|--------|
| Movement Edge Cases | `spec-260126-combat/edge-cases-movement.md` | Collision cascades, swap detection via mutual destination check, cycle resolution | Complete |
| Combat Edge Cases | `spec-260126-combat/edge-cases-combat.md` | Multiple attackers resolved independently; support cutting rules; retreat cascade handling | Complete |
| Formation Edge Cases | `spec-260126-force/edge-cases-formation.md` | Bonus caps enforced per-source; mixed rotations break groups; diagonal lines count | Complete |

---

## Design Analysis

| Document | Path | Description | Status |
|----------|------|-------------|--------|
| Strength Formulas | `spec-260126-force/strength-formulas.md` | Mathematical breakdown: max attack 9, max defense 5; formula derivations | Complete |
| Flanking Analysis | `spec-260126-force/flanking-analysis.md` | Attack angle classification: front (0), flank (+1 at 60-120 deg), rear (+2 at 180 deg) | Complete |
| Combat Models | `spec-260126-combat/alternative-models.md` | Evaluated Pure Diplomacy, Pure HP, Full Hybrid; chose Simplified Hybrid | Complete |
| Grouping Alternatives | `spec-260126-group/alternatives-grouping.md` | Evaluated Explicit, Implicit, Hybrid grouping; chose Implicit flood-fill | Complete |
| Balance Analysis | `spec-260126-force/balance-analysis.md` | Formation strength vs flanking effectiveness tradeoffs; blob vs spread strategies | Complete |
| Historical Accuracy | `spec-260126-force/historical-accuracy.md` | Design choices mapped to historical phalanx tactics; shield wall, othismos, flanking | Complete |

---

## Implementation Planning

| Document | Path | Description | Status |
|----------|------|-------------|--------|
| Resolution Order | `spec-260126-combat/resolution-order.md` | Detailed 10-phase algorithm with state transitions and timing guarantees | Complete |
| Test Scenarios | `spec-260126-combat/test-scenarios.md` | 44 test cases: 12 movement, 12 formation, 15 combat, 5 integration | Complete |
| Design Decisions | `spec-260126-force/design-decisions-summary.md` | All design choices with rationale: base strength, bonus caps, tie-breaking rules | Complete |
| Implementation Guide | `spec-260126-engine/implementation-guide.ex` | Complete idiomatic Elixir code for hex utils, grouping, force calc, combat, engine | Complete |

---

## Supporting Systems

| Document | Path | Description | Status |
|----------|------|-------------|--------|
| State Machine | `spec-260126-engine/state-machine.md` | Game lifecycle: waiting/playing/finished states; turn phase transitions | Complete |
| Multiplayer Sync | `spec-260126-engine/multiplayer-sync.md` | Turn timer (30s default), order locking, PubSub broadcasts, disconnect handling | Complete |
| Database Schema | `spec-260126-engine/database-schema.md` | Optional persistence: players, games, turns, orders tables with Ecto schemas | Complete |
| Terrain System | `spec-260126-engine/terrain-system.md` | Terrain types (clear/impassable/rough/elevated); movement costs; LOS rules | Complete |
| Tutorial Design | `spec-260126-engine/tutorial-design.md` | 8 progressive lessons: movement, rotation, combat, formation, energy, tactics | Complete |
| AI Opponent | `spec-260126-engine/ai-opponent.md` | Four AI tiers: Scripted (tutorial), Reactive (easy), Tactical (medium), Strategic (hard) | Complete |
| Performance Analysis | `spec-260126-engine/performance-analysis.md` | O(u^2) worst case, O(u) typical; scales to 10K concurrent games per node | Complete |
| Overnight Summary | `OVERNIGHT-SUMMARY.md` | Catalog of 20 design documents with key decisions and open questions | Complete |
| Energy System | `energy-system.md` | Forward -1, backward 0, hold +1 (if not attacked); zero energy = -1 HP | Complete |
| Win Conditions | `spec-260126-engine/win-conditions.md` | Elimination, rout threshold, turn limit with scoring | Not Created |
| UX Feedback | `spec-260126-engine/ux-feedback.md` | Visual/audio feedback for actions, conflicts, damage | Not Created |
| Exploit Analysis | `spec-260126-engine/exploit-analysis.md` | Edge case exploits, degenerate strategies, balance concerns | Not Created |

---

## Project Files

| Document | Path | Description | Status |
|----------|------|-------------|--------|
| Player Rules | `/Users/sachinmeier/Projects/phalanx/RULES.md` | Complete player-facing rules: setup, orders, movement, combat, energy, victory | Complete |
| Dev Guide | `/Users/sachinmeier/Projects/phalanx/.claude/CLAUDE.md` | Build commands, architecture overview, module reference, keyboard controls | Complete |

---

## Summary

| Category | Total | Complete | Not Created |
|----------|-------|----------|-------------|
| Core Specs | 4 | 4 | 0 |
| Edge Case Analysis | 3 | 3 | 0 |
| Design Analysis | 6 | 6 | 0 |
| Implementation Planning | 4 | 4 | 0 |
| Supporting Systems | 12 | 9 | 3 |
| Project Files | 2 | 2 | 0 |
| **Total** | **31** | **28** | **3** |

---

## Open Work

Documents marked "Not Created" are referenced in specs but need authoring:

1. **Win Conditions** - Elimination rule exists; needs formal spec with alternatives
2. **UX Feedback** - No spec exists; needed for polish phase
3. **Exploit Analysis** - Deferred to playtesting phase
