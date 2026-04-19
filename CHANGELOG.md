# Changelog

All notable changes to mdbrain are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Semver: MAJOR.MINOR.PATCH.

---

## [0.3.0] — 2026-04-19

### Added — modern distribution

- **npm package `mdbrain`** — one-command install via `npx mdbrain install` (no `git clone` required).
  - ESM, Node 20+, zero runtime dependencies (stdlib only).
  - `bin/mdbrain.js` CLI entry with `install`, `scan`, `--version`, `--help` subcommands.
  - Published with `--provenance` (Sigstore-signed supply chain attestation).
- **Claude Code plugin manifest** (`.claude-plugin/plugin.json`) — mdbrain is now a valid native Claude Code plugin.
  - Ships `agents/`, `commands/`, `hooks/hooks.json` at plugin root per 2026 convention.
  - Submittable to the official Claude Code plugin marketplace.
- **Plugin marketplace manifest** (`.claude-plugin/marketplace.json`) — makes `github.com/chanjoongx/mdbrain` a self-hostable marketplace. Users can run `/plugin marketplace add chanjoongx/mdbrain` and discover `mdbrain` directly.

### Changed — positioning reset after competitive research

A three-agent research sweep on April 19 revealed that "mechanical guardrails via hooks" and "tool-scoped subagents" are **table-stakes in the April 2026 Claude Code ecosystem** (TDD-Guard, VoltAgent, wshobson, etc. already own those framings). We repositioned around the two genuinely differentiated pillars:

- **XML-structured protocol framework** — BRAIN/CRAFT/PERF treat Claude's attention surface as addressable via XML tags. Nobody else is marketing this as a first-class primitive despite Anthropic's own docs recommending it.
- **False-positive catalog** — the 16-entry registry of "patterns that look like anti-patterns but aren't" (config files, V8 JIT paths, framework idioms) is ecosystem-unique. No other project ships a curated FP catalog.

README, BRAIN.md, and CHANGELOG now lead with these. Hook enforcement is supporting evidence, not headline.

### Restructured — plugin-convention compliance

- `.claude/agents/` → `agents/` (plugin root)
- `.claude/commands/` → `commands/` (plugin root)
- `.claude/hooks/` → `hooks/` (plugin root) + new `hooks/hooks.json` manifest
- `.claude/rules/` and `.claude/settings.example.json` stay under `.claude/` (plugin spec cannot package path-scoped rules or settings; these remain as install templates only).

### Deprecated

- **`install.sh` / `install.ps1`** reduced to ~30-line thin wrappers that invoke `node bin/mdbrain.js install`. Same CLI flags as before, single source of truth. Recommended install path is now `npx mdbrain install`.

### Fixed

- Windows PowerShell em-dash (`—`) rendering corruption on CP949 / Korean locales (fallback to plain `-` through Node's UTF-8 stdout).
- `-ExecutionPolicy Bypass` no longer required — npm entry point sidesteps PowerShell's script policy entirely.
- `bash` invocation in PowerShell no longer routes to (missing) WSL — `npx mdbrain` works natively from any shell.

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
