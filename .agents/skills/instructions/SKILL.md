---
name: good-instructions
description: Write AI instructions (skills, agents, prompts) that are token-efficient, human-scannable, and reliably followed. Use when authoring CLAUDE.md, agent definitions, or skill files.
---

# Good Instructions

Write instructions that AI follows reliably. Minimize tokens. Maximize clarity.

## When to Use

- Writing a new skill file
- Writing an agent definition
- Adding a section to CLAUDE.md
- Crafting a system prompt
- Reviewing existing instructions for clarity

## When NOT to Use

- Writing end-user documentation
- Writing code comments
- Prose content (use `good-prose` skill instead)

## Core Principles

| Principle | Meaning |
|-----------|---------|
| **Scannable** | Reader finds what they need in 3 seconds |
| **Imperative** | Commands, not suggestions |
| **Concrete** | Examples, not abstractions |
| **Structured** | Tables and lists, not paragraphs |
| **Complete** | No ambiguity about expected behavior |

## Document Structure

Every instruction document follows this skeleton:

```
---
name: [slug]
description: [one sentence - when to use this]
---

# Title

[One sentence purpose. No preamble.]

## When to Use
[Bullet list of triggers]

## When NOT to Use
[Bullet list of exclusions]

## Rules
[Numbered list - core constraints]

## Output Format
[Exact template the AI must produce]

## Examples
[WRONG vs CORRECT side-by-side]

## Checklist
[Verification before completion]
```

Omit sections that don't apply. Never pad.

---

## Writing Rules

### 1. One Sentence per Concept

```
WRONG:
"When you encounter an error during implementation, you should
carefully analyze it to understand the root cause before making
any changes to fix it."

CORRECT:
"On error: find root cause first, then fix."
```

### 2. Tables over Prose

```
WRONG:
"The agent can run in three modes. Interactive mode pauses at each
phase for user approval. Autonomous mode proceeds without pausing
but still requires approval before committing..."

CORRECT:
| Mode | Pauses | Commit Approval |
|------|--------|-----------------|
| Interactive | Each phase | Required |
| Autonomous | None | Required |
| FullyAuto | None | None |
```

### 3. Imperative Verbs

```
WRONG: "You might want to consider validating the input"
WRONG: "It would be good to check the types"
WRONG: "The system should ensure data integrity"

CORRECT: "Validate input at boundaries"
CORRECT: "Check types before processing"
CORRECT: "Parse external data via Schema"
```

### 4. WRONG/CORRECT Examples

Always show both. Side-by-side when possible.

```
// WRONG - vague
"Make sure to handle errors properly"

// CORRECT - specific
"Return errors in Effect's E channel. Never throw."
```

### 5. Explicit Output Templates

Don't say "return a summary." Show the exact format:

```
## Output Format

Return ONLY:

\`\`\`
## Summary
**Files**: [count]
**Issues**: [count]

### Critical
- `file:line` — [issue] → [fix]

---
VERDICT: [CLEAN | NEEDS_FIXES]
\`\`\`
```

### 6. Numbered Rules, Not Paragraphs

```
WRONG:
"The agent should follow the debugging methodology which
involves first observing the error, then forming a hypothesis,
then testing it, and finally applying a fix only after..."

CORRECT:
## Rules
1. Observe error (gather facts)
2. Form ONE hypothesis
3. Test hypothesis
4. Fix only after confirmation
```

### 7. Scope Boundaries

Always define when NOT to use:

```
## When NOT to Use
- Single-line typo fixes
- Pure research tasks (use Explore agent)
- User gave explicit detailed instructions
```

### 8. Force-Stop Conditions

For multi-step skills, define failure modes:

```
## Force-Stop Conditions

| Condition | Action |
|-----------|--------|
| 3 failed attempts | Escalate to user |
| Ambiguous requirements | Ask before proceeding |
| Missing credentials | List what's needed |
```

### 9. Phase Transitions

