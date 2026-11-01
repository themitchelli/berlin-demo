#!/usr/bin/env python3
"""Independent reference check for the survival engine.

Standard library only. Reads data/mortality.csv (skipping '#' comment lines and
the header), computes l(0) = 1000000 and l(x+1) = l(x) * (1 - q(x)) with plain
floats, and writes data/reference.json with unrounded values at ages 30, 65, 90
and 110 for both sexes.

This script must not read or import any JavaScript. Its job is to be an
independent calculation. If tests/reference.test.mjs disagrees with it, the JS
engine is wrong until a human says otherwise.

Terminal age convention: q(120) = 1. Everyone alive at 120 dies in that year.

Run from the repository root:  python3 tools/reference.py
"""

import json
import os

COHORT = 1000000
REFERENCE_AGES = [30, 65, 90, 110]
TERMINAL_AGE = 120

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
CSV_PATH = os.path.join(ROOT, 'data', 'mortality.csv')
OUT_PATH = os.path.join(ROOT, 'data', 'reference.json')


def read_rates(path):
    """Return (male, female) lists of q(x), indexed by age 0..120."""
    male = {}
    female = {}
    with open(path, 'r', encoding='utf-8') as handle:
        for raw in handle:
            line = raw.strip()
            if line == '' or line.startswith('#'):
                continue
            cells = line.split(',')
            if cells[0].strip() == 'age':
                continue
            age = int(cells[0])
            male[age] = float(cells[1])
            female[age] = float(cells[2])
    male_list = [male[age] for age in range(TERMINAL_AGE + 1)]
    female_list = [female[age] for age in range(TERMINAL_AGE + 1)]
    return male_list, female_list


def survivors_at(qx):
    """Return the list l where l[x] is the count alive at age x, for x = 0..121."""
    lx = [float(COHORT)]
    for age in range(TERMINAL_AGE + 1):
        lx.append(lx[age] * (1.0 - qx[age]))
    return lx


def main():
    male_q, female_q = read_rates(CSV_PATH)
    male_l = survivors_at(male_q)
    female_l = survivors_at(female_q)

    result = {
        'male': {str(age): male_l[age] for age in REFERENCE_AGES},
        'female': {str(age): female_l[age] for age in REFERENCE_AGES},
    }

    with open(OUT_PATH, 'w', encoding='utf-8') as handle:
        json.dump(result, handle, indent=2)
        handle.write('\n')

    print(f'wrote {OUT_PATH}')


if __name__ == '__main__':
    main()
