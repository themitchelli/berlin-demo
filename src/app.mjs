// Wiring only: reads controls, asks the engine for numbers, writes them to the page.
// The engine is the only source of survivor counts.

import { parseTable } from './engine/table.mjs';
import { survivors } from './engine/survival.mjs';

const COHORT = 1000000;
const MIN_START_AGE = 0;
const MAX_START_AGE = 90;

const els = {
  sex: document.getElementById('sex'),
  startAge: document.getElementById('startAge'),
  age: document.getElementById('age'),
  alive: document.getElementById('alive'),
  pct: document.getElementById('pct'),
};

const state = {
  table: null,
  sex: 'male',
  startAge: 0,
  improvement: 0,
  currentAge: 0,
  playing: false,
  baseline: [],
};

function readStartAge() {
  const n = Math.trunc(Number(els.startAge.value));
  if (!Number.isFinite(n)) return MIN_START_AGE;
  return Math.min(MAX_START_AGE, Math.max(MIN_START_AGE, n));
}

function recomputeBaseline() {
  state.sex = els.sex.value;
  state.startAge = readStartAge();
  els.startAge.value = String(state.startAge);
  state.currentAge = state.startAge;
  state.baseline = survivors(COHORT, state.table[state.sex], state.startAge);
}

function survivorsAt(age) {
  return state.baseline[age - state.startAge];
}

function render() {
  const alive = survivorsAt(state.currentAge);
  els.age.textContent = `Age ${state.currentAge}`;
  els.alive.textContent = Math.round(alive).toLocaleString('en-GB');
  els.pct.textContent = `${((alive / COHORT) * 100).toFixed(1)}%`;
}

function onSettingChange() {
  recomputeBaseline();
  render();
}

async function init() {
  const response = await fetch('data/mortality.csv');
  if (!response.ok) {
    throw new Error(`Could not load data/mortality.csv (HTTP ${response.status})`);
  }
  state.table = parseTable(await response.text());
  onSettingChange();
}

els.sex.addEventListener('change', onSettingChange);
els.startAge.addEventListener('change', onSettingChange);

init().catch((err) => {
  console.error(err);
  els.age.textContent = 'Could not load the mortality table. Serve this folder over HTTP.';
});
