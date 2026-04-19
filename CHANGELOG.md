# Changelog

All notable changes are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Semver: MAJOR.MINOR.PATCH.

> Note: this project was renamed from `mdbrain` to `stetkeep` at v0.4.0 (2026-04-20). All entries below v0.4.0 refer to the project under its original name.

---

## [0.4.0] — 2026-04-20

### Changed — project renamed from mdbrain to stetkeep

The project has been renamed from `mdbrain` to `stetkeep` due to a brand conflict with [mediaire's `mdbrain`](https://mediaire.ai/en/mdbrain/), an established CE-certified medical AI software for brain MRI analysis (certified 2019-01-21). Continuing under the same name carried real risks:

- Trademark dilution / confusion claims from an established medical brand
- Anthropic marketplace reviewer rejection on discovery
- SEO collision and user confusion ("is this a medical AI tool?")

The rebrand was executed at v0.3.0 + 1 day, when the npm download count was still effectively zero, making this the lowest-cost moment to switch.

**Name origin**: `stet` is the traditional editorial mark from Latin "let it stand" — an editor's instruction to cancel a proposed deletion and preserve the original text. `stetkeep` applies the same principle to code: stop Claude from "helpfully" refactoring your intentional code.

### Added — `stet` CLI alias

- The `stetkeep` package registers `stet` as a bin alias. After `npm install -g stetkeep`, both `stet install` and `stetkeep install` work identically.
- Note on the `stet` npm package name: we considered publishing a thin proxy package named `stet` as an additional shorthand, but npm's typosquatting protection blocks the name (it's considered too similar to `st`, `net`, `test`, etc.). This also means no one else can claim the name, so `stet` as a CLI shorthand is effectively reserved by npm policy. The only lost affordance is `npm install stet` as an installation command; the `stet` CLI command itself still works via the bin alias above.

### Migration for existing `mdbrain` users (all ~zero of you)

- Old package `mdbrain@<=0.3.0` has been deprecated on npm with pointer: "Renamed to stetkeep. See https://github.com/chanjoongx/stetkeep"
- New package `stetkeep@0.4.0` is **functionally identical** to `mdbrain@0.3.0`
- Replace `npm install mdbrain` with `npm install stetkeep`
- GitHub repo renamed: `chanjoongx/mdbrain` → `chanjoongx/stetkeep` (legacy URLs redirect automatically)
- Protocol bootstrap line in your `CLAUDE.md` still works; only the package name changed

### Fixed — pre-rename polish (bundled with the rename commit)

- README Install section reorganized into Quickstart (1-step, Layers C/D/E) and Recommended (2-step, all 5 layers) with explicit Layer A/B dependency on `settings.json`
- Repo layout section now shows the `.claude/` dogfooding mirrors and PRIVACY.md
- Verify section marks install-mode conditionality (npm-install vs plugin-marketplace)
- Roadmap updated: `v0.3.1 = benchmark results`, `v0.4 = rebrand + ongoing feedback`, `v0.5 = per-language variants`, `v1.0 = stable API`
- XML prompting claim now links to [Anthropic's official documentation](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags)
- Windows best-effort disclaimer in Requirements
- ARCHITECTURE §3 clarifies the layout is for `npx stetkeep install` flow, not plugin-marketplace installs
- CLAUDE.md hard constraints now track 3-place version-bump discipline (package.json, plugin.json, marketplace.json confirm)
- CONTRIBUTING documents the `.claude/` dogfooding mirror convention and manual sync verification
- `.claude/settings.json` overwrite warning added to README Recommended section
- `.github/workflows/mirror-sync-check.yml` added to prevent `.claude/` mirror drift via CI

### Removed

- `mdbrain-0.3.0.tgz` local artifact (stale pre-publish snapshot)

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
