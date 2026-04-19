---
paths:
  - "src/**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "app/**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "next.config.*"
  - "vite.config.*"
  - "webpack.config.*"
---

# Rule: PERF Safety Net (path-scoped)

Loaded automatically when Claude reads or edits source files, Next/Vite/Webpack configs.

## Measurement gate

<measurement_required>
Before ANY performance-motivated edit, all 4 must be YES:
1. Baseline numbers exist (Lighthouse report, Profiler snapshot, bundle analysis, or benchmark)
2. The change targets a Top 5 bottleneck identified from those numbers
3. A performance budget is stated (project-local or PERF.md `<perf_budget>` defaults)
4. Before/After can be re-measured under the same conditions

Any NO → refuse to edit. Ask the user to produce baseline measurements first.
</measurement_required>

## Forbidden without measurement

- Adding `React.memo`, `useMemo`, `useCallback` — require Profiler evidence of re-render cost
- Replacing a dependency for "bundle size" — require `vite-bundle-visualizer` output
- Adding virtualization — require list size and current render time
- Algorithm swaps — require benchmark comparing old vs new
- Loop unrolling / manual hoisting — require benchmark
- Web Worker introduction — require user approval (architectural shift)

## False-positive mandatory check

Before flagging any pattern from PERF.md `<anti_patterns>`, cross-check PERF.md `<false_positives>` catalog. On any match, refuse to act and request measurement.

## Marker respect

Never edit code with these markers:
- `@perf-optimized reason="..."`
- `@perf-hot-path reason="..."`
- `@perf-measured date="..." baseline="..."`
- `@perf-benchmarked reason="..."`

Editing these regresses intentional, measured performance work.

## Commit format

```
perf: T<N> <summary> — <metric> <before>→<after>
```
Example: `perf: T7 moment→date-fns — bundle 680KB→398KB`

## Behavior

- Baseline measurements required before any change
- One optimization per commit
- Before/After numbers in every commit message
- Save Lighthouse reports to `.perf-history/YYYYMMDD-<baseline|after>.json`
- Rollback if effect < 70% of predicted
