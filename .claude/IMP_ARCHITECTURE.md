# IMP-1 Architecture

IMP-1 is a simple agent architecture to execute BROAD WORK REQUESTS with AUTONOMY and with CONSISTENT QUALITY. The architecture is (1) MALLEABLE to allow IMP-1 implementation for various types of work requests (2) MODULAR to allow for the combination of various IMP-1 implementations to execute even broader work requests autonomously and consistently.

> Note 1: For IMP-1 in practice see `spec` and `implementation`.
> Note 2: Thinking about IMP-2 architecture that uses the NCR of the inspector to allow the manager to issue Preventitive Actions (PAs) resulting in improvements to the agent documents themselves.

## Background

Current models and agentic harnesses solve most narrow tasks well. However, scaling them to solve broad tasks on a globally coherent level is an open challenge.

The reason is architectural. Context windows are finite and attention is not uniform. Models fixate on beginnings and endings while critical details in the middle slip away - context rot.

Yegge frames this as the diver problem: "Your context window is like an oxygen tank. You're sending a diver down into your codebase. One diver. Everyone says we'll just give him a bigger tank. But he's still going to run out of oxygen."

Several approaches have emerged to address this:

**Yegge's Gas Town** (January 2026) replaces the single diver with an ant swarm. A factory of specialized roles: Mayor orchestrates work distribution. Polecats spawn, execute tasks in isolated Git worktrees, and self-destruct. Witness monitors health. Deacon runs patrol loops. Refinery coordinates merges. Beads provides persistent memory stored in Git, surviving context exhaustion and session death.

**Huntley's Ralph Wiggum Loop** (July 2025) pursues radical simplicity. A bash loop feeds the same prompt to an agent repeatedly. Progress persists in files and Git history, not in context. Each iteration starts fresh. External verification through stop hooks determines completion rather than agent self-assessment.

**Hierarchical Manager-Worker patterns** (LangGraph, CrewAI, Microsoft Semantic Kernel) decompose objectives through supervisor agents that delegate to specialists.

Like Gas Town and Loop, IMP-1 is a coherent and closed framework. However, with Gas Town sitting left on the autonomy vs outcome consistency spectrum (not ready for creating production-grade software) and Loop sitting on the right (engineers need to be heavily involved, unable to run more than 1-2 sessions in parallel), IMP-1 explores if we can have our cake and eat it too.

## Overview

An IMP-1 implementation is a set of at least three agents. Every agent performs EXACTLY ONE role and every role must be performed by AT LEAST ONE agent. The three roles are:

1. **I**nspector    invoked by the manager to review an artifact
2. **M**anager      invoked by the user with a work request
3. **P**rincipal    invoked by the manager to produce or redo an artifact

The Manager role is special, because it MUST be performed by EXACTLY ONE agent. Inspector and Principal roles can be performed by one or more agents.

Broadly speaking the workflow looks like this. The user invokes via the Claude Code CLI the Manager agent with a broad, and most likely vague, work request. To fulfill the work requested, the Manager commissions work to the Principals (as subagents), assigns Inspectors (also as subagents) to review the Principal's work, and decides whether to accept, revise, or restart the process.

Crucially, IMP-1 solves context rot via **Run-Scoped Persistence**. State is not held in the chat window but in a dedicated directory on disk. Agents communicate via "Packets" (bounded context files) rather than raw conversation history.

```
                                  ┌──────┐
                                  │ User │
                                  └──┬───┘
                                     │▲ 
                        Work Request ││  Work Outcome
                                     ││
┌────────────────────────────────────││──────────────────────────────-┐
│  Claude Code CLI Session           ││                               │
│                                    ▼│                               │
│                             ┌─────────┐   Packet    ┌───────────┐   │  
│   ┌───────────┐   Packet    │         │────────────►│ Inspector │   │
│   │ Principal │◄────────────│ Manager │             │ (subagent)│   │
│   │ (subagent)│             │         │◄────────────│           │   │
│   └─────┬─────┘             └───▲──┬──┘     NCR     └─────┬─────┘   │
│         │ Artifact              │  │                      │         │
│         │ Manifest              │  │ Event Log            │         │
│         ▼                       │  ▼                      ▼         │
│   ┌─────────────────────────────────────────────────────────────┐   │
│   │                    Run State Directory                      │   │
│   │ (Filesystem: Artifacts, Manifests, NCRs, Packets, Events)   │   │
│   └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└────────────────────────────────────────────────────────────────────-┘
```

## The Three Roles

Principals and Inspectors are **agents** in `.claude/agents/`. Managers are **skills** in `.claude/skills/` because they must run in the main session to spawn subagents.

### File Locations

| Role | Location | Naming |
|------|----------|--------|
| Manager | `.claude/skills/{domain}-manager/SKILL.md` | Skill (main session) |
| Principal | `.claude/agents/{domain}-principal-{type}.md` | Agent (subagent) |
| Inspector | `.claude/agents/{domain}-inspector-{type}.md` | Agent (subagent) |

**Why Managers are Skills**: Claude Code subagents cannot spawn their own subagents. Since Managers must dispatch Principals and Inspectors via Task, they must run in the main session. Skills inject into the main session; agents run as subagents.

For example, for the `spec` IMP-1 implementation:

- `.claude/skills/spec-manager/SKILL.md` — Manager (skill)
- `.claude/agents/spec-principal-writer.md` — Principal (agent)
- `.claude/agents/spec-inspector-formatting.md` — Inspector (agent)
- `.claude/agents/spec-inspector-parsimonious.md` — Inspector (agent)
- `.claude/agents/spec-inspector-naming.md` — Inspector (agent)

**Invocation**: User starts session and calls `/spec-manager [work request]`.

