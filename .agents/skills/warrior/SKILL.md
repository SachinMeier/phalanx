---
name: workflows-warrior-e2e
description: Solve issues end-to-end, from Linear ticket or written task to merged PR. Orchestrates planning, implementation, review, and finalization phases with appropriate skill invocations.
user-invocable: true
---

# Warrior E2E

Take an issue. Ship a PR.

## Architecture

This skill orchestrates work using a **hybrid approach**:
- **Main conversation**: Orchestration, user interaction, approvals
- **Subagents**: Heavy lifting (exploration, spec review, code review) — keeps verbose output isolated
- **Parallel execution**: Where possible, spawn multiple subagents concurrently

| Phase | Execution | Parallelism |
|-------|-----------|-------------|
| INTAKE | Main context (needs user input) | — |
| DISCOVERY | **Explore subagent** (fast search) | Can spawn multiple Explore agents |
| PLANNING | **spec-reviewer** + **solution-reviewer** agents | ✓ Run in parallel |
| IMPLEMENTATION | Main context (interactive coding) | — |
| REVIEW | **code-reviewer** + **format-checker** agents | ✓ Run in parallel |
| PR | Main context (needs user approval) | — |

### Custom Agents

| Agent | Skills Loaded | Model | Purpose |
|-------|---------------|-------|---------|
| `spec-reviewer` | `review-spec-mh`, `good-prose` | Sonnet | Review spec clarity/prose |
| `solution-reviewer` | — | Opus | Validate solution correctness/optimality |
| `code-reviewer` | `review-code-mh` | Sonnet | Review code changes |
| `format-checker` | `good-file-format` | Haiku | Verify section order |
| `debugger` | `good-debugging` | Sonnet | Find root cause of errors |

### Built-in Subagents

| Agent | Use Case |
|-------|----------|
| `Explore` | Fast codebase search (Haiku) |
| `Plan` | Research and planning |
| `general-purpose` | Flexible tasks |

> **Skills invoked in main context**: `review-pr-description`

## Input

| Format | Example |
|--------|---------|
| Linear ID | `/workflows-warrior-e2e TK-123` |
| Linear URL | `/workflows-warrior-e2e https://linear.app/toolkit/issue/TK-123` |
| Written task | `/workflows-warrior-e2e "Add pagination to /users endpoint"` |
| Autonomous | `/workflows-warrior-e2e TK-123 --auto` |
| Fully Autonomous | `/workflows-warrior-e2e TK-123 --fullyAuto` |

## State Machine

Always know which phase you're in. Always suggest next actions.

```
INTAKE → DISCOVERY → PLANNING → IMPLEMENTATION ⇄ REVIEW → PR
                                     └───────────┘
                                    (loop on violations)
```

**IMPORTANT**: On every phase transition, **re-read this skill file** to refresh the instructions for the new phase. Do not rely on memory — phases have specific actions and outputs that must be followed exactly.

---

## Phase 1: INTAKE

**Goal**: Understand the issue completely before touching code.

**Actions**:
1. **Workspace setup**: First, use `AskUserQuestion` to ask:
   How do you want to work on this issue?
2. Classify: `bug` | `feature` | `chore` | `refactor`

**Output**:
```
## Current Phase: INTAKE ✓

**Type**: [bug/feature/chore/refactor]
**Summary**: [one sentence]
**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2

**Next Actions**:
→ Confirm understanding is correct
→ Proceed to DISCOVERY
→ Ask clarifying questions
```

**Transition**:
- **Interactive**: User confirms → move to DISCOVERY
- **`--auto`**: Auto-proceed → move to DISCOVERY
- **`--fullyAuto`**: Auto-proceed → move to DISCOVERY

---

## Phase 2: DISCOVERY

**Goal**: Find all relevant code before planning.

**Actions**:
Use the `Task` tool with the built-in `Explore` subagent. It's fast (uses Haiku) and keeps verbose search output isolated.

```js
Task({
  subagent_type: "Explore",
  prompt: `
    Search the codebase for: [keywords from issue]

    Find:
    1. Primary files that need modification
    2. Sibling files in the same directory
    3. Existing tests for these files
    4. Related types/interfaces

    Return file paths with brief descriptions.
  `,
  description: "Explore codebase for issue"
})
```

Present the agent's findings to user.

**Output**:
```
## Current Phase: DISCOVERY ✓

**Primary Files** (to modify):
- `path/to/file.ts` — [what it does]

**Sibling Files** (for reference):
- `path/to/sibling.ts` — [related functionality]

**Related Types**:
- `path/to/types.ts` — [relevant interfaces]

**Existing Tests**: [path or "none found"]

**Next Actions**:
→ Explore additional areas (spawn another Explore subagent)
→ Proceed to PLANNING
→ Read specific file for more context
```

