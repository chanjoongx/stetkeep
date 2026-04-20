# ARCHITECTURE.md — How stetkeep Actually Works

> Technical reference. Every claim in this document is backed by a real
> Claude Code mechanism: hooks, subagents, path-scoped rules, permissions,
> slash commands. The brain metaphor is a mnemonic; this doc is the truth.

---

## 1. Enforcement Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                  What the user asks for                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ LAYER A — Permissions (settings.json, deterministic)            │
│   • deny: [Edit(legacy/**), Edit(generated/**), ...]            │
│   • ask:  [Bash(rm -rf *), Edit(**/.env*), ...]                 │
│   • Applied by Claude Code before any tool call                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ LAYER B — PreToolUse Hook (out-of-process, mechanical)          │
│   • .claude/hooks/safety-net.sh                                 │
│   • Runs before every Edit / Write / Bash                       │
│   • Can deny, ask, or allow — returns JSON decision             │
│   • Checks: .craftignore, .perfignore, @markers, protected dirs │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ LAYER C — Subagent Tool Scoping (structural)                    │
│   • craft-specialist: tools [Read, Grep, Glob, Edit, Bash]      │
│     — NO Write tool → cannot create new files                   │
│   • perf-specialist: tools [Read, Grep, Glob, Bash, Edit]       │
│     — NO Write → measurement-first; cannot bypass               │
│   • Enforced by Claude Code at subagent spawn                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ LAYER D — Path-scoped Rules (auto-loaded context)               │
│   • .claude/rules/craft-rules.md   paths: src/**, lib/**        │
│   • .claude/rules/perf-rules.md    paths: src/**, config files  │
│   • Loaded when Claude reads matching files — not always        │
│   • Behavioral: heuristic guidance, not hard enforcement        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ LAYER E — Protocol Files (behavioral, prompt-level)             │
│   • CRAFT.md / PERF.md — XML-structured directives              │
│   • False-positive catalogs                                     │
│   • Confidence grading (heuristic)                              │
│   • Pre-action self-checks (scaffold for CoT)                   │
└─────────────────────────────────────────────────────────────────┘
```

**Deterministic enforcement**: Layers A, B, C. These always fire, regardless of model attention.
**Heuristic guidance**: Layers D, E. These bias model behavior toward caution.

*Effect size on false-positive reduction is not yet measured. The methodology is in [`benchmark/SPEC.md`](benchmark/SPEC.md); results will be published before any headline claim is made. No current number exists for this.*

---

## 2. Signal Flow (Concrete)

```
User: "clean up src/components/"

  ┌──▶  Claude Code auto-loads:
  │      - CLAUDE.md  (project facts)
  │      - memory/MEMORY.md + links  (if auto-memory enabled)
  │
  ├──▶  User types command; Claude plans
  │     → Decides to Read files in src/components/
  │
  ├──▶  On Read src/components/Foo.tsx:
  │      - .claude/rules/craft-rules.md AUTO-LOADS (paths: src/**)
  │      - .claude/rules/perf-rules.md AUTO-LOADS (paths: src/**)
  │     Context now includes Safety Net rules
  │
  ├──▶  Claude evaluates: task is "clean up" → matches craft-specialist description
  │     → Delegates via Agent tool to craft-specialist
  │
  ├──▶  craft-specialist subagent spawns with:
  │      - tools allowlist: Read, Grep, Glob, Edit, Bash  (no Write)
  │      - inherits relevant CLAUDE.md context
  │      - reads CRAFT.md per its system prompt
  │
  ├──▶  craft-specialist runs CRAFT.md P0 audit
  │     Returns: Top N anti-patterns + confidence grades + plan
  │     Waits for user approval
  │
  ├──▶  User approves. craft-specialist calls Edit.
  │     Before the tool executes:
  │      ┌──────────────────────────────────────┐
  │      │ PreToolUse HOOK fires                 │
  │      │ safety-net.sh reads tool_input         │
  │      │ Checks: path, markers, ignore files   │
  │      │ Returns JSON: allow | ask | deny     │
  │      └──────────────────────────────────────┘
  │     If allow → edit proceeds
  │     If ask → user confirmation required
  │     If deny → Claude Code cancels the tool call
  │
  └──▶  Edit succeeds. Loop.
```

---

## 3. File Layout

*Shown as it appears in a **user project after `npx stetkeep install`**. Plugin-marketplace installs register agents/commands/hooks from Claude Code's own plugin directory and do not populate this tree.*

```
project-root/
├── CLAUDE.md                       # Layer E (auto-loaded)
├── BRAIN.md                        # Layer E (referenced by CLAUDE.md)
├── CRAFT.md                        # Layer E (invoked by craft-specialist)
├── PERF.md                         # Layer E (invoked by perf-specialist)
│
├── .craftignore                    # Layer B (read by hook)
├── .perfignore                     # Layer B (read by hook)
│
└── .claude/
    ├── settings.example.json       # template (always present after install)
    ├── settings.json               # Layer A + B (user creates via `cp settings.example.json settings.json`)
    │
    ├── agents/                     # Layer C (tool-scoped subagents)
    │   ├── brain-router.md
    │   ├── craft-specialist.md
    │   └── perf-specialist.md
    │
    ├── hooks/                      # Layer B (mechanical enforcement)
    │   ├── safety-net.sh           # bash (macOS/Linux/Git Bash)
    │   └── safety-net.ps1          # PowerShell (Windows)
    │
    ├── rules/                      # Layer D (path-scoped auto-load)
    │   ├── craft-rules.md          # paths: src/**, lib/**, app/**
    │   └── perf-rules.md           # paths: src/**, next.config.*, vite.config.*
    │
    └── commands/                   # user-facing
        ├── brain-scan.md           # /brain-scan
        ├── craft-audit.md          # /craft-audit
        └── perf-audit.md           # /perf-audit
```

---

## 4. Why This Shape

| Decision | Reason |
|---|---|
| **Subagents with restricted tool lists** | Structural enforcement — perf-specialist *cannot* write new files because Write is not in its scope. Not a rule; a missing capability. |
| **PreToolUse hook for Safety Net** | Out-of-process enforcement — runs regardless of LLM attention. Hook's decision is final unless model retries with different input. |
| **Path-scoped rules** | Token efficient — CRAFT rules only load when Claude is actually editing code, not during doc work. Uses native Claude Code 2026 mechanism. |
| **Slash commands over magic phrases** | Discoverable (tab-complete), versionable, testable. Replaces "type this exact sentence" pattern. |
| **Permissions `deny` list** | Hard backstop if the hook has a bug. Defense in depth. |
| **XML tags in CRAFT/PERF** | [Anthropic's prompting guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags) explicitly recommends XML tags for prompt structuring: "XML tags can be a game-changer... they help Claude parse your prompts more accurately." Models attend to XML-delimited directive blocks more reliably than emoji-prefixed Markdown headers. |
| **False-positive catalogs preserved verbatim** | The single most behaviorally-effective content in the repo per multiple reviews. Kept as lookup tables. |

---

## 5. Priority Resolution Example

**Scenario**: User asks "refactor src/legacy/auth.ts"

```
1. Permissions.deny matches "Edit(legacy/**)"
   → Claude Code blocks before any tool call
   → Claude responds: "That path is denied by .claude/settings.json.
      Would you like me to propose changes in a review doc instead?"

No hook runs. No subagent spawns. Deterministic refusal.
```

**Scenario**: User asks "refactor src/utils/date.ts" (inside CRAFT scope)

```
1. Permissions: no match, passes
2. Claude reads src/utils/date.ts → triggers craft-rules.md auto-load
3. Claude delegates to craft-specialist
4. craft-specialist proposes 3 anti-pattern fixes, waits for approval
5. User approves Fix #1 (A1 God File, split)
6. craft-specialist calls Edit
7. PreToolUse hook fires, checks:
   - Path in .craftignore? No
   - File starts with @craft-ignore? No
   - In legacy/generated/vendor? No
   → "allow"
8. Edit succeeds
9. Loop for Fix #2 and #3 (one per turn, per CRAFT execution rule)
```

---

## 6. Installation → Operation

```
  bash install.sh
      │
      ├─▶ copy BRAIN.md, CRAFT.md, PERF.md to project root
      ├─▶ copy .claude/ directory (agents, hooks, rules, commands, settings.example.json)
      ├─▶ copy .craftignore, .perfignore
      ├─▶ if no CLAUDE.md: create from template
      │   else (coexist mode): append protocol bootstrap line to existing CLAUDE.md
      └─▶ prompt user to: cp .claude/settings.example.json .claude/settings.json

  cd project
  claude
      │
      ├─▶ Claude Code starts session
      ├─▶ auto-loads CLAUDE.md (which references BRAIN/CRAFT/PERF via bootstrap line)
      ├─▶ registers subagents from .claude/agents/
      ├─▶ registers slash commands from .claude/commands/
      ├─▶ wires hooks from .claude/settings.json
      └─▶ ready
```

---

## 7. Validation — How to Verify Claims

Run these after installation:

```bash
# 1. Hook executes correctly
echo '{"tool_name":"Edit","tool_input":{"file_path":"legacy/x.ts"}}' \
  | bash .claude/hooks/safety-net.sh
# Expected: {"hookSpecificOutput":{"permissionDecision":"ask","permissionDecisionReason":"..."}}

# 2. Subagent discovery
ls .claude/agents/
# Expected: brain-router.md, craft-specialist.md, perf-specialist.md

# 3. Commands registered
ls .claude/commands/
# Expected: brain-scan.md, craft-audit.md, perf-audit.md

# 4. Path-scoped rules
cat .claude/rules/craft-rules.md | head -5
# Expected: frontmatter with `paths: [...]`

# 5. Permissions wired
jq '.permissions.deny' .claude/settings.json
# Expected: array containing "Edit(legacy/**)" etc.
```

If any of these fail, the corresponding enforcement layer is not active.

---

## 8. What This Is NOT

Being honest about scope:

- **Not a cognitive architecture.** MD files are documents read by a language model. The brain metaphor is pedagogy.
- **Not a guarantee against AI over-refactoring.** Layers A, B, C reliably block specific actions. Layers D, E *bias* behavior but cannot guarantee it.
- **Not an Anthropic product.** Independent open-source project built on Claude Code's public extension mechanisms.
- **Not a replacement for code review.** It's an additional filter.
- **Not measured yet.** The `benchmark/SPEC.md` exists; runs are pending. Do not cite effectiveness numbers until the benchmark has been executed.

---

## 9. Dependencies

- **Claude Code 2026** (hooks, subagents, path-scoped rules require this)
- **bash 4+** (for `.sh` hook; fallback to `.ps1` on Windows)
- **jq** (for JSON parsing inside the hook; install via `apt`/`brew`/`choco`)

---

## 10. Related Work & Prior Art

stetkeep builds on or relates to the following literature. The project does not claim novelty in the concepts below — only in assembling them into a practitioner-ready extension.

**LLM orchestration & rule systems**:
- **Constitutional AI** (Bai et al., 2022, *arXiv:2212.08073*) — principle-driven self-critique. Closest prior art for the rule-bound behavior stetkeep's protocols encode.
- **Mixture-of-Experts gating** (Shazeer et al., 2017, *ICLR*) — learned routing between specialists. stetkeep uses keyword-triggered subagent delegation instead; acknowledged as a simpler but shallower mechanism.
- **LLM-Blender / RouteLLM** (Jiang et al., 2023; Ong et al., 2024) — query-routing across models. stetkeep routes across *prompts within one model*, not across models.
- **Anthropic's Claude Code extension surface (2026)** — hooks, subagents, path-scoped rules. stetkeep composes these; it does not reimplement them.

**Cognitive architecture references (for the mnemonic)**:
- **Miller & Cohen (2001)**, *An Integrative Theory of Prefrontal Cortex Function* (Annu. Rev. Neurosci.) — task-set selection and conflict monitoring. Loosely inspires the BRAIN routing framing.
- **McClelland, McNaughton & O'Reilly (1995)**, Complementary Learning Systems — fast episodic + slow semantic memory. Better fit for the "session memory vs. project facts" distinction than any single-region analogy.
- **Badre (2008)**, rostro-caudal PFC hierarchy — informs the priority-levels framing.

Where stetkeep's naming invokes anatomical terms (e.g., "BRAIN as orchestrator"), it does so as mnemonic pedagogy. The engineering is implemented against the Claude Code 2026 extension surface, not against a cognitive model.

---

## 11. Further Reading

- [`BRAIN.md`](BRAIN.md) — orchestration logic
- [`CRAFT.md`](CRAFT.md) — refactor protocol
- [`PERF.md`](PERF.md) — performance protocol
- [`BOOTSTRAP_GUIDE.md`](BOOTSTRAP_GUIDE.md) — first-session walkthrough
- [`benchmark/SPEC.md`](benchmark/SPEC.md) — evaluation methodology
- [`.claude/settings.example.json`](.claude/settings.example.json) — hook wiring reference