For stateful skills:

```
## State Machine

INTAKE → DISCOVERY → IMPLEMENTATION → REVIEW → PR

## Phase: INTAKE

**Goal**: [one sentence]

**Actions**:
1. [action]
2. [action]

**Output**: [template]

**Transition**: [condition] → [next phase]
```

### 10. Verdict/Checksum

End with clear success signal:

```
---
VERDICT: [PASS | FAIL | NEEDS_REVIEW]
```

Or a checklist:

```
## Checklist
- [ ] All rules applied
- [ ] Output matches template
- [ ] No prohibited patterns
```

---

## Anti-Patterns

### Padding
```
WRONG: "In order to ensure the best possible outcome..."
WRONG: "It's important to note that..."
WRONG: "As a general rule of thumb..."

CORRECT: [delete the sentence]
```

### Hedging
```
WRONG: "You might want to consider..."
WRONG: "It could be helpful to..."
WRONG: "One approach would be to..."

CORRECT: [imperative statement]
```

### Meta-Instructions
```
WRONG: "Remember to follow the guidelines below"
WRONG: "The following rules should be applied"
WRONG: "Please note the important points"

CORRECT: [just state the rules]
```

### Redundant Explanations
```
WRONG:
"Use tables (because tables are more scannable than prose and
allow the reader to quickly find information)"

CORRECT:
"Use tables"
```

### Vague Directives
```
WRONG: "Handle errors appropriately"
WRONG: "Follow best practices"
WRONG: "Ensure code quality"

CORRECT: "Return typed errors in E channel"
CORRECT: "Functions < 30 lines"
CORRECT: "No `as any` assertions"
```

---

## Agent Definition Template

Agents are ultra-minimal. ~50 lines max.

```yaml
---
name: [slug]
description: [one sentence]
tools: [Tool1, Tool2]
model: [sonnet | opus | haiku]
skills: [skill1, skill2]
---

# Agent Name

[One sentence purpose.]

## Input
- [what agent receives]

## Output Format
\`\`\`
[exact template]
\`\`\`

## Rules
1. [rule]
2. [rule]
3. [rule]
```

---

## Skill File Template

Skills can be longer but stay structured.

```yaml
---
name: [slug]
description: [one sentence - when to invoke]
---

# Skill Name

[One sentence purpose. What this skill does.]

## When to Use
- [trigger 1]
- [trigger 2]

## When NOT to Use
- [exclusion 1]
- [exclusion 2]

## Core Rules
1. [rule]
2. [rule]

## Output Format
[template]

## Examples

### WRONG
[bad example]

### CORRECT
[good example]

## Checklist
- [ ] [verification item]
```

### Skill Directory Structure

```
.claude/skills/{skill-name}/
├── SKILL.md (required)
├── scripts/     (optional)
├── references/  (optional)
└── assets/      (optional)
```

| Resource | Purpose | Example |
|----------|---------|---------|
| `scripts/` | Executable code (Python/Bash) | `scripts/rotate_pdf.py` |
| `references/` | Context docs (loaded on demand) | `references/schema.md` |
| `assets/` | Output templates, icons, fonts | `assets/template.html` |

### Skill Anti-Patterns

- README.md, CHANGELOG.md, or auxiliary docs in skill folder
- "When to use" in body (belongs in description only)
- Deeply nested references (keep one level from SKILL.md)
- Duplicate info in SKILL.md and references

---

## Checklist

Before finalizing any instruction document:

- [ ] Purpose clear in first sentence?
- [ ] When to use / NOT use defined?
- [ ] Rules numbered, not paragraphs?
- [ ] Output format is exact template?
- [ ] Examples show WRONG and CORRECT?
- [ ] No padding words (ultimately, importantly, etc.)?
- [ ] No meta-instructions (remember to, note that)?
- [ ] Tables used where comparison exists?
- [ ] Verdict/checksum at end?
- [ ] Under token budget?