**Transition**:
- **Interactive**: User confirms sufficient context → move to PLANNING
- **`--auto`**: Auto-proceed when files found → move to PLANNING
- **`--fullyAuto`**: Auto-proceed when files found → move to PLANNING

---

## Phase 3: PLANNING

**Goal**: Design solution before writing code.

**Actions**:
1. Write implementation plan in spec format
2. Define tasks as checkbox list
3. Identify risks or unknowns
4. **Save tech spec to file**: `[YYYY-MM-DD] {Short Title}.md` in project root (do NOT commit/push)
   - Example: `[2026-01-14] CI Test Speedup: Vitest Sharding.md`
   - Use today's date and derive short title from issue title or task description
5. **Review tech spec in PARALLEL** (both agents at once):
   ```js
   // Launch BOTH agents in a single message
   Task({
     subagent_type: "spec-reviewer",
     prompt: `
       Review this tech spec: [path to spec file]
       Context: [issue summary]
     `,
     description: "Review spec clarity"
   })

   Task({
     subagent_type: "solution-reviewer",
     prompt: `
       Tech spec: [path to spec file]
       Problem: [issue description]
       Acceptance criteria: [from Linear issue]
       Codebase context: [relevant files from DISCOVERY]
     `,
     description: "Review solution"
   })
   ```
6. **Collect results**: Wait for both agents
   - `spec-reviewer`: checks clarity, prose, completeness
   - `solution-reviewer`: checks correctness, optimality, flaws
7. **Fix loop**: If either VERDICT is not APPROVED → fix issues → re-run BOTH in parallel
8. **Write tasks to TodoWrite** (if 2+ tasks)

**Output**:
```
## Current Phase: PLANNING ✓

### Problem
Casual: [user need]
Formal:
1. [technical gap]

### Solution
- [architectural component]

### Key Changes
- `path/to/file.ts` — add NewType interface
- `path/to/other.ts` — update handler

### Review Results (parallel)
| Agent | Verdict |
|-------|---------|
| spec-reviewer | APPROVED |
| solution-reviewer | APPROVED |

### Tasks
- [ ] Task 1
- [ ] Task 2

**Next Actions**:
→ Approve plan and proceed to IMPLEMENTATION
→ Modify plan
→ Ask about alternative approaches
```

**Transition**:
- **Interactive**: User approves plan → move to IMPLEMENTATION
- **`--auto`**: Auto-proceed after both reviews pass → move to IMPLEMENTATION
- **`--fullyAuto`**: Auto-proceed after both reviews pass → move to IMPLEMENTATION

---

## Phase 4: IMPLEMENTATION

**Goal**: Write code following codebase patterns.

**Actions**:
1. Complete tasks from plan one by one
2. **Update TodoWrite** as tasks complete (mark in_progress → completed)
3. Run type check after each change: `devbox run -- npm run check -w <pkg>`
4. Run lint: `devbox run -- npm run lint -w <pkg>`
5. Run tests if they exist: `devbox run -- npm test -w <pkg>`
6. On error → spawn debugger agent:
   ```js
   Task({
     subagent_type: "debugger",
     prompt: `
       Error: [error message]
       File: [file where error occurred]
       Context: [what was being implemented]
     `,
     description: "Debug error"
   })
   ```
   Apply the fix returned by debugger, then continue.

**Tests**: If no tests exist, do NOT create them unless explicitly requested.

**Output**:
```
## Current Phase: IMPLEMENTATION

**Progress**: [2/5 tasks complete]

**Current Task**: [task description]

**Completed**:
- [x] Task 1
- [x] Task 2

**Remaining**:
- [ ] Task 3
- [ ] Task 4
- [ ] Task 5

**Type Check**: [pass/fail]
**Lint**: [pass/fail]
**Tests**: [pass/fail/none]

**Next Actions**:
→ Continue with next task
→ Fix failing tests/types
→ Review completed work
→ Proceed to REVIEW (when all tasks done)
```

**On Error**:
```
## BLOCKED: [error type]

**Error**: [message]
**Root Cause**: [analysis]

**Next Actions**:
→ Apply fix: [specific fix]
→ Investigate further
→ Ask for help
```

**Transition**:
- **Interactive**: All tasks complete + checks pass → move to REVIEW
- **`--auto`**: All tasks complete + checks pass → move to REVIEW
- **`--fullyAuto`**: All tasks complete + checks pass → move to REVIEW

---

## Phase 5: REVIEW

**Goal**: Self-audit before committing.

