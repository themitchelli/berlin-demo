# Testing standard

- Tests run with `node --test tests/`. No other runner.
- The engine (`src/engine/`) must have tests for:
  1. Every q(x) in the table is between 0 and 1 inclusive, and q(120) = 1.
  2. Survivor counts never increase with age.
  3. Zero mortality produces no deaths.
  4. Certain mortality (q = 1) at an age produces zero survivors from the next age on.
  5. Improved mortality never produces fewer survivors than baseline at any age.
  6. The survivor count at the starting age equals the cohort size.
  7. Survivors reach zero after the terminal age.
  8. Survivor counts at the ages listed in `data/reference.json` match to within 0.5 of a life.
- Never set a story to `passes: true` unless its tests ran in this session and passed. Paste the test command and the summary line into `fade/progress.md`.
- Never edit `data/reference.json` or `tools/reference.py`. If they disagree with the engine, the engine is wrong.
- A test that always passes (`assert.ok(true)`, `1 === 1`) is a defect.
