# PERF.md — Performance Optimization Protocol

<mission>
Measure. Optimize only what hurts. Prove the fix with numbers.
Trigger phrases: "PERF mode", "optimize performance", "follow PERF.md".
Knuth: premature optimization is the root of all evil.
</mission>

<pre_check>
Before any optimization, all three must be YES:
1. Measured bottleneck? (profile / Lighthouse / benchmark data exists)
2. User-perceptible? (not just dev-tool curiosity)
3. Payoff > readability cost?
Any NO => do not optimize.
</pre_check>

<constraints>
1. Measurement is mandatory. No numbers = no change.
2. Follow 80/20 — target Top 5 hotspots only.
3. Define budget first; if inside budget, stop.
4. Correctness beats speed.
5. Do not optimize run-once init / migration code.
6. `React.memo` / `useMemo` / `useCallback` have cost — add only after Profiler evidence.
7. Cache only where needed; cache = invalidation bug surface.
8. >100ms work => async / worker / idle.
9. Best optimization is deleting code.
10. Readability-sacrificing hack requires a `// PERF:` comment with profile numbers.
</constraints>

<perf_budget>
Web Vitals defaults (tune per project):
  LCP  < 2.5s
  INP  < 200ms      (replaced FID as Core Web Vital, Mar 2024)
  CLS  < 0.1
  TTI  < 3.8s
  TTFB < 800ms
Bundle:
  Initial JS (gzip)  < 170KB (recommended) / < 500KB (hard cap)
  Initial CSS        < 50KB
  Total transfer     < 1.5MB
  Lighthouse score   > 90
Runtime:
  Frame budget       16.67ms (60fps)
  Long task          < 50ms
  Memory growth      zero (no leaks)
</perf_budget>

<decision_matrix>
All 6 must be YES to optimize:
1. Measured? (else STOP)
2. User affected? (else STOP)
3. Budget exceeded? (else leave it)
4. In Top 5 bottlenecks? (else fix bigger things)
5. Readability cost justified? (else prefer CRAFT)
6. Can verify Before/After under same conditions?
</decision_matrix>

<workflow>
GREENFIELD: declare the budget in README, pick a framework mindful of bundle size, design the critical path under 50KB above the fold, pick a data layer (SWR / React Query for dynamic), plan route-based splitting from day one, install `web-vitals` + Lighthouse CI gate.

BROWNFIELD (main mode):
  P0 Baseline (never skip):
    - `npx lighthouse <url> --view --preset=desktop` then `--preset=mobile`
    - Bundle: `npx vite-bundle-visualizer` or `npx source-map-explorer 'dist/assets/*.js'`
    - React DevTools Profiler: Top 5 longest renders
    - Chrome Performance: record with 6x CPU throttle
    - Memory: heap snapshots over time
  P1 Bottleneck priority matrix (Impact x User-pain). Pick Top 5.
  P2 For each: What / Where / Why / Fix hypothesis.
  P3 ONE optimization at a time: predict, implement, re-measure, compare, rollback if off.
  P4 Report Before/After with deltas (% change).
  P5 Log history in project PERF.md with date, metric deltas, method, verification tool.
  P6 Stop when: budget reached OR last gain <5% OR readability loss > perf gain OR Top 5 exhausted.
</workflow>

<anti_patterns>
| ID | Pattern | Transform |
|---|---|---|
| P1 | Inline object/fn in JSX | Hoist const / `useCallback` (only if child memoized) |
| P2 | Missing memo/useMemo/useCallback | Apply only after Profiler proves re-render cost |
| P3 | Useless useEffect (render->setState) | Replace with `useMemo` |
| P4 | Giant Context for everything | Split context or Zustand/jotai |
| P5 | Unvirtualized long list (>100) | `react-window` / `@tanstack/virtual` |
| P6 | Unoptimized images | WebP/AVIF + srcset + `loading=lazy` + `decoding=async` |
| P7 | Bundle bloat (>500KB initial) | Swap fat deps (moment->date-fns, lodash->lodash/x), dynamic import |
| P8 | Duplicate fetches | React Query / SWR dedup |
| P9 | No input debounce | `debounce(setQuery, 300)` via `useMemo` |
| P10 | Sync heavy computation in render | `useMemo` / Web Worker / `requestIdleCallback` |
| P11 | Excess setState calls | Batch / reducer (watch async auto-batch edges) |
| P12 | Huge dep for tiny feature | Hand-roll or lighter alternative |
| P13 | No code splitting | Route-level `lazy()` |
| P14 | Waterfall requests | `Promise.all` |
| P15 | Missing HTTP caching | Cache-Control, immutable fingerprints |
| P16 | Memory leaks | Return cleanup from `useEffect` |
| P17 | Blocking fonts (FOIT) | `font-display: swap` + preload critical |
| P18 | Layout thrashing | Batch reads, then writes |
| P19 | Sync localStorage in render | Lazy `useState` init or move to effect |
| P20 | Unnecessary SSR re-hydration | Selective hydration / islands |
</anti_patterns>

