---
description: Baseline measurements + Top 5 bottlenecks per PERF.md (measurement-only, no edits)
---

Read `PERF.md` from the project root. Then delegate to the `perf-specialist` subagent with the following brief:

Perform a read-only Brownfield Phase 0 baseline on: $ARGUMENTS (defaults to the whole project).

Steps:
1. Check whether the project is runnable (`npm run dev` / `npm run build` / equivalent). If not, stop and ask the user to make it runnable first.
2. Instruct the user to run (do not run yourself unless you are certain it is safe):
   - `npx lighthouse <url> --view --preset=desktop`
   - `npx lighthouse <url> --view --preset=mobile`
   - `npm run build && npx vite-bundle-visualizer` (or `source-map-explorer`)
   - React DevTools Profiler: record a representative interaction
3. Collect the numbers: LCP, FID/INP, CLS, TTI, bundle (gzipped), top 5 deps by size, top 5 renders by duration
4. Compare against the `<perf_budget>` block; flag anything over budget
5. Rank Top 5 bottlenecks by Impact × User-pain
6. For each: state What / Where / Why / Fix hypothesis + expected delta
7. Exclude anything in `.perfignore` or with `@perf-optimized` / `@perf-hot-path` markers
8. Return the `<report_template>` populated — DO NOT EDIT ANY FILES

End the report with: "Proceed? (Top 3 first / all / reorder)"
