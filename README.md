# The Million Lives Experiment

## What this is

An interactive page for a conference talk to actuaries. One million simulated people start at a chosen age and are followed towards 120. A survival curve and the surviving population update as the age advances. A slider applies a mortality improvement and shows the baseline and improved scenarios side by side.

The mortality table is synthetic and illustrative. The calculation is deterministic and lives in `src/engine/`. The particle field is a display of the engine's numbers: it takes survivor counts from the engine and introduces no randomness into the calculation.

## The maths

Survival from one age to the next:

    l(x+1) = l(x) * (1 - q(x))

Mortality improvement, where pct is between 0 and 0.30:

    qImproved(x) = (1 - pct) * q(x)

Terminal age convention: q(120) = 1. Everyone alive at 120 dies in that year, so the survivor count at age 121 is 0.

The synthetic table is generated from a Gompertz-Makeham form, `q(x) = min(1, A + B * exp(C * x))`, with a fixed q(0) and q(120) = 1. See `tools/generate-table.mjs`.

## Run it

Requires Node 20 or later and Python 3 (for the static server only). No npm install is needed.

```
python3 -m http.server 8080
```

Then open http://localhost:8080/ in a browser. The page fetches `data/mortality.csv`, so it needs the server; opening `index.html` directly as a file may be blocked by the browser.

## Test it

```
node --test tests/*.test.mjs
```

Use the glob form. On Node 21 and later, `node --test tests/` is treated as a file path and fails.

## Regenerate the table

```
node tools/generate-table.mjs
python3 tools/reference.py
```

The first command writes `data/mortality.csv`. The second writes `data/reference.json`, the independent check of a few survivor values. Both files are generated; do not edit them by hand.

## Disclaimer

Synthetic mortality assumptions for illustration only. Not for real actuarial use.