<transformations>
T1 `useCallback` — only when child is `React.memo` and stable identity matters.
T2 `useMemo` — only for repeated expensive work on the same input.
T3 `React.memo` — only when props rarely change but the parent re-renders often.
T4 Virtualize when list > ~100 items.
T5 Route-level `lazy()` + `Suspense`.
T6 Image pipeline: WebP/AVIF, multi-size srcset, lazy, async decode.
T7 Web Worker for independent heavy JS.
T8 Request dedup via React Query.
T9 `debounce` (lodash-es) for input; `throttle` for scroll.
T10 `<link rel=preload/prefetch>` for critical assets.
T11 Batch DOM reads then writes to avoid layout thrash.
T12 Always return cleanup from `useEffect` (timers, listeners, subs).
</transformations>

<safety_net>
Layer 1 — Inline markers (skip and do not touch):
  `// @perf-optimized reason="profiled: 62% CPU, hand-tuned"`
  `// @perf-hot-path reason="frame budget critical, 16ms target"`
  `// @perf-measured date="YYYY-MM-DD" baseline="LCP 1.8s"`
  `// @perf-benchmarked reason="3.2x faster than reduce"`
  `// @perf-intentional-inline reason="V8 JIT optimization path"`
  `reason=` is REQUIRED.

Layer 2 — `.perfignore` (path-based):
  src/core/renderer.ts, src/engine/fastLoop.ts, generated/**, *.min.js,
  dist/**, .next/**, node_modules/**, tests/**, scripts/**

Layer 3 — Confidence grading (bias toward the safer grade):
  High: measured bottleneck + standard transform (WebP, lazy, dedup) -> auto apply.
  Medium: profile exists but expected impact <10% or readability hit -> user confirm.
  Low: no measurement, "seems slow", speculative -> do not act; measure first.

Layer 4 — Pre-action self-check (any NO => STOP):
  1. Baseline numbers collected? (Lighthouse / Profiler / benchmark)
  2. Inside Top 5 bottlenecks?
  3. Budget exceeded and budget stated?
  4. Can verify Before/After under same conditions?

Layer 5 — Mandatory-ask triggers:
  - Touching any `@perf-hot-path` marker
  - Expected improvement < 3%
  - Major readability sacrifice
  - Adding a new dependency (bundle + learning cost)
  - Algorithm swap (O(n^2) -> O(n log n))
  - Micro-optimizations without benchmark (loop unrolling, manual hoist)
  - Introducing Web Worker / Worklet (architectural shift)
</safety_net>

<false_positives>
| Situation | AI will misjudge as | Actually |
|---|---|---|
| `const` not hoisted out of loop | "move it outside" | V8 JIT already handles |
| `for (let i=0;i<arr.length;i++)` | "cache length" | V8 auto-optimizes (post-2017) |
| Multiple `useState` calls | "merge" | React 18 auto-batches |
| Small fn lacking useMemo | "add useMemo" | Compare cost > savings |
| Plain `<img>` | "use Next/Image" | Unnecessary unless LCP element |
| Chained `.map()` calls | "collapse into reduce" | V8 optimized + readability loss |
| List <50 items | "virtualize" | Overhead > savings |
| Sync localStorage (<1KB) | "use IndexedDB" | localStorage faster at that size |

Any match => 🔴 Low confidence, require measurement.
</false_positives>

<execution_rules>
1. No optimization without measurement — not one line.
2. No "I think this might be slow" — prove it.
3. No `useMemo`/`memo` spam — Profiler evidence required.
4. One session = one optimization; batching hides cause.
5. Readability sacrifice => `// PERF:` comment with numbers.
6. Every commit carries Before/After numbers (`perf: T1 memoize UserList — LCP 2.4s->1.8s`).
7. Preserve CRAFT; structural beauty must survive.
8. Effect < 70% of expected => consider rollback.
9. Save Lighthouse reports to `.perf-history/YYYYMMDD-{baseline|after}.json`.
10. Budget reached => STOP further optimization.
</execution_rules>

<priority_by_vitals>
Tie every effort to user-perceived metrics:
- LCP: images, fonts, above-fold content first.
- INP/FID: JS execution length, main-thread blocking.
- CLS: reserve space for images/ads, avoid late-inserted layout.
Work that does not move these three is deprioritized.
</priority_by_vitals>

<report_template>
## PERF Audit Report
Baseline (measured):
  Lighthouse Desktop/Mobile: Perf score, LCP, FID/INP, CLS.
  Bundle gzipped size + top deps with bytes.
  Profiler: top render name + ms.
Budget deltas: current vs target, over/under.
Top 5 bottlenecks with expected deltas.
"Proceed? (Top 3 / all / reorder)"

Per optimization:
  Before metrics -> Change summary -> After metrics (% delta) -> Budget met? -> CRAFT impact.
</report_template>

<order_with_craft>
1. CRAFT first (clean structure).
2. Measure baseline.
3. Only if over budget, enter PERF.
4. Verify with numbers.
5. Confirm readability preserved.
6. Safety Net always on.
</order_with_craft>

<north_star>
Measure, touch only painful spots, prove with numbers.
Unmeasured optimization is superstition; readability-breaking optimization is a crime.
Touching already-optimized code is the greatest sin — respect `@perf-optimized`.
</north_star>
