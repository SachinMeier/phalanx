---
name: overnight
description: Long-running autonomous work session. Delegate to sub-agents, preserve context, maximize progress.
user-invocable: true
---

# Overnight

Run uninterrupted as long as needed to complete the task(s). Delegate everything to subagents. Write all relevant results, plans, etc. to markdown files. Return comprehensive results.

## When to Use

- User is going away (sleep, meeting, travel)
- Complex multi-faceted work request
- Deep exploration needed across many files/concepts
- Work benefits from parallel investigation

## When NOT to Use

- Quick tasks (< 30 min)
- User wants to stay involved
- Single focused implementation task

## Input Format

```
/overnight [work request]

Optional flags in request:
- "use /spec-manager" → invoke spec-manager for design work
- "use /warrior" → invoke warrior for implementation work
- "parallel" → spawn multiple exploration agents simultaneously
- "depth over breadth" → fewer topics, more detail each
- "breadth over depth" → more topics, less detail each
```

## Core Rules

1. **NEVER ask questions** — make reasonable decisions, document assumptions
2. **Delegate to sub-agents** — preserve main context for orchestration
3. **Create tasks immediately** — track all work via TaskCreate/TaskUpdate
4. **Produce artifacts** — every investigation yields a written document
5. **Summarize at end** — create OVERNIGHT-SUMMARY.md with all work

## Workflow

```
INITIALIZE → DECOMPOSE → EXECUTE → CONSOLIDATE → SUMMARIZE
```

### Phase: INITIALIZE

1. Create run directory: `plans/overnight-{YYMMDD}/`
2. Parse work request for:
   - Primary objective
   - Skill directives (/spec-manager, /warrior, etc.)
   - Parallelism preferences
3. Create initial task list via TaskCreate

### Phase: DECOMPOSE

Break work into independent workstreams. Each workstream becomes a sub-agent task.

| Work Type | Delegation Target |
|-----------|-------------------|
| Design/spec work | `/spec-manager` via Skill tool |
| Implementation | `/warrior` via Skill tool |
| Research/exploration | `Task` with `subagent_type: "Explore"` |
| Deep analysis | `Task` with `subagent_type: "general-purpose"` |
| Code review | `Task` with `subagent_type: "code-reviewer"` |

### Phase: EXECUTE

1. Launch sub-agents in parallel where independent
2. Track each via TaskUpdate (in_progress → completed)
3. Read sub-agent outputs and spawn follow-up agents as needed
4. Continue until:
   - All tasks complete, OR
   - Diminishing returns detected, OR
   - Critical blocker requiring user input

**Parallel Launch Pattern**:
```
// Single message with multiple Task calls
Task({ subagent_type: "Explore", prompt: "...", description: "Research A" })
Task({ subagent_type: "Explore", prompt: "...", description: "Research B" })
Task({ subagent_type: "general-purpose", prompt: "...", description: "Analyze C" })
```

### Phase: CONSOLIDATE

For each completed sub-agent:
1. Read output file/result
2. Extract key findings
3. Identify follow-up work
4. Update task status

### Phase: SUMMARIZE

Create `OVERNIGHT-SUMMARY.md` in run directory:

```markdown
# Overnight Work Summary

**Date**: {date}
**Duration**: {start} to {end}
**Work Request**: {original request}

## Documents Created

| Document | Path | Summary |
|----------|------|---------|
| ... | ... | ... |

## Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| ... | ... | ... |

## Open Questions

1. [question needing user input]

## Recommended Next Steps

1. [action item]
```

## Context Preservation Rules

| Action | Tool | Why |
|--------|------|-----|
| Research codebase | `Task` (Explore) | Keeps findings in sub-agent |
| Write specs | `Task` (spec-principal-writer) | Heavy lifting delegated |
| Deep analysis | `Task` (general-purpose) | Analysis stays in sub-agent |
| Track progress | `TaskCreate/Update` | Lightweight, stays in main |
| Read results | `Read` | Only summaries, not full exploration |

**Never do directly**:
- Large codebase searches (use Explore agent)
- Multi-file reading sessions (use general-purpose agent)
- Complex analysis (delegate and read summary)

## Output Format

At session end, ensure:

1. **Run directory** with all artifacts: `plans/overnight-{YYMMDD}/`
2. **OVERNIGHT-SUMMARY.md** in run directory
3. **Task list** showing all completed work
4. **Final message** to user with:
   - Document count
   - Key decisions summary
   - Open questions list
   - Recommended reading order

## Examples

### WRONG

```
User: /overnight Design a new combat system

Agent: [Reads 20 files directly]
Agent: [Writes analysis inline in conversation]
Agent: [Asks user "Should I continue?"]
Agent: [No summary document created]
```

### CORRECT

```
User: /overnight Design a new combat system

Agent: [Creates tasks for: force calc, grouping, combat resolution]
Agent: [Spawns 3 parallel spec-manager agents]
Agent: [Spawns 5 parallel Explore agents for edge cases]
Agent: [Reads summaries from completed agents]
Agent: [Spawns follow-up agents for gaps]
Agent: [Creates OVERNIGHT-SUMMARY.md]
Agent: "Created 15 documents. Key decisions: [list].
        Open questions: [list]. Start reading: spec.md"
```

## Force-Stop Conditions

| Condition | Action |
|-----------|--------|
| Critical ambiguity blocking all work | Document in summary, stop |
| Same error 3+ times | Document in summary, move to other tasks |
| All tasks complete | Proceed to summarize |
| No productive work possible | Summarize partial results |

## Checklist

Before declaring complete:

- [ ] All tasks marked completed or documented as blocked
- [ ] OVERNIGHT-SUMMARY.md created with all sections
- [ ] Every sub-agent output captured in a document
- [ ] Open questions clearly listed
- [ ] Next steps provided
- [ ] User can find all work via summary
