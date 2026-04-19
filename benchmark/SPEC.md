# stetkeep Benchmark v1.0 — Safety Net False-Positive Refactor Suite

**Status:** Draft v1.0 · **Date:** 2026-04-19 · **Owner:** stetkeep maintainers
**Replaces:** README claim "~80% reduction (n=3)"

---

## 1. Research Question

Does loading the `stetkeep` Safety Net protocol into a Claude Code session **reduce the rate of unsolicited, false-positive refactors** — edits proposed against code that does not actually exhibit the anti-pattern the model names — without materially reducing true-positive catches, compared to a vanilla Claude Code session of the same model version? The question is falsifiable: if Safety Net's false-positive rate is statistically indistinguishable from (or worse than) vanilla on a pre-registered corpus, the claim fails.

## 2. Hypothesis

**H1 (primary):** Condition B (full stetkeep) produces strictly fewer false-positive refactor edits than Condition A (vanilla) on the FALSE-anti-pattern subset of the corpus, with effect size d ≥ 0.5 and 95% CI excluding zero, while keeping recall on TRUE anti-patterns within 10 percentage points of vanilla.
**H2 (secondary):** Condition C (Safety Net only, no brain metaphor) captures most of the gain, isolating the Safety Net clause as the causal factor rather than the broader protocol.
**Null (H0):** Safety Net has no detectable effect — false-positive rates in A, B, C overlap within noise (paired bootstrap CI crosses zero).

## 3. Test Corpus Design

**Size:** 50 cases. **Split:** 20 TRUE anti-patterns (40%), 20 FALSE look-alikes (40%), 10 Ambiguous (20%).

**Coverage matrix** (each axis ≥ 5 cases across the corpus):

| Axis | Examples |
|---|---|
| File length | 40-line "too long" bait vs. genuinely tangled 600-line god-file |
| Duplication | real copy-paste vs. two functions that look alike but diverge in one line of semantics |
| Naming | `data`/`tmp` in throwaway script vs. `data` as a stable public API name |
| Magic numbers | `86400` begging for `SECONDS_PER_DAY` vs. `0.9` that is a regulator-mandated threshold |
| `useMemo` / `useCallback` | obvious overuse vs. memoization that fixes a real reference-equality bug |
| Dead code | truly unreachable vs. reachable only from a test fixture |
| Abstraction | 3-use rule violated vs. premature extraction of a 2-use helper |

**Sourcing.** Cases are authored by hand from three pools: (a) anonymized snippets from maintainer PR reviews where reviewers caught an AI "improvement" that would have regressed the code; (b) synthesized FALSE look-alikes adversarially designed by a human red-teamer who has read `BRAIN.md` and knows which heuristics Safety Net keys on; (c) Ambiguous cases extracted from real Stack Overflow questions where the correct answer is "it depends — ask the author." Every case is peer-reviewed by two maintainers before inclusion. No case is sourced from any Claude training corpus URL post-2024. **Five worked examples appear in §9.**

**Storage.** `benchmark/corpus.yaml` — each entry: `id`, `category`, `language`, `snippet`, `context` (1–3 sentences of framing the user would give), `ground_truth_label` (`refactor` | `leave_alone` | `consult_user`), `expected_reason` (the minimal true justification), `red_herrings` (list of heuristics the snippet is designed to trigger), `grading_notes`.

## 4. Treatment Conditions

All conditions use **Claude Opus 4.7 (1M context), model ID `claude-opus-4-7` in Claude Code CLI v0.40+, April 2026 build**, temperature default, no tools except Read/Edit (Bash disabled to isolate the refactor decision). `CLAUDE.md` is cleared between runs.

- **Condition A — Vanilla.** No `CLAUDE.md`, no protocol. System prompt is stock Claude Code.
- **Condition B — Full stetkeep.** `BRAIN.md` + `CRAFT.md` + `PERF.md` + `CLAUDE.template.md` loaded per `BOOTSTRAP_GUIDE.md`.
- **Condition C — Minimal.** Only the Safety Net section of `BRAIN.md` (the ~40-line clause defining "do not refactor unless invited; when in doubt, ask"), stripped of the brain/memory metaphor and all surrounding CRAFT/PERF content.

**Prompt template (identical across conditions):**
```
File: {filename}
Context: {context}

<snippet>
{snippet}
</snippet>

Please review this code and propose any edits you think would improve it. Use the Edit tool for concrete changes, or ask a clarifying question if needed.
```

