<div align="center">

```
███╗   ███╗██████╗ ██████╗ ██████╗  █████╗ ██╗███╗   ██╗
████╗ ████║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║
██╔████╔██║██║  ██║██████╔╝██████╔╝███████║██║██╔██╗ ██║
██║╚██╔╝██║██║  ██║██╔══██╗██╔══██╗██╔══██║██║██║╚██╗██║
██║ ╚═╝ ██║██████╔╝██████╔╝██║  ██║██║  ██║██║██║ ╚████║
╚═╝     ╚═╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
```

### *XML protocol framework + false-positive catalog for Claude Code.*

**Stop Claude from "helpfully" refactoring your intentional code.**

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=18&duration=3500&pause=900&color=A78BFA&center=true&vCenter=true&width=760&lines=XML-structured+protocols.+Not+prose+prompts.;16-entry+false-positive+catalog.;The+intentional-code+defense+layer.)](https://git.io/typing-svg)

[![npm](https://img.shields.io/npm/v/mdbrain?color=CB3837&logo=npm)](https://www.npmjs.com/package/mdbrain)
[![License: MIT](https://img.shields.io/badge/License-MIT-A78BFA.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Built%20for-Claude%20Code-D4A27F)](https://claude.com/claude-code)
[![Version](https://img.shields.io/badge/version-v0.3.0-5FE5D4)](CHANGELOG.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-7AB7FC)](CONTRIBUTING.md)

</div>

---

## ⚡ 30-second install

```bash
npx mdbrain install
```

That's it. Run it in your project. It wires up the protocols, subagents, hooks, and slash commands. Next session of `claude`, type `/brain-scan` and you're working.

Full walkthrough: [`BOOTSTRAP_GUIDE.md`](BOOTSTRAP_GUIDE.md).

---

## 🎯 What mdbrain actually is

Two things other Claude Code projects don't ship:

### 1. **XML-structured protocol framework**

Prose prompts ("be careful when refactoring, prefer readability over cleverness...") don't survive 20K-token contexts. XML-tagged directives do. Anthropic's own prompting guide recommends XML. We built three protocols around it:

- **BRAIN.md** — `<routing>` / `<mode>` / `<inhibit>` — decides where a command goes
- **CRAFT.md** — `<anti_patterns>` / `<safety_net>` / `<false_positives>` — structural refactor discipline
- **PERF.md** — `<pre_check>` / `<perf_budget>` / `<measurement_gate>` — measurement-first performance work

Each is ~1.8K tokens. Claude's attention lands on XML-delimited sections more reliably than on Markdown prose headers.

### 2. **False-positive catalog**

The 16-entry registry of "patterns Claude will mistakenly flag as problems." Examples:

| What Claude sees | What Claude will say | What it actually is |
|---|---|---|
| 1000-line `constants.js` | "God File (A1). Split it." | A data table. Splitting loses context. |
| Deliberate inline `for` loop | "Duplication (A3). Extract." | Profiled hot path. 10× faster than `reduce`. |
| Plain `<img>` element | "Use `next/image`." | Below-fold. Not the LCP element. |
| `Array.map().map().map()` | "Collapse into `reduce`." | V8 optimizes this; readability wins. |

When Claude matches one of these, the Safety Net flags it 🔴 Low confidence and asks before editing. Catalog is under `<false_positives>` in CRAFT.md and PERF.md.

No competitor ships this.

---

## 🛡 Supporting layer — hook-enforced Safety Net

On top of the XML framework, mdbrain ships a five-layer defense:

- **Layer A** — `permissions.deny` hard-blocks edits to `legacy/`, `generated/`, `vendor/` (deterministic)
- **Layer B** — PreToolUse hook runs out-of-process; returns `deny`/`ask`/`allow` JSON (deterministic)
- **Layer C** — Subagent tool scoping — `craft-specialist` / `perf-specialist` can't `Write` new files (structural)
- **Layer D** — Path-scoped rules auto-load CRAFT/PERF on `src/**` file access (heuristic)
- **Layer E** — XML protocols + false-positive catalog (heuristic)

Layers A / B / C fire regardless of model attention. Layers D / E bias behavior. Honest breakdown in [`ARCHITECTURE.md §1`](ARCHITECTURE.md).

This part is **not novel** — [TDD-Guard](https://github.com/nizos/tdd-guard), [claude-guardrails](https://github.com/dwarvesf/claude-guardrails), and others already ship hook-based enforcement. mdbrain's wedge is the XML framework + FP catalog above; hooks are just the vehicle.

---

## 🧠 Architecture at a glance

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
   │ agents/            │    │ .claude/rules/       │
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
                 │ PreToolUse HOOK        │  ◀── mechanical, out-of-process
                 │ hooks/safety-net.sh    │     can deny / ask / allow
                 │ + false-positive gate  │     XML-catalog-driven
                 └───────────┬────────────┘
                             │
                        allow│deny/ask
                             ▼
                    ┌──────────────┐
                    │   file edit  │
                    └──────────────┘
```

---

## 📦 Install

### Option 1 — `npx` (recommended, no clone needed)

```bash
cd /path/to/your-project
npx mdbrain install
```

Handles existing `CLAUDE.md` / `memory/` / other `.md` files non-destructively by default (coexist mode).

Modes:
- `--mode coexist` (default) — preserve everything, append 3-line bootstrap to CLAUDE.md
- `--mode merge` — same + add a Protocols reference section
- `--mode fresh` — empty-project install (requires `--force` if anything exists)
- `--dry-run` — preview without writing

### Option 2 — Claude Code plugin marketplace

```
# In Claude Code
/plugin marketplace add chanjoongx/mdbrain
/plugin install mdbrain
```

Auto-loads the subagents, commands, and hook — no file copying into your project. Downside: cannot install the path-scoped rules and root-level protocol MDs (those are user-level, not plugin-packagable).

### Option 3 — clone + script (legacy)

```bash
git clone https://github.com/chanjoongx/mdbrain.git
cd /path/to/your-project
bash /path/to/mdbrain/install.sh
```

The `install.sh` is now a thin wrapper over `node lib/install.js`. Use this if you want to hack on mdbrain itself.

### After install

```bash
# One-time: activate the hook
cp .claude/settings.example.json .claude/settings.json

# Launch Claude Code
claude

# Type this inside Claude Code:
/brain-scan
```

---

## 📦 Requirements

- **Claude Code 2026+** (hooks, subagents, path-scoped rules, slash commands all require this)
- **Node 20+** (bundled with Claude Code — you have it)
- **bash** on macOS/Linux; **Git Bash or PowerShell** on Windows
- **jq** (optional — hook falls back to grep if absent)

---

## ⚖ vs. the 2026 ecosystem

Honest comparison, based on [competitive research](https://github.com/chanjoongx/mdbrain/blob/main/CHANGELOG.md#030):

| | **mdbrain** | [TDD-Guard](https://github.com/nizos/tdd-guard) | [claude-guardrails](https://github.com/dwarvesf/claude-guardrails) | [VoltAgent subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | [everything-claude-code](https://github.com/affaan-m/everything-claude-code) |
|---|---|---|---|---|---|
| **Scope** | XML protocols + FP catalog | TDD-specific blocking | Security permissions | Subagent library | Kitchen-sink toolkit |
| **Stars (Apr 2026)** | v0.3.0 launch | 2K | 12 | 17.7K | 160K |
| **Hook enforcement** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Tool-scoped subagents** | ✅ | ❌ | ❌ | ✅ | ✅ |
| **XML-structured protocols** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **False-positive catalog** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Plugin marketplace** | ✅ | ✅ | ❌ | ✅ | ✅ |
| **npm package** | ✅ | ✅ | ✅ | ❌ | ✅ |

If you want **TDD-specific blocking** → TDD-Guard. If you want **security policy as code** → claude-guardrails. If you want **an agent library** → VoltAgent. If you want **everything at once** → everything-claude-code.

If you want **a protocol framework with a curated false-positive registry**, that's us.

---

## 🎯 Verify it works

```bash
# 1. Hook runs and returns decisions
echo '{"tool_name":"Edit","tool_input":{"file_path":"legacy/x.ts"}}' \
  | bash .claude/hooks/safety-net.sh

# Expected (JSON):
# {"hookSpecificOutput":{"permissionDecision":"ask", ...}}

# 2. Subagents discoverable
ls .claude/agents/
# brain-router.md  craft-specialist.md  perf-specialist.md

# 3. Slash commands (after restarting claude)
# In Claude Code, type `/` — you should see /brain-scan, /craft-audit, /perf-audit

# 4. Quick diagnostic
npx mdbrain scan
```

---

## 🔧 Troubleshooting

### Windows PowerShell execution policy blocks install.ps1
Use `npx mdbrain install` instead (npm bypasses the .ps1 policy entirely). Or:
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

### PowerShell renders em-dashes (`—`) as `??`
Cosmetic only on Korean / CP949 consoles. Run `chcp 65001` first, or just ignore — the install is correct.

### `bash` in PowerShell tries to invoke WSL
That's Windows's built-in `bash.exe` (WSL proxy), not Git Bash. Use `npx mdbrain install` (no bash dependency) or open Git Bash directly from the Start menu.

### Hook doesn't seem to do anything
Verify the hook returns JSON:
```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"legacy/x.ts"}}' | bash .claude/hooks/safety-net.sh
```
If no output: make sure `.claude/settings.json` exists (copy from `settings.example.json`) and the hook is wired under `hooks.PreToolUse`.

### `/brain-scan` not recognized
Claude Code 2026+ required. Older versions don't scan `.claude/commands/`. Check with `claude --version`.

---

## 📁 Repo layout

```
mdbrain/
├── agents/                      # plugin subagents (Claude Code marketplace compatible)
├── commands/                    # plugin slash commands
├── hooks/
│   ├── hooks.json               # plugin hook manifest
│   ├── safety-net.sh            # PreToolUse (bash)
│   └── safety-net.ps1           # PreToolUse (PowerShell)
├── .claude/
│   ├── rules/                   # path-scoped rules (user-level, not plugin-packagable)
│   └── settings.example.json    # hook wiring template
├── .claude-plugin/
│   ├── plugin.json              # Claude Code plugin manifest
│   └── marketplace.json         # self-hosted marketplace entry
├── bin/mdbrain.js               # npm CLI entry (ESM, Node 20+, stdlib only)
├── lib/
│   ├── install.js               # cross-platform installer
│   ├── scan.js                  # ecosystem diagnostic
│   └── utils.js                 # log helpers
├── BRAIN.md                     # routing protocol
├── CRAFT.md                     # refactor protocol + FP catalog
├── PERF.md                      # performance protocol + FP catalog
├── ARCHITECTURE.md              # honest enforcement breakdown
├── BOOTSTRAP_GUIDE.md           # first-session walkthrough
├── benchmark/SPEC.md            # evaluation methodology
├── validators/                  # installation verification (.sh + .ps1)
├── install.sh / install.ps1     # thin wrappers over lib/install.js
├── package.json
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE
```

---

## 🧪 Benchmark

We publish a pre-registered evaluation spec instead of hand-wavy numbers:

📄 [`benchmark/SPEC.md`](benchmark/SPEC.md) — 50 test cases, 3 conditions (vanilla / mdbrain full / mdbrain Safety-Net-only), human rubric grading (Cohen's κ ≥ 0.75), paired bootstrap statistics, `~$18–25` per full run on Opus 4.7 (April 2026 pricing).

Results pending. We'll publish data + methodology, not a single percentage.

---

## ❓ FAQ

### Does the Safety Net actually work, or is it prompting theater?
Layers A (permissions) and B (hook) are out-of-process and deterministic — they block edits before the tool fires, regardless of what Claude decided. Layer C (subagent tool scoping) is enforced at spawn — the tool simply isn't available. Layers D (path-scoped rules) and E (XML protocols + FP catalog) are heuristic — they bias the model but cannot guarantee behavior. Full breakdown in [ARCHITECTURE.md §1](ARCHITECTURE.md).

### Does this work with Cursor / Codex / OpenCode?
The XML protocols and false-positive catalog are plain Markdown — any AI that reads MD can use them. But the hook system, subagent tool scoping, and path-scoped rules are Claude Code 2026 features. Without them you lose the deterministic layers.

### Why the brain metaphor?
It's a mnemonic — "BRAIN routes, CRAFT refactors, PERF measures" — not a cognitive claim. MD files are documents read by a language model. See [ARCHITECTURE.md §8](ARCHITECTURE.md).

### Does it work with existing `CLAUDE.md` and `memory/`?
Yes. `coexist` mode (default) preserves everything — only appends a 3-line bootstrap reference to your CLAUDE.md. The `memory/` folder is detected and left untouched.

### npm install vs plugin marketplace?
- **npm install**: gets you **everything** — the root protocols (BRAIN.md / CRAFT.md / PERF.md), path-scoped rules, settings template, plus the plugin components.
- **Plugin marketplace**: gets you **only the plugin components** — subagents, slash commands, hook. Path-scoped rules and root-level protocols can't be packaged as a plugin, so they stay user-level.

For full mdbrain behavior, use npm install. For lightweight subagent access, plugin install is enough.

### Built with AI?
Yes. Designed by [CJ Kim](https://github.com/chanjoongx) in iteration with Claude. The protocol's own Safety Net caught multiple attempts where Claude proposed to "improve" the protocol in self-defeating ways — which is exactly the kind of false-positive editing mdbrain is built to prevent.

---

## 🗺 Roadmap

- [x] **v0.1** — protocol-only draft
- [x] **v0.2** — Claude Code 2026 native mechanisms (hooks, subagents, path-scoped rules)
- [x] **v0.3** — **npm package + plugin manifest + ecosystem repositioning**
- [ ] **v0.4** — Claude Code marketplace submission; `npx mdbrain init` interactive
- [ ] **v0.5** — per-language variants (`CRAFT.python.md`, `CRAFT.rust.md`)
- [ ] **v0.6** — run the benchmark, publish results
- [ ] **v1.0** — stable API, typed plugin configs

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Highest-value contributions:

- **New false-positive entries** — patterns Claude commonly mis-flags (with a minimal reproducer)
- **New anti-pattern entries** (A21+, P21+) — with corresponding FP counterexamples
- **Hook improvements** — edge cases, better path matching, platform fixes
- **Benchmark corpus cases** — see [benchmark/SPEC.md §3](benchmark/SPEC.md)

---

## 📜 License

MIT. Use it, fork it, ship it.

---

<div align="center">

**Built by [CJ Kim](https://github.com/chanjoongx) · Stress-tested with Claude · Published 2026-04-19**

*The model is eager. The Safety Net is skeptical. The XML protocol is structured.*

</div>
