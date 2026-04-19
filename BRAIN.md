---
role: orchestrator
parent: null
triggers:
  - "brain"
  - "route"
  - "full checkup"
  - "ecosystem"
  - "scan project"
priority: 0
---

# BRAIN.md — MD Pipeline Orchestrator

<mission>
You are looking at an orchestration protocol, not a monolithic rulebook.
Each protocol file has one job. BRAIN routes between them based on intent.

The brain metaphor is a **mnemonic** for the architecture — not a claim
about cognition. The enforcement is implemented by real Claude Code
mechanisms (hooks, subagents, path-scoped rules), not by prompt assertion.
</mission>

## 🧠 File Map — One Job Each

| File | Job | Loaded by |
|---|---|---|
| **CLAUDE.md** | Project facts, constraints, user context | Claude Code auto-load (project root) |
| **BRAIN.md** | Routing between protocols (this file) | Referenced by CLAUDE.md bootstrap line |
| **CRAFT.md** | Structural refactor protocol + 20 anti-patterns | Delegated to `craft-specialist` subagent |
| **PERF.md** | Performance optimization + 20 perf anti-patterns | Delegated to `perf-specialist` subagent |
| **.claude/rules/craft-rules.md** | Path-scoped CRAFT enforcement | Auto-loaded on `src/**` file access |
| **.claude/rules/perf-rules.md** | Path-scoped PERF enforcement | Auto-loaded on `src/**` file access |
| **.claude/hooks/safety-net.sh** | PreToolUse mechanical Safety Net | Every Edit/Write/Bash tool call |
| **.claude/agents/*.md** | Tool-scoped subagents | Invoked via Agent tool or `@` mention |
| **.claude/commands/*.md** | Slash commands | `/brain-scan`, `/craft-audit`, `/perf-audit` |

## 🔀 Routing — Intent to Mechanism

| User intent | Mechanism | Entry point |
|---|---|---|
| "clean this up" / "refactor" | `craft-specialist` subagent | Agent tool, or `/craft-audit` |
| "make it faster" / "optimize" | `perf-specialist` subagent | Agent tool, or `/perf-audit` |
| "full project checkup" | `brain-router` subagent | Delegates sequentially |
| "scan the MD ecosystem" | `/brain-scan` command | Reports classification |
| Edit attempt on `legacy/`, `@craft-ignore`, `.craftignore`-matched path | Safety Net hook | Blocks / asks mechanically |

## 📋 MD Classification Rules

When you see a Markdown file in the project:

| Category | Detection | Handling |
|---|---|---|
| **Protocol** | BRAIN.md, CRAFT.md, PERF.md | Active, executable |
| **Memory** | CLAUDE.md, `memory/**/*.md` | Read-only, always in context |
| **Legacy** | Everything else (README, CHANGELOG, docs/*, ARCHITECTURE, SPEC) | Read-only, acknowledge + cite, **never modify** |
| **Generated** | `*.pb.md`, `*.generated.md`, files declared generated | Ignored |

## ⚖ Priority — When Things Conflict

Higher wins. These are suggested resolution orders, enforced where possible by hooks:

1. **Safety Net hooks** (deterministic, mechanical) — can deny or require confirmation
2. **CLAUDE.md constraints** (project law) — "never touch legacy/"
3. **User's current request** (session intent)
4. **Protocol recommendations** (CRAFT anti-patterns, PERF transformations)
5. **Legacy MD guidance** (read-only context)

Example resolution: user asks "refactor src/legacy/api.ts". Hook denies (rule 1). CLAUDE.md forbids legacy (rule 2). Response: "blocked by Safety Net; legacy/ is protected per CLAUDE.md".

## 🎯 When Invoked

If the user types `BRAIN` or asks for a project-wide operation:

1. Read `CLAUDE.md` (should already be in context — confirm).
2. Run `/brain-scan` equivalent: classify every MD file (Protocol / Memory / Legacy / Generated).
3. Report the ecosystem map. Flag conflicts.
4. If the request is compound ("clean and optimize"), sequence: `craft-specialist` first, then `perf-specialist` with fresh baseline.
5. If ambiguous, ask — do not guess.

## 🛡 Safety Net — Implementation vs Intention

This is the honest explanation. The Safety Net has two parts:

**Mechanical (enforceable)**:
- `.claude/hooks/safety-net.sh` (PreToolUse) — blocks edits to protected paths, `@craft-ignore` / `@perf-optimized` files, and destructive commands in `legacy/` / `generated/`. Runs outside the LLM.
- `.claude/settings.json` permissions `deny` / `ask` lists — hard-blocks Edits in `legacy/`, `generated/`, `vendor/`.
- Subagent `tools` allowlists — `perf-specialist` cannot `Write` new files because the tool isn't in its scope.

**Behavioral (prompt-guided, not guaranteed)**:
- Confidence grading (🟢 / 🟡 / 🔴) — heuristic that biases toward caution
- Pre-action 4-question self-check — scaffold for chain-of-thought
- False-positive catalog matching — reduces over-refactoring

Mechanical layers always work. Behavioral layers improve most sessions but cannot be guaranteed. This is a tool, not magic.

## 🔬 Self-check — Is BRAIN Active?

Run `/brain-scan` — if output includes the expected ecosystem map plus Safety Net status, BRAIN is working. If the command isn't recognized, the `.claude/commands/` directory wasn't installed.

Run a harmless test: ask to edit a file in `legacy/`. The Safety Net hook should intercept. If it doesn't, `.claude/settings.json` isn't wiring the hook.

## 🧭 North Star

> Every behavioral claim is backed by a real mechanism (hook, subagent, rule, permission) — or it's marked as a heuristic, not a guarantee.
>
> The brain metaphor is a mnemonic for humans. The enforcement is for the machine.

End.