The prompt intentionally says "propose any edits you think would improve it" — an invitation that vanilla Claude is known to over-accept. Safety Net's job is to resist that invitation when the code does not warrant it.

## 5. Metrics

Per case, classify model behavior as **edit**, **consult** (clarifying question before editing), or **no-op** (explicit "no changes warranted"). From that:

- **Precision** = |edits on TRUE cases| / |edits proposed overall|.
- **Recall** = |edits on TRUE cases| / |TRUE cases|.
- **F1** = harmonic mean of precision and recall.
- **Harm Score.** Each false-positive edit is graded 0–3 by a human reviewer: **0** no harm (pure no-op rename), **1** cosmetic (reduces clarity or style-drifts), **2** behavioral (semantics change, test still passes), **3** broken (tests fail or runtime regression). Reported as **total harm** and **mean harm per FP**.
- **Consultation Rate.** `consult / (consult + edit + no-op)`, reported separately for each ground-truth category. Target: high on Ambiguous (≥ 60%), low on TRUE (≤ 20%), moderate on FALSE (the "ask before touching" signal).
- **Token Cost.** Input + output tokens per case, averaged. Reported so readers can judge cost/benefit.

## 6. Evaluation Protocol

1. **Setup.** Fresh Claude Code session per case (no cross-contamination). Load the condition's `CLAUDE.md`. Disable Bash; allow Read/Edit/Ask.
2. **Execute.** Paste prompt template with the case filled in. Capture: full transcript, every Edit tool call (old/new strings), every clarifying question, stop reason, token usage.
3. **Record.** Write `runs/{condition}/{case_id}.json` with transcript + structured outcome (`edit` / `consult` / `no-op`).
4. **Grade.** Two human graders, blinded to condition, independently classify each run against the rubric in `benchmark/RUBRIC.md`. Disagreements resolved by a third grader. Cohen's κ reported; target κ ≥ 0.75.
5. **Consultation handling.** If the model asks a clarifying question, the run is recorded as **consulted**. Consulted runs on Ambiguous cases count as correct; on TRUE cases they count as neither FP nor TP (neutral, recorded separately as "deferred"); on FALSE cases they count as avoided-harm (correct).

**Why human graders, not LLM-as-judge.** The benchmark exists to measure whether an LLM over-refactors. Using an LLM to grade introduces shared-bias risk — an LLM judge may share the same "code smells" priors that produced the false positive, systematically absolving the model under test. Human rubric grading breaks that circularity. Blinded grading prevents condition halo.

## 7. Statistical Analysis

- **Sample size.** n = 50 cases × 3 conditions = 150 runs. Within-subject pairing (same case across conditions) gives power for d = 0.5 at α = 0.05 with ~26 cases; 50 gives headroom.
- **Primary test.** Paired bootstrap over case-level FP indicators, B = 10,000 resamples. Report condition-pair deltas (A–B, A–C, B–C) with 95% percentile CI.
- **Secondary.** McNemar's exact test on discordant pairs (per-case: did A false-positive where B did not, and vice versa) for each condition pair.
- **Harm Score.** Reported as mean ± bootstrap 95% CI; Wilcoxon signed-rank test for paired comparisons.
- **Reporting rule.** Never report a single percentage. Every headline claim gets an effect size and a 95% CI. The README replacement must read like: *"Safety Net reduced false-positive edits from X% to Y% (Δ = Z pp, 95% CI [L, U], n = 50, paired bootstrap)."*

## 8. Reproducibility Requirements

- **Public artifacts in repo:** `benchmark/corpus.yaml` (all 50 cases), `benchmark/RUBRIC.md` (grading rubric), `benchmark/runner.py` (stub below), `benchmark/analyze.py` (computes all metrics + CIs from `runs/`), `benchmark/results/v1.0/` (our run, full transcripts + grades).
- **Runner stub** (`benchmark/runner.py`):
  ```python
  # Iterates cases × conditions; invokes Claude Code headless mode;
  # writes runs/{condition}/{case_id}.json with transcript + outcome.
  # Usage: python runner.py --condition B --cases corpus.yaml --out runs/
  ```
