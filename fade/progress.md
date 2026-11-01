<!-- FADE progress.md v0.3.1 -->

# Progress Log

Session history for this project. Append-only.

<!--
Entry format (append new entries below the line):

## YYYY-MM-DD HH:MM - US-XXX: Story Title - COMPLETE

- Summary of what was implemented
- Files changed: list key files
- Tests: passed/added

For blocked stories, use:

## YYYY-MM-DD HH:MM - US-XXX: Story Title - BLOCKED

- What was attempted
- What's blocking progress
- Suggested resolution
-->

---

## 2026-11-01 17:11 - US-001: Generate data/mortality.csv - BLOCKED

- Implemented tools/generate-table.mjs per the stated formula q(x) = min(1, A + B*exp(C*x)), with fixed q(0) and q(120)=1, and generated data/mortality.csv.
- Verified: 123 lines (comment, header, 121 rows); row 0 is 0.00400000 / 0.00350000; row 120 is 1.00000000 / 1.00000000; two runs are byte-identical (cmp); q(x) is non-decreasing for x=1..119 for both sexes.
- Blocking discrepancy: the acceptance criterion says male age 80 should be 0.06196 "(0.0002 + 0.00003 * exp(7.6))", but that expression evaluates to 0.06014588. The formula and the number cannot both hold. Story left passes: false.
- Suggested resolution: a human decides whether the constants (e.g. B or C) or the expected value 0.06196 is the intended one. Once decided, update the PRD text, regenerate the CSV, and rerun the checks. data/reference.json is not yet created (US-004), so no off-limits file was touched.

## 2026-11-01 17:12 - US-001: Generate data/mortality.csv - COMPLETE

- Generator tools/generate-table.mjs already matched the corrected PRD (age-80 male expected 0.06015; formula gives 0.06014588). Verified without changes to code or data.
- Files changed: fade/prds/FEAT-001-mortality-table-and-engine.json (US-001 passes: true), fade/progress.md
- Tests: all five acceptance criteria checked by hand: 123 lines; age 0 row 0.00400000/0.00350000; age 120 row 1.00000000/1.00000000; age 80 male 0.06014588; two runs byte-identical (cmp); q(x) <= q(x+1) for x=1..119 for both sexes (0 violations). No automated test file exists yet for this story (node --test tests/ is US-002's scope).

## 2026-11-01 17:13 - US-002: Table loader src/engine/table.mjs - COMPLETE

- Implemented parseTable(csvText) as a pure module: skips # comment lines and the header, returns { male, female } as Float64Array(121). Throws `Missing age N`, `Duplicate age N`, `Rate out of range at age N` per the PRD. No DOM, fetch or fs in src/engine/.
- Files changed: src/engine/table.mjs, tests/table.test.mjs, fade/prds/FEAT-001-mortality-table-and-engine.json (US-002 passes: true), fade/progress.md, fade/learned.md
- Tests: added 5 tests in tests/table.test.mjs (real CSV loads with length 121 and male[0]=0.004; Missing age 50; age 10 male 1.2 rejected; duplicate row; negative rate). Ran `node --test tests/*.test.mjs` (Node v25.5.0): `ℹ tests 5 / ℹ pass 5 / ℹ fail 0`. `node --test tests/` as written in FADE.md errors on Node 21+ (see learned.md).

## 2026-11-01 18:00 - US-003: Survival engine src/engine/survival.mjs - COMPLETE

- Implemented survivors(cohort, qx, startAge) (lx[0] = cohort, lx[i+1] = lx[i] * (1 - q(startAge+i)) through age 120, final element age 121; length 121 - startAge + 1; no rounding) and applyImprovement(qx, pct) (returns a new array of (1 - pct) * q; throws 'pct must be between 0 and 0.3' outside [0, 0.3]). Terminal age convention noted in the module comment.
- Files changed: src/engine/survival.mjs, tests/survival.test.mjs, fade/prds/FEAT-001-mortality-table-and-engine.json (US-003 passes: true), fade/progress.md
- Tests: added 9 tests in tests/survival.test.mjs covering the length/last-element/monotonic checks, q(120)=1 and q(30)=1 copies, applyImprovement 0.9 factor at age 80, improved >= baseline, non-mutation, and both out-of-range throws. Ran `node --test tests/*.test.mjs` (Node v25.5.0): `ℹ tests 14 / ℹ pass 14 / ℹ fail 0`. The directory form `node --test tests/` is not used because of the Node 21+ issue in learned.md.
