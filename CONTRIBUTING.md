# Contributing to stetkeep

Thank you for considering a contribution. This project improves faster when people
break it, find its false-positives, and ship real fixes.

---

## Highest-value contributions

### 1. False-positive entries

The `<false_positives>` catalogs in `CRAFT.md` and `PERF.md` are the single most
behaviorally-useful part of the protocol. They encode "patterns the AI will mistakenly
refactor."

**What we want**:
- A specific code pattern the AI commonly mis-flags
- The anti-pattern ID it mistakenly matches (e.g., "flagged as A3 duplication")
- Why the code is actually correct (1 sentence)
- A minimal reproducer (10-30 lines)

**Where to add**: append a row to the `<false_positives>` table in `CRAFT.md` or `PERF.md`.

### 2. Hook improvements

`.claude/hooks/safety-net.sh` and `.ps1` enforce the mechanical Safety Net. Improvements we want:

- Better gitignore-pattern matching (current regex conversion is simplistic)
- More efficient marker detection (currently scans first 20 lines)
- Additional protected path categories (e.g., `.github/workflows/`, `Dockerfile*` if user opts in)
- Edge cases that caused false positives or misses

**Include** a test invocation in your PR:
```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"YOUR_TEST_PATH"}}' \
  | bash .claude/hooks/safety-net.sh
```
with expected output.

### 3. New anti-patterns

A21+, P21+. The 20+20 catalog is not exhaustive.

**Requirements**:
- Pattern must be common (seen across ≥3 real projects)
- Detection must be concrete (LOC thresholds, AST pattern, etc.)
- Transformation must preserve behavior
- Must include a false-positive counterexample

### 4. Language/stack specialization

`CRAFT.md` currently biases toward TypeScript/React. Python, Rust, Go would benefit
from their own variants: `CRAFT.python.md`, `PERF.python.md`, etc.

Scope for v0.5 — open issues with the proposal first so we can align on structure.

### 5. Benchmark corpus cases

`benchmark/SPEC.md` specifies 50 test cases (40% TRUE, 40% FALSE, 20% ambiguous).
We need contributed cases.

**Format**: one YAML file per case with:
```yaml
id: case-042
category: FALSE   # TRUE / FALSE / AMBIGUOUS
expected_action: skip   # fix / skip / ask
anti_pattern_id: A3  # which pattern it looks like
code: |
  // actual code snippet
rationale: "..."
```

---

## Process

### Small contributions (false positives, doc fixes)

1. Fork
2. Edit the relevant `.md` file or `.sh`/`.ps1` hook
3. Open a PR with:
   - The change
   - For hooks: the test invocation + expected output
   - For catalogs: a minimal reproducer

### Larger contributions (new subagents, new rules, new languages)

1. Open an issue first — "Proposal: add CRAFT.python.md"
2. Discuss scope before writing
3. PR with:
   - Rationale
   - Cross-reference updates (BRAIN.md routing table, ARCHITECTURE.md file layout)
   - Test cases for `benchmark/SPEC.md` corpus if applicable

---

## Style

- **Honesty first**: do not claim mechanical enforcement for prompt-only features
- **Concrete detection rules**: "file >300 LOC" beats "file too long"
- **Preserve XML tag structure** in CRAFT.md / PERF.md — it's load-bearing for Claude's attention
- **No emojis in rules**: emojis can disrupt Claude's XML parsing in edge cases; they're fine in README/docs
- **Test any hook change**: a broken hook fails open (Claude proceeds) — silent regression is worst-case
- **Match existing phrasing**: "Any match => 🔴 Low confidence, confirm first" is the canonical false-positive closing

---

## What we will reject

- Changes that add features without removing anything (bloat)
- New rules without corresponding false-positive entries (half-measures)
- Behavioral claims without a mechanism (hook / permission / subagent tool scoping)
- Expanding the brain metaphor into more prose (the metaphor is a mnemonic, not an ontology)
- Unsupported performance claims in README or CHANGELOG

---

## Dogfooding layout

The repo contains two copies of the plugin directories on purpose:

- `agents/`, `commands/`, `hooks/` at the repo root are the **canonical**, marketplace-distributed versions
- `.claude/agents/`, `.claude/commands/`, `.claude/hooks/` are **mirrors** of the canonical versions

The mirrors exist so that running `claude` inside this repo loads stetkeep's own subagents, slash commands, and hooks (dogfooding). They are NOT shipped via npm or the plugin marketplace, so users never see them.

When editing any plugin artifact:

1. Edit the **root** version first (e.g. `agents/brain-router.md`)
2. Copy the change to the mirror (`.claude/agents/brain-router.md`)
3. Both versions must stay byte-identical. CI enforces this via `.github/workflows/mirror-sync-check.yml` on every push/PR (runs `diff -rq` across the three pairs). Still manually check before committing to avoid CI red.

Manual sync verification:
```bash
diff -rq agents/   .claude/agents/
diff -rq commands/ .claude/commands/
diff -rq hooks/    .claude/hooks/
```
No output means they agree. Any drift will make in-repo `claude` sessions run stale mirrors while npm/plugin users get the latest version.

---

## Local development

```bash
# Clone
git clone https://github.com/<username>/stetkeep.git
cd stetkeep

# Install into a test project
bash install.sh /path/to/test-project

# Verify hooks work
echo '{"tool_name":"Edit","tool_input":{"file_path":"legacy/x.ts"}}' \
  | bash .claude/hooks/safety-net.sh
```

---

## Governance

- Solo maintainer (CJ Kim) until traction warrants more
- All decisions traceable via issues and PR comments
- Benchmark results will be published openly; no selective reporting

---

## Code of Conduct

Be direct. Be kind. Assume good faith. This project's own origin — a human iterating with an AI that kept proposing bad refactors — is a reminder that being wrong is normal.
