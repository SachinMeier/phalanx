# Skills

Quick reference for all available skills.

## Directory Structure

```
skills/
├── debugging/
├── design/
├── effect/
├── file-format/
├── instructions/
├── observability/
├── prose/
├── linear-cli/              # Linear CLI management
├── linear-sync/             # Sync work progress with Linear
├── review-code-mh/
├── review-pr-description/
├── review-spec-mh/
├── spec-manager/
└── workflows-warrior-e2e/
```

## When to Use Which Skill

| Situation | Skill | Invocation |
|-----------|-------|------------|
| Implementing a Linear ticket | `workflows-warrior-e2e` | `/workflows-warrior-e2e TK-123` |
| Managing Linear issues/docs | `linear-cli` | `/linear-cli` |
| Syncing work to Linear | `linear-sync` | `/linear-sync` |
| Writing Effect-TS code | `effect` | Auto (via agents) |
| Debugging test failures | `debugging` | Auto (via debugger agent) |
| Creating PR description | `review-pr-description` | Auto (via workflow) |
| Reviewing code changes | `review-code-mh` | Auto (via code-reviewer agent) |
| Reviewing tech specs | `review-spec-mh` | Auto (via spec-reviewer agent) |
| Checking module structure | `file-format` | Auto (via format-checker agent) |
| Writing documentation | `prose` | Manual or via spec-reviewer |
| Adding observability | `observability` | Manual |
| UI design work | `design` | `/i-<command>` |
| Writing AI instructions | `instructions` | Manual |
| Managing spec creation | `spec-manager` | Manual |

## Skill → Agent Mapping

| Agent | Primary Skill(s) | Model |
|-------|------------------|-------|
| `code-reviewer` | review-code-mh | Sonnet |
| `spec-reviewer` | review-spec-mh, prose | Sonnet |
| `format-checker` | file-format | Haiku |
| `debugger` | debugging | Sonnet |
| `solution-reviewer` | — (raw reasoning) | Opus |

## Skill Descriptions

### Workflows

End-to-end orchestration skills that coordinate multiple phases and agents.

- **workflows-warrior-e2e**: Complete issue-to-PR pipeline with phases: INTAKE → DISCOVERY → PLANNING → IMPLEMENTATION → REVIEW → PR
- **spec-manager**: Orchestrates spec creation from work request to approved artifact

### Linear Integration

Skills for managing Linear issues, documents, and syncing work progress.

- **linear-cli**: Comprehensive Linear CLI for managing issues, documents, comments, projects, and teams
- **linear-sync**: Syncs work progress with Linear—updates status, adds comments, creates sub-issues

### Review

Quality gate skills for reviewing code, specs, and PRs.

- **review-code-mh**: Ruthless code review standards—security, correctness, patterns
- **review-spec-mh**: Tech spec review for clarity, completeness, precision
- **review-pr-description**: SCQA-format PR descriptions with concrete evidence

### *

Process, methodology, design skills, and coding standards.

- **debugging**: Four-phase debugging framework: investigate → analyze → hypothesize → implement
- **design**: 17-command system for design fluency (diagnostic, quality, intensity, adaptation, enhancement)
- **effect**: Comprehensive Effect-TS patterns (30KB+)—services, errors, testing
- **file-format**: Module section order and naming conventions
- **instructions**: Write AI instructions (skills, agents, prompts) that are token-efficient and reliably followed
- **observability**: OpenTelemetry tracing and instrumentation patterns
- **prose**: Writing standards—no AI tics, concrete language, active voice

## Auto-Invocation Rules

These skills are automatically loaded by agents or workflows:

| Trigger | Skill(s) Loaded |
|---------|-----------------|
| Running `warrior` | review-pr-description (in PR phase) |
| Spawning `code-reviewer` agent | review-code-mh |
| Spawning `spec-reviewer` agent | review-spec-mh, prose |
| Spawning `format-checker` agent | file-format |
| Spawning `debugger` agent | debugging |

## Adding New Skills

1. Create directory: `.claude/skills/{skill-name}/`
2. Add `SKILL.md` with frontmatter:
   ```yaml
   ---
   name: {skill-name}
   description: One-line description of what this skill does.
   user-invocable: true  # Optional: makes it available as /skill-name
   ---
   ```
3. Update this README.md
4. If skill is invoked by agents, update the agent definition's `skills` field
