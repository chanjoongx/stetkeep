# Changelog

All notable changes to mdbrain are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Semver: MAJOR.MINOR.PATCH.

---

## [0.2.1] — 2026-04-19 (post-review micro-fixes)

### Fixed — flagged in three-persona expert review

- **Bash-based Write bypass** — hook now blocks `>`/`tee` redirections into `legacy/`, `generated/`, `vendor/`, `node_modules/`, `dist/`, `build/`, `.next/`. Previously a specialist subagent with Bash access could write to protected zones by shell redirection.
- **Unsubstantiated "2-5× false-positive reduction" claim** in ARCHITECTURE.md — removed. Replaced with explicit "effect size not yet measured; see benchmark/SPEC.md" disclosure.
- **Residual "hippocampus" strings** (anatomy metaphor leaked into operational output) — scrubbed from `.claude/commands/brain-scan.md`, `BOOTSTRAP_GUIDE.md`, `install.sh`, `install.ps1`. Replaced with neutral "Memory (context)" / "project memory extension".
- **No literature references** — added ARCHITECTURE.md §10 "Related Work & Prior Art" citing Constitutional AI (Bai et al. 2022), MoE gating (Shazeer et al. 2017), LLM-Blender / RouteLLM (Jiang et al. 2023; Ong et al. 2024), Miller & Cohen 2001, McClelland et al. 1995, Badre 2008.

---

## [0.2.0] — 2026-04-19

### Added — native Claude Code 2026 mechanisms

- **PreToolUse hook** (`.claude/hooks/safety-net.sh` + `.ps1`) — out-of-process Safety Net enforcement on Edit/Write/Bash
- **Tool-scoped subagents** (`.claude/agents/brain-router.md`, `craft-specialist.md`, `perf-specialist.md`) — specialists cannot Write new files (tool not in scope)
- **Path-scoped rules** (`.claude/rules/craft-rules.md`, `perf-rules.md`) — auto-load on `src/**` file access
- **Slash commands** (`.claude/commands/`) — `/brain-scan`, `/craft-audit`, `/perf-audit`
- **Permissions deny/ask lists** (`.claude/settings.example.json`) — hard backstop for `legacy/`, `generated/`, `vendor/`, destructive Bash
- **Benchmark spec** (`benchmark/SPEC.md`) — 50-case eval methodology with human rubric grading and bootstrap statistics
- **ARCHITECTURE.md** — honest mapping of claims to actual enforcement mechanisms
- **CONTRIBUTING.md** — how to add anti-patterns, false-positive cases, hook improvements

### Changed — honesty pass

- **Protocol compression** — CRAFT.md and PERF.md compressed ~66% (~5,400 → ~1,800 tokens each) using XML-tag structure per Anthropic 2026 prompting best practices
- **Safety Net Layer 3** reframed from "never upgrade grade" (unenforceable) to "bias toward safer grade"
- **BRAIN.md** rewritten — thin orchestrator that routes to real mechanisms, not aspirational state machine
- **CLAUDE.template.md** — includes 3-line Protocol bootstrap reference so BRAIN/CRAFT/PERF guidance loads without the user memorizing magic phrases

### Removed

- **Fictional state management** section (Claude has no session timestamps or command counters)
- **Neuroplasticity / monthly self-audit** aspirational claim (Claude has no cross-session persistence)
- **YAML frontmatter "priority" theater** (there is no parser; decorative text only)
- **Unsubstantiated "~80% reduction (n=3)" metric** — replaced with published benchmark methodology, results pending
- **`.claude/rules/*.md` auto-load claim** that was previously mis-stated (it now correctly describes the path-scoped mechanism)

### Fixed

- Cerebellum/Hippocampus mappings reframed as mnemonic, not cognitive claim
- `install.sh` `set -e` incompatibility with check_file return codes and arithmetic pre-increment
- `install.sh`/`install.ps1` now copy `.claude/` directory and add Protocol bootstrap line to CLAUDE.md

---

## [0.1.0] — 2026-04-19 (internal only)

Initial prompt-only protocol draft. Not publicly released.

### Included
- BRAIN.md (orchestrator concept)
- CRAFT.md (20 anti-patterns + 10 principles)
- PERF.md (20 perf anti-patterns + measurement-first)
- Brain-region metaphor throughout
- install.sh / install.ps1 (coexist / merge / fresh modes)

### Known issues (fixed in 0.2.0)
- All behavioral claims were prompt-level — no mechanical enforcement
- Protocol claimed ~80% false-positive reduction with no methodology
- Referenced nonexistent `.claude/rules/*.md` auto-load mechanism
- State management / neuroplasticity sections encouraged hallucination
- Token cost high (~15-18K on full load)
