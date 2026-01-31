# Overnight Work Summary

**Date**: 2026-01-29
**Work Request**: Scan plans folder for inconsistencies, contradictions, and logical dilemmas across spec files

## Documents Created

| Document | Path | Summary |
|----------|------|---------|
| Inconsistencies Report | `plans/INCONSISTENCIES.md` | 27 categorized inconsistencies with sources and impact |

## Key Findings

### Critical (5 issues)
1. **Flanking mechanics** - 4 incompatible definitions (strength bonus vs damage only vs negate defender bonuses)
2. **Combined attacks** - 3 rules (forces add vs separate resolution vs 100ms window)
3. **Damage stacking** - 3 models (additive vs angle-only vs dislodge-only)
4. **Retreat determinism** - Spec says deterministic, code is random
5. **Rotation on balk** - Opposite behaviors defined

### High (4 issues)
1. **Formation bonus cap** - Same file says "no cap" AND defines `@max_bonus 4`
2. **Rear bonus cap** - Ranges from +1 (geometry) to unlimited depending on source
3. **Side neighbor count** - 2 vs 4 (fundamental hex geometry disagreement)
4. ~~**Phase numbering**~~ (resolved: 13 phases standardized)

### Medium (8 issues)
- ~~Energy type integer vs float for real-time~~ (resolved: real-time.md removed from scope)
- Rotation 0 maps to NW in one file, E in all others
- Two modules for strength calculation (Phalanx.Strength location)
- Group vs Phalanx struct naming
- Zero energy penalty: decided vs TBD
- ~~Support mechanic: exists vs doesn't~~ (resolved: Support + Formation are separate bonuses)
- ~~Formation bonus: requires same movement vs facing only~~ (resolved: phalanx membership, not movement)
- Game status values inconsistent
- Turn phase names don't match

### Lower (8 issues)
- ~~Terrain system signature change not propagated~~ (N/A: terrain is future work)
- Performance analysis uses old phase count
- Starting positions conflict between files
- Internal contradictions within single documents

## Analysis Method

Spawned 5 parallel sub-agents to analyze:
1. Combat domain (6 files)
2. Force domain (7 files)
3. Group domain (3 files)
4. Engine domain (9 files)
5. Standalone files (5 files)

Each agent read all files in its domain and identified contradictions with specific line citations.

## Recommended Next Steps

1. Review `plans/INCONSISTENCIES.md` for full details
2. Start with Critical issues - these block implementation
3. For each conflict, pick ONE authoritative source and update others
4. Consider marking one spec (e.g., `combat/spec.md`) as canonical
5. Run a follow-up pass after fixing Critical issues to check for cascading updates

## Open Questions

None - all analysis completed autonomously per overnight skill rules.