### Principal

The Principals do the work. Whatever work must be performed for the IMP-1 domain, a Principal is the one that must perform it. A Principal may create, explore, delete - whatever is required. The core job is always to produce an Artifact though, not to orchestrate or critically assess work done by itself or other Principals.

Principals are always subagents and can therefore not spawn their own subagents; a deliberate Claude Code limitation. It is recommended to give Principal agents any skills they require.

Principals receive a **Task Packet** (markdown definition of the job) or a **Repair Packet** (aggregated NCRs) to avoid context pollution.

```typescript
interface Principal {
  invoke: (packetPath: string) => ArtifactManifest
}

interface ArtifactManifest {
  artifact_id: string
  kind: string         // e.g. "source_code", "markdown_doc"
  source: {
    type: "repo" | "generated"
    paths: string[]
    commit_hash: string
  }
}
```

### Inspector

The Inspector judges an artifact by creating a Non Conformance Report (NCR). The Inspector NEVER fixes the artifact. The Inspector ALWAYS returns a NCR back to the Manager. Like Principals, Inspectors are always subagents and can therefore not spawn their own subagents; a deliberate Claude Code limitation. It is recommended to give Inspectors any skills they require.

The tone and conduct of an Inspector is exacting and uncompromising. Untiring and fair judgment is applied to any artifact.

It is common that multiple types of Inspectors exist for the same artifact. One might check completeness. Another might check formatting. A third might check naming conventions. The Manager decides which Inspectors to commission and how to aggregate their NCRs.

Inspectors receive an **Inspection Packet**, which contains the location of the artifact (manifest) and the rubric/standards to apply.

```typescript
interface Inspector {
  invoke: (packetPath: string) => NonConformanceReport
}

interface NonConformanceReport {
  run_id: string
  artifact_fingerprint: string // Hash of content inspected to prevent version skew
  outcome: "Scrap" | "Repair" | "Pass"
  findings: NonConformance[]
}

interface NonConformance {
  location: string    // e.g. /path/to/file.ts:XX
  violation: string   // e.g. Reference to specific guideline
  detail: string      // Standalone description of violation for worker
  severity: "Critical" | "Major" | "Minor"
  positedCorrectiveAction: string // any hints as to what the fix will require
}
```

### Manager

The Manager orchestrates. It runs in the main Claude Code CLI session as a **skill** (not agent) and is the only component that spawns subagents. It is also the only role in any IMP-1 implementation that can never have more than one type.

Managers do not produce artifacts. They do not write code, draft documents, research solutions, or inspect a Principal's output. They manage the **Run State**.

**Prohibited Tools**: Managers must NEVER use `Read`, `Glob`, `Grep`, `Write`, `WebSearch`, or `Bash` directly. All work is delegated to Principals and Inspectors.

**Invocation**: `/spec-manager [work request]` at session start.

```typescript
interface Manager {
  invoke: (workRequest: string) => WorkOutcome
}

interface WorkOutcome {
  status: "Complete" | "Failed" | "Partial"
  deliverables: ArtifactManifest[]
  summary: string
}
```

A Manager's responsibilities:

1. **Intake**: Create run ID. Identify 2-4 clarifying questions. Spawn agents to research recommended answers. Present questions with recommendations to user. Collect confirmations/overrides.
2. **Dispatch**: Create bounded Packets (Task/Repair/Inspection). Invoke Principals/Inspectors pointing to these packets.
3. **Adjudicate**: Collect NCRs from Inspectors. Decide if "Repair" findings are valid. Merge multiple NCRs into a single "Repair Packet" for the Principal.
4. **Deliver**: When all commissioned artifacts are approved, return the Work Outcome to the User.

## Persistence and State Management

To satisfy the requirements of context isolation and multi-user safety in a shared monorepo, IMP-1 utilizes a **Run-Scoped Ledger** strategy.

### Directory Structure

State is stored **outside** the Git repository to prevent pollution and collision, using a hashed fingerprint of the repository to namespace runs.

```text
plans/                         # Plans directory (in repo)
  <run_id>/                    # e.g. spec-260120-1430
    spec.md                    # Primary artifact (for spec domain)
    manifest.json              # Artifact manifest
    ncr/                       # Inspector outputs
      formatting.json
      parsimonious.json
      naming.json
```

Note: Simplified structure for `spec` domain. Full structure with packets, events, etc. may be used for complex domains.

### The Packet Pattern (Context Sharing)

To solve the "Diver Problem," we never dump the full history into a subagent. We pass **Packets**.

1. **Task Packet**: A standalone Markdown file created by the Manager containing *only* the requirements for the specific task and links to necessary context files.
2. **Repair Packet**: A Markdown file containing the aggregated, deduplicated findings from the Inspectors. The Principal reads this file, not the Inspector's chat history.
3. **Rubric Packet**: A Markdown file containing the specific subset of `CLAUDE.md` or architectural guidelines relevant to the inspection.

### The Artifact Manifest (Memory)

Principals do not "return" code to the Manager. They commit code to the repository (or write to disk) and return a **Manifest**. This is a lightweight JSON pointer containing the Commit Hash and File Paths. This ensures the Manager knows *where* the state is without holding the code in its context window.

## Safety and Isolation

1. **Inspector Read-Only Enforcement**: Inspectors must be prevented from modifying artifacts. This is enforced via Claude Code **PreToolUse hooks**. If an Inspector attempts to use a write-tool on any path not inside `$IMP1_STATE_DIR/ncr/`, the hook rejects the action.
2. **Version Skew Prevention**: Every NCR must include an `artifact_fingerprint`. If the Principal updates the code (changing the hash) while an Inspector is running, the Manager detects the mismatch in the NCR and discards/retries the inspection.