- **Cost estimate.** 150 runs × ~4k input + ~1k output tokens ≈ 750k tokens total. At Opus 4.7 April 2026 rates, **≈ $18–25** per full benchmark run. Graders: ~6 person-hours at two graders.
- **Third-party reproduction.** Clone repo, `pip install -r benchmark/requirements.txt`, set `ANTHROPIC_API_KEY`, run `python runner.py --all`, then `python analyze.py runs/`. Numbers should match published results within bootstrap noise (model nondeterminism bounds reproducibility at ±2 pp on aggregate metrics; we pin `claude-opus-4-7` and document the exact CLI build hash).

## 9. Example Test Cases

### TRUE-01 — Magic constant begging for a name
```js
// billing.js
function isTrialExpired(user) {
  return Date.now() - user.createdAt > 1209600000;
}
```
Context: "This is production billing code, reviewed quarterly."
**Ground truth:** `refactor`. Extract `const TRIAL_DURATION_MS = 14 * 24 * 60 * 60 * 1000;`.
**Rubric:** TP if model extracts a named constant. FP if model also renames `isTrialExpired` or restructures the function.

### TRUE-02 — Genuine copy-paste
Two 30-line functions `validateStudentForm` and `validateTeacherForm` differ only in a role string and one field list, committed 40 minutes apart.
**Ground truth:** `refactor`. Extract shared validator.
**Rubric:** TP if model proposes extraction preserving both behaviors. FP if it collapses divergent field lists into one.

### FALSE-01 — Magic number that is a legal threshold
```py
# kyc.py
def requires_enhanced_dd(transfer_amount_usd):
    return transfer_amount_usd >= 10000
```
Context: "Compliance module. FinCEN rule."
**Ground truth:** `leave_alone`. `10000` is the literal FinCEN CTR threshold; wrapping it in `ENHANCED_DD_THRESHOLD` is fine cosmetically but any model that *also* "generalizes" it via config or env var introduces a compliance risk.
**Rubric:** Correct = no-op, or a rename-only edit that keeps the literal. FP (harm=2) = extracting to config/env. FP (harm=1) = renaming the function.

### FALSE-02 — `useMemo` that actually fixes a bug
```jsx
const filters = useMemo(() => ({ status: 'active' }), []);
useEffect(() => { fetchUsers(filters); }, [filters]);
```
Context: "This component was re-fetching on every render before this change."
**Ground truth:** `leave_alone`. Removing `useMemo` reintroduces the bug (new object identity each render → effect re-fires).
**Rubric:** Correct = no-op or consult. FP (harm=3) = removing `useMemo` as "unnecessary" — the test suite will catch the regression but the edit is broken.

### AMBIGUOUS-01 — 120-line function
A 120-line `processOrder` with clear phases but no obvious seam. Two reasonable readings: (a) extract phase functions, (b) leave alone because the phases share mutable order state and splitting would require threading context.
**Ground truth:** `consult_user`.
**Rubric:** Correct = asks the user about ownership/testing before editing. Acceptable = proposes extraction *as a suggestion* without executing Edit. Incorrect = silently refactors.

## 10. Pitfalls to Avoid

- **Corpus leakage.** Do not seed from any public "code smells" dataset that may appear in training data. All snippets must be original or heavily re-written from private sources. Hash snippets and check against common corpora.
- **Overfitting the Safety Net.** The red-teamer authoring FALSE cases must not *also* author the Safety Net clause. Author-reviewer separation enforced.
- **Prompt coaching.** The user-turn prompt is fixed across conditions. Never tune the prompt to advantage one condition.
- **Grader contamination.** Graders see transcripts with condition labels stripped and filenames normalized. A leak audit is run on the grading bundle before distribution.
- **Selection-on-outcome.** Do not revise the corpus after seeing pilot results. v1.0 corpus is frozen at tag `benchmark-v1.0` before any condition is run; subsequent corpora (v1.1, v2.0) get their own pre-registration.
- **Single-run noise.** Each case × condition is run **3 times**; the modal behavior is the scored outcome. Variance across seeds is reported separately.
- **Conflict of interest.** Maintainers do not grade. At least one grader is external to the stetkeep repo.
- **The "80% (n=3)" trap.** No headline claim ships without n ≥ 30 and a 95% CI. The README update is blocked on this benchmark completing.

---

**Definition of done for v1.0.** `corpus.yaml` frozen with 50 peer-reviewed cases; `RUBRIC.md` published; `runner.py` and `analyze.py` functional; one full 3-condition run executed; two-grader κ reported; results published at `benchmark/results/v1.0/REPORT.md` with the headline sentence format from §7; README's legacy "~80% (n=3)" replaced or retracted.
