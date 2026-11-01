# Engineering Log

One entry per PRD. Test results are as recorded at the time of each story; the current suite is `node --test tests/*.test.mjs` (29 passing).

## FEAT-001: Synthetic mortality table and survival engine

- Date: 2026-11-01 (completed 19:00)
- Decisions: Gompertz-Makeham table `q(x) = min(1, A + B * exp(C * x))` with fixed q(0) and q(120) = 1, generated deterministically by `tools/generate-table.mjs` and committed as `data/mortality.csv`. The engine (`src/engine/table.mjs`, `src/engine/survival.mjs`) is pure: no DOM, fetch or fs. Fractional survivor counts, no rounding. An independent Python check (`tools/reference.py`, written without reading the JS) produces `data/reference.json`, which the JS engine must match.
- PRD corrections made by a human during the feature: the age-80 male expected value (0.06196 became 0.06015) and the age-30 male sanity bound (990000 became 980000). The formula was not changed.
- Test command and result: `node --test tests/*.test.mjs`, 23 of 23 passing at completion (the suite then held the table, survival and reference tests).
- Known limitations: the table is synthetic and illustrative. `node --test tests/` (directory form) fails on Node 21 and later.

## FEAT-002: Page shell, survival chart and controls

- Date: 2026-11-01 (completed 18:20)
- Decisions: `src/app.mjs` holds one state object, fetches `data/mortality.csv`, and computes the baseline with `survivors(1000000, table[sex], startAge)`. Playback advances one year per 250 ms in a `requestAnimationFrame` loop, not `setInterval`. Start age is clamped to 0 to 90. `src/chart.mjs` draws the survival curve on canvas from the engine's array.
- Test command and result: `node --test tests/*.test.mjs`, 23 of 23 passing at the time of the chart story. Browser checks used headless Chrome (`--dump-dom`) and a scratch copy with a `requestAnimationFrame` polyfill.
- Known limitations: real `requestAnimationFrame` playback was not observed in a browser, because headless Chrome does not pump it. Play, pause and reset were checked against a polyfilled scratch copy only.

## FEAT-003: The million lives particle field

- Date: 2026-11-01 (completed with FEAT-003 US-002 at 21:00)
- Decisions: `src/particles.mjs` draws 1,000 display particles. `visibleCount(lx, l0, total)` = `Math.round(total * lx / l0)` maps the engine's survivors onto them. `Math.random` is used only for initial particle placement and drift phase, never for survivor counts. Dying particles fade and shrink over 400 ms. The field loop runs for the page's life, so particles drift while paused.
- Test command and result: `node --test tests/*.test.mjs`, 29 of 29 passing at completion.
- Known limitations: the browser criteria (thinning between ages 75 and 100 while playing from 60, reset within one frame, drift while paused, 50 fps) rest on the code path and were not observed in a real browser.

## FEAT-004: Mortality improvement scenario

- Date: 2026-11-01
- Decisions: a range slider (0 to 30%, step 1) sets `pct`. `state.improved = survivors(COHORT, applyImprovement(table[sex], pct), startAge)` is recomputed on sex, start age and slider change. The chart shows two series (baseline blue, improved orange) and a legend only when the improvement is above 0. The statistic `#extra` shows the improved survivors minus the baseline, rounded, and shows a dash at 0%. Slider changes do not move the current age.
- Test command and result: `node --test tests/*.test.mjs`, 29 of 29 passing. Engine check (scratch script, not committed): improved l(x) exceeds baseline l(x) at every age after start age for male and female at starts 0, 30 and 60.
- Known limitations: the slider and the per-frame `#extra` updates were not driven in a real browser. Headless Chrome cannot drag the slider or pump the animation frame. The screenshot at 30% was taken from a preset value in a scratch copy.

## FEAT-005: Cinematic presentation and README

- Date: 2026-11-01 (completed with US-002 at 17:27; US-003 is this README and log)
- Decisions: dark theme (`#05070d` background, light text), large clamped type for the age and survivor figures, a 60/40 field-and-panel layout, and a title over the field that fades on Play and returns on Reset. The title's font size is capped at 16cqw, a deliberate deviation from the spec's 10vw cap, so that it stays inside the field at 1280x720. The disclaimer is fixed at the bottom of every view. Polish touches only `index.html`, `styles.css` and `src/app.mjs`, never `src/engine/`.
- Test command and result: `node --test tests/*.test.mjs`, 29 of 29 passing. `node --check src/app.mjs` passes.
- Known limitations: layout was measured at viewport heights of 993 px and 633 px (browser chrome included), not exactly 1080 and 720. The title fade and the look on a projector were not seen by eye.

## Human checks

- FEAT-002 US-002: Press Play, Pause and Reset in a real browser; the age advances about 4 years per second and holds on Pause.
- FEAT-003 US-001: Play from 0 on a real browser; all particles are visible at age 0 and none at age 121.
- FEAT-003 US-002: Play from 60 with the field visible; thinning is visible between ages 75 and 100. Reset restores all particles within one frame. Pause keeps the living particles drifting.
- FEAT-004 US-001: Move the mortality improvement slider while playing; the curves change and #age does not change.
- FEAT-004 US-002: Play with the slider at 30%; #extra grows as the age advances and updates every frame while playing.
- FEAT-004 US-002: At age 85, male, 10% improvement, #extra shows the same value as the engine check (+39,590 at the time of the check; the browser value was not observed).
- FEAT-005 US-002: The title fade on Play and Reset (600 ms) looks right in a real browser.
- FEAT-005 US-001: The layout looks right on the projector at its real resolution.
