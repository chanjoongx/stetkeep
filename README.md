<div align="center">

```
███╗   ███╗██████╗ ██████╗ ██████╗  █████╗ ██╗███╗   ██╗
████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║
██╔████╔██║██║  ██║██████╔╝██████╔╝███████║██║██╔██╗ ██║
██║╚██╔╝██║██║  ██║██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║
██║ ╚═╝ ██║██████╔╝██████╔╝██║  ██║██║  ██║██║██║ ╚████║
╚═╝     ╚═╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
```

### *A native Claude Code extension with mechanical guardrails against false-positive refactors.*

**Hook-enforced Safety Net. Tool-scoped subagents. Path-scoped rules. Slash commands.**
**Built on Claude Code's 2026 extension mechanisms — not prompt assertion.**

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=18&duration=3500&pause=900&color=A78BFA&center=true&vCenter=true&width=760&lines=Hook-enforced+Safety+Net;Tool-scoped+subagents;Path-scoped+rules;False-positive+catalogs+that+actually+work)](https://git.io/typing-svg)

[![License: MIT](https://img.shields.io/badge/License-MIT-A78BFA.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Built%20for-Claude%20Code-D4A27F)](https://claude.com/claude-code)
[![Version](https://img.shields.io/badge/version-v0.2.1-5FE5D4)](CHANGELOG.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-7AB7FC)](CONTRIBUTING.md)

</div>

---

## ⚡ 30-Second Pitch

Claude Code is powerful. It's also enthusiastic — it will happily "refactor" your intentional design choices into generic patterns, `useMemo` a component without measuring, or delete a `*.pb.ts` file it thinks is dead.

**mdbrain adds mechanical guardrails on top of Claude Code's native 2026 extension APIs:**

- **PreToolUse hook** (out-of-process bash/PowerShell) blocks edits to `legacy/`, `@perf-hot-path`, `.craftignore`-matched paths — regardless of what the model decides
- **Tool-scoped subagents** — `perf-specialist` physically cannot create new files (no Write in its allowlist)
- **Path-scoped rules** auto-load CRAFT/PERF guidance only when Claude is editing code, not during doc work
- **Permissions `deny` list** as a hard backstop
- **False-positive catalog** of 16 cases the model commonly misjudges (1000-line config, deliberate inline loops, V8 JIT optimizations, etc.)

Five layers of defense against the AI's over-eagerness. The first three are deterministic; the last two are prompting heuristics.

---

## 🧠 The Idea in One Picture

```
                 ┌──────────────────────────┐
  user command ─▶│     Claude Code          │
                 │  (reads CLAUDE.md auto)  │
                 └───────────┬──────────────┘
                             │
               ┌─────────────┴─────────────┐
               ▼                           ▼
   ┌────────────────────┐    ┌──────────────────────┐
   │ Subagents          │    │ Path-scoped rules    │
   │ .claude/agents/    │    │ .claude/rules/       │
   │ — tool-scoped      │    │ — auto-load on read  │
   └──────────┬─────────┘    └──────────┬───────────┘
              │                          │
              └──────────────┬───────────┘
                             ▼
                  ┌──────────────────────┐
                  │  Edit / Write tool   │
                  └──────────┬───────────┘
                             │
                 ┌───────────▼────────────┐
                 │ PreToolUse HOOK        │  ◀── Safety Net (mechanical)
                 │ .claude/hooks/         │     runs out-of-process
                 │ checks: ignore files,  │     can deny / ask / allow
                 │ markers, protected dirs│
                 └───────────┬────────────┘
                             │
                        allow│deny/ask
                             ▼
                    ┌──────────────┐
                    │   file edit  │
                    └──────────────┘
```

---

## 📦 Requirements

- **Claude Code 2026** or later — this project uses the 2026 extension surface (hooks, subagents, path-scoped rules, slash commands). Older versions will fall back to prompt-level behavior only (Layer D/E); mechanical enforcement (Layers A/B/C) requires 2026+.
- **Shell**:
  - macOS / Linux: bash 4+ (default)
  - Windows: Git Bash (bundled with Git for Windows — what most Claude Code Windows users already have), or native PowerShell 5.1+
- **Optional**: `jq` — the hook uses it if present, falls back to grep-based JSON parsing if absent.

---

## 🚀 Install

### Clone + install

```bash
# 1. Clone this repo anywhere
git clone https://github.com/chanjoongx/mdbrain.git

# 2. Run the installer from your project folder
cd /path/to/your-project

# macOS / Linux / Git Bash
bash /path/to/mdbrain/install.sh

# Windows PowerShell
powershell -File C:\path\to\mdbrain\install.ps1
```

### What the installer does

1. Copies `BRAIN.md`, `CRAFT.md`, `PERF.md` to your project root
2. Copies `.claude/` directory (agents, hooks, rules, commands, settings.example.json)
3. Creates `.craftignore` and `.perfignore` if missing
4. Adds a bootstrap line to your existing `CLAUDE.md` (or creates one from template)
5. Reminds you to `cp .claude/settings.example.json .claude/settings.json`

### Install modes

| Mode | When |
|---|---|
| `coexist` (default) | Existing project with `CLAUDE.md` / `memory/` — preserves everything |
| `merge` | Appends a Protocol section to existing `CLAUDE.md` |
| `fresh` | Empty project |

Run `bash install.sh --dry-run` to simulate without changes.

---

## 📋 After Install — First Command

```
/brain-scan
```

That's it. `/brain-scan` is a slash command defined in `.claude/commands/brain-scan.md` — it reads `BRAIN.md`, classifies every MD file, reports the ecosystem map, and suggests next steps.

Natural language afterward:
```
"clean up src/components/"    →  delegates to craft-specialist
"make this faster"            →  delegates to perf-specialist (with measurement gate)
"full project checkup"        →  brain-router sequences both
```

The Safety Net hook is active from the moment you type — regardless of what you say.

---

## 🛡 The Safety Net — What Makes It Different

Most AI coding tools have rules. mdbrain has **enforcement**:

### Deterministic layers (always fire)

**Permissions deny list** (`.claude/settings.json`):
```json
"deny": [
  "Edit(legacy/**)",
  "Edit(generated/**)",
  "Edit(vendor/**)",
  "Edit(.env*)"
]
```
Claude Code blocks these before any tool call. No model involvement.

**PreToolUse hook** (`.claude/hooks/safety-net.sh`):
```bash
# Runs on every Edit/Write/Bash. Returns JSON: allow/ask/deny.
# Checks: .craftignore patterns, @craft-ignore / @perf-optimized markers,
# protected paths, destructive Bash commands in sensitive dirs.
```
Runs in a separate process. Hook's decision is final.

**Subagent tool scoping** (`.claude/agents/perf-specialist.md`):
```yaml
tools: Read, Grep, Glob, Bash, Edit     # note: NO Write
```
perf-specialist physically cannot create new files. Not a rule — a missing capability.

### Heuristic layers (bias behavior)

- **Path-scoped rules** auto-load CRAFT/PERF guidance on `src/**` access
- **Confidence grading** (🟢 / 🟡 / 🔴) biases toward caution
- **False-positive catalog** — 16 cases the model commonly misjudges

---

## 🎯 Verify It Works

After install:

```bash
# 1. Hook runs and returns deny
echo '{"tool_name":"Edit","tool_input":{"file_path":"legacy/x.ts"}}' \
  | bash .claude/hooks/safety-net.sh

# Expected output (JSON):
# {"hookSpecificOutput":{"permissionDecision":"ask", ...}}

# 2. Subagents discovered
ls .claude/agents/
# craft-specialist.md  perf-specialist.md  brain-router.md

# 3. Commands registered (after restarting claude)
# In Claude Code CLI, type `/` and you should see /brain-scan, /craft-audit, /perf-audit
```

If any of these fail, the corresponding enforcement layer is not active.

---

## 🔧 Troubleshooting

### Hook doesn't seem to do anything
Run the test invocation from "Verify It Works". If it returns no JSON:
- On macOS/Linux: check `bash .claude/hooks/safety-net.sh` is executable (`chmod +x`)
- On Windows: verify Git Bash is installed, or switch to the PowerShell hook (see below)
- If output shows but decisions are wrong: confirm `.craftignore` / `.perfignore` patterns match your project layout

### Windows native PowerShell (no Git Bash)
The shipped `.claude/settings.example.json` uses a bash hook by default. For pure PowerShell:
1. Copy `settings.example.json` → `settings.json`
2. Change the hook `command` to:
   ```json
   "command": "powershell -File $CLAUDE_PROJECT_DIR/.claude/hooks/safety-net.ps1"
   ```
3. Use `validators/validate-protocol.ps1` (we ship both `.sh` and `.ps1` validators).

### Slash commands not appearing (`/brain-scan` unknown)
Claude Code scans `.claude/commands/` at session start. If you added files mid-session, quit and restart `claude`. Commands also require Claude Code 2026+.

### Subagents not being delegated to
Claude decides delegation based on the subagent's `description` field. Make your user command match the description vocabulary ("refactor", "optimize", "audit"). You can also invoke explicitly with `@craft-specialist ...`.

### Hooks fail silently (fail-open behavior)
By design, a broken hook doesn't block Claude (fail-open for usability). This means a hook bug can silently disable the Safety Net. Run the test in "Verify It Works" after any edit to hook files.

### I installed but `/brain-scan` does nothing
Check: (a) Claude Code version 2026+, (b) `.claude/commands/brain-scan.md` exists, (c) you ran `claude` AFTER installing (session needs restart to pick up new commands).

---

## ⚖ vs. Alternatives

| | **mdbrain** | `.cursorrules` | Plain CLAUDE.md | Custom prompts |
|---|---|---|---|---|
| Hook-enforced Safety Net | ✅ Mechanical | ❌ | ❌ | ❌ |
| Tool-scoped subagents | ✅ Native 2026 API | ❌ | ❌ | ❌ |
| Path-scoped rules | ✅ Auto-load on file access | ❌ | ❌ | ❌ |
| Permissions deny list | ✅ Deterministic | ❌ | ❌ | ❌ |
| False-positive catalog | ✅ 16 cases | ⚠ project-specific | ⚠ mentions | ⚠ |
| Coexist-with-existing | ✅ 3 install modes | N/A | N/A | N/A |
| Token cost (full load) | ~7-9K | ~1-2K | 1-5K | varies |

mdbrain is heavier than `.cursorrules` but the weight buys mechanical enforcement. For single-file solo projects, `.cursorrules` is probably enough. For multi-file projects with legacy zones, generated code, or measured performance requirements, the guardrails matter.

---

## 🧪 Benchmark

The classic open-source "our tool improves X by N%" claim is unfalsifiable without a benchmark. Rather than ship a number we can't defend, we published the **evaluation methodology first**:

📄 [`benchmark/SPEC.md`](benchmark/SPEC.md) — full spec:
- **50 test cases**: 40% true anti-patterns, 40% false-positive lookalikes (adversarial), 20% ambiguous
- **3 conditions**: vanilla Claude Code / mdbrain full / mdbrain Safety-Net-only
- **Metrics**: precision, recall, F1, harm score (0-3 severity), consultation rate
- **Protocol**: human rubric grading (2 blinded + tiebreaker), Cohen's κ ≥ 0.75, paired bootstrap statistics
- **Cost**: ~$18-25 per full 3-condition run at Opus 4.7 April 2026 rates

First run pending. Results will be published with full methodology, data, and reproducibility instructions.

---

## 📚 Files

```
mdbrain/
├── README.md                      ← you are here
├── BRAIN.md                       ← orchestration logic
├── CRAFT.md                       ← 20 anti-patterns + safety net (XML-structured)
├── PERF.md                        ← 20 perf anti-patterns + measurement discipline
├── ARCHITECTURE.md                ← how it actually works (honest)
├── BOOTSTRAP_GUIDE.md             ← first-session walkthrough
├── CLAUDE.template.md             ← project memory template
│
├── .claude/
│   ├── settings.example.json      ← hook wiring + permissions
│   ├── agents/
│   │   ├── brain-router.md        ← orchestrator subagent
│   │   ├── craft-specialist.md    ← refactor subagent (no Write tool)
│   │   └── perf-specialist.md     ← perf subagent (no Write tool)
│   ├── hooks/
│   │   ├── safety-net.sh          ← PreToolUse hook (bash)
│   │   └── safety-net.ps1         ← PreToolUse hook (PowerShell)
│   ├── rules/
│   │   ├── craft-rules.md         ← path-scoped: src/**/*.{ts,tsx,js,jsx}
│   │   └── perf-rules.md          ← path-scoped: src/**, config files
│   └── commands/
│       ├── brain-scan.md          ← /brain-scan
│       ├── craft-audit.md         ← /craft-audit
│       └── perf-audit.md          ← /perf-audit
│
├── benchmark/
│   └── SPEC.md                    ← eval methodology (v1)
│
├── install.sh / install.ps1
├── LICENSE (MIT)
├── CHANGELOG.md
└── CONTRIBUTING.md
```

---

## ❓ FAQ

### Does the Safety Net actually work, or is it prompting theater?

Layers A (permissions) and B (hook) are out-of-process and deterministic. They work regardless of model behavior. Layer C (subagent tool scoping) is enforced at subagent spawn — the tool isn't available, period. Layers D (path-scoped rules) and E (prompt-level directives) are heuristic — they bias the model but cannot guarantee behavior.

See [`ARCHITECTURE.md`](ARCHITECTURE.md) §1 for the full layer-by-layer breakdown.

### Does this work with Cursor / Copilot?

Partially. `CRAFT.md` and `PERF.md` content is plain Markdown — any AI can read them. But the hook system, subagent tool scoping, and path-scoped rules are Claude Code 2026 features. Without them, you lose the deterministic layers.

### What's the brain metaphor for?

It's a mnemonic. "BRAIN routes, CRAFT refactors, PERF measures" is memorable. It's not a claim about cognition. The MD files are documents read by a language model.

### Does it work with existing `CLAUDE.md` and `memory/`?

Yes. Install defaults to `coexist` mode — nothing existing is modified except appending a 3-line protocol bootstrap to your `CLAUDE.md`. The `memory/` folder is acknowledged as-is.

### Built with AI help?

Yes. Designed by [CJ Kim](https://github.com/chanjoongkim) in iteration with Claude. The protocol's own Safety Net caught multiple attempts where Claude proposed to "improve" the protocol in self-defeating ways — which is exactly the kind of false-positive editing mdbrain is built to prevent.

---

## 🗺 Roadmap

- [x] **v0.1** — BRAIN / CRAFT / PERF / Safety Net (prompt-level)
- [x] **v0.2** — Native Claude Code mechanisms (hooks, subagents, path-scoped rules, commands), compressed protocols, benchmark spec
- [ ] **v0.3** — Run the benchmark; publish results
- [ ] **v0.4** — Per-language variants (CRAFT.python.md, CRAFT.rust.md)
- [ ] **v0.5** — `routines/DEPLOY.md`, `routines/TEST.md` templates
- [ ] **v1.0** — Stable API, npm package `mdbrain`

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Especially valuable:

- New false-positive entries (with minimal reproducers)
- New anti-pattern entries (A21+, P21+)
- Hook improvements (edge cases, better path matching)
- Language/stack-specific rules

---

## 📜 License

MIT. Use it, fork it, ship it.

---

<div align="center">

**Built by [CJ Kim](https://github.com/chanjoongkim) · Stress-tested with Claude · Published 2026-04-19**

*The model is eager. The Safety Net is skeptical. Together they ship.*

</div>