**Actions**:
1. **Run reviews in PARALLEL** (both agents at once):
   ```js
   // Launch BOTH agents in a single message with multiple Task calls
   Task({
     subagent_type: "code-reviewer",
     prompt: `
       Review these changed files: [list]
       Context: [what was implemented]
     `,
     description: "Code review"
   })

   Task({
     subagent_type: "format-checker",
     prompt: `
       Check formatting of these files: [list]
       File types: [domain module / service / etc.]
     `,
     description: "Format check"
   })
   ```
2. **Collect results**: Wait for both agents to complete
3. **Fix loop**: If either VERDICT is not clean → fix issues → re-run BOTH agents in parallel
4. Run final checks: `devbox run -- npm run check && npm run lint && npm test`

**Output**:
```
## Current Phase: REVIEW ✓

**Files Changed**:
- `path/to/file.ts` — [summary]

**Review Results** (parallel):
| Agent | Verdict | Issues |
|-------|---------|--------|
| code-reviewer | CLEAN | 0 |
| format-checker | CORRECT | 0 |

**Review Iterations**: [n]
**Type/Lint/Tests**: pass

**Next Actions**:
→ Fix violations (back to loop)
→ Proceed to PR
```

**Transition**:
- **Interactive**: No violations + user confirms → move to PR
- **`--auto`**: No violations + checks pass → move to PR (But DO NOT commit or push, just provide the commit message and PR description)
- **`--fullyAuto`**: No violations + checks pass → move to PR

---

## Phase 6: PR

**Goal**: Create commit and pull request.

**Actions**:
1. **Tech spec cleanup** (FIRST, before drafting PR):
   - Find tech spec file: `[YYYY-MM-DD]*.md` in project root
   - Use `AskUserQuestion` (skipped in `--fullyAuto` → defaults to Delete):

   | Option | Action |
   |--------|--------|
   | **Delete** | Remove the tech spec file from disk |
   | **Keep** | Leave for local reference |
   | **Upload to Linear** | Create document via `linear document create -t "Title" -f ./spec.md`, link to issue |

   - If uploaded: save document URL to include in PR description

2. Draft commit message (Conventional Commits format)
3. **Invoke `pr-description` skill** to draft PR description in SCQA format
   - If tech spec was uploaded to Linear, include link in PR description
   - Include Linear issue ID (e.g., "Closes TK-123")
   - NO test plan section — the SCQA Answer section covers what changed
4. **ASK FOR APPROVAL** before committing (skipped in `--fullyAuto`)
5. Stage only files modified during IMPLEMENTATION, commit, push, create PR
6. **Update Linear**: `linear issue update TK-123 -s "In Review"` and add PR link via `linear issue comment add TK-123 -b "PR: [url]"`

**Important**:
- Do NOT add "Co-Authored-By: Claude" or "Generated with Claude Code" to commits or PR descriptions

**Output (before approval)**:
```
## Current Phase: PR

**Proposed Commit**: `feat(module): description`

**Proposed PR Description**:
[Use pr-description skill — SCQA format with concrete evidence from commits]

**Approval Required**:
→ Approve commit and PR description
→ Edit commit message
→ Edit PR description
```

**WAIT FOR USER APPROVAL BEFORE COMMITTING.**

**Output (after approval)**:
```
## COMPLETE ✓

**Issue**: TK-123 — [title]
**Commit**: `feat(module): description`
**PR**: https://github.com/org/repo/pull/456
**Linear**: TK-123 → In Review (PR linked)

**Changes**:
- `file.ts` — [summary]

**Follow-up** (if any):
- [future work identified]
```

---

## Force-Stop Conditions

Immediately stop and surface to user:

| Condition | Action | `--fullyAuto` |
|-----------|--------|---------------|
| Ambiguous requirements | Ask clarifying question | STOP (pre-flight) |
| 3 failed fix attempts | Escalate with analysis | STOP and Escalate with analysis |
| Architecture decision needed | Present options | STOP and Present options |
| Missing env/credentials | List what's needed | STOP and List what's needed |

---

## Modes

| Mode | Phases | Commit/PR | Use when |
|------|--------|-----------|----------|
| **Interactive** (default) | Pause at each | Approval required | Learning codebase, complex issues |
| **Autonomous** (`--auto`) | No pause | Approval required | Trusted flow, want review before commit |
| **Fully Autonomous** (`--fullyAuto`) | No pause | No approval | Well-defined issue, trust agent completely |

### `--fullyAuto` Behavior

- Executes entire pipeline: INTAKE → DISCOVERY → PLANNING → IMPLEMENTATION → REVIEW → PR
- Commits, pushes, creates PR, updates Linear — all without pausing
- Stops after **3 failed fix attempts** — needs human debugging
- On ANY force-stop condition: halts and surfaces to user with full context
- Always outputs final summary so user can review what was done
