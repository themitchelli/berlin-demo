// Wiring only: reads controls, asks the engine for numbers, writes them to the page.
// The engine is the only source of survivor counts.

import { parseTable } from './engine/table.mjs';
import { survivors, applyImprovement } from './engine/survival.mjs';
import { drawChart } from './chart.mjs';
import { createField, update as updateField, visibleCount } from './particles.mjs';

const COHORT = 1000000;
const PARTICLES = 1000;
const MIN_START_AGE = 0;
const MAX_START_AGE = 90;
const END_AGE = 121; // one past the terminal age 120; survivors here are 0
const STEP_MS = 250; // time per simulated year while playing
const BASELINE_COLOUR = '#7fd1ff';
const IMPROVED_COLOUR = '#ffb347';

const els = {
  sex: document.getElementById('sex'),
  startAge: document.getElementById('startAge'),
  improvement: document.getElementById('improvement'),
  improvementValue: document.getElementById('improvementValue'),
  legend: document.getElementById('legend'),
  age: document.getElementById('age'),
  alive: document.getElementById('alive'),
  pct: document.getElementById('pct'),
  aliveImproved: document.getElementById('aliveImproved'),
  extra: document.getElementById('extra'),
  play: document.getElementById('play'),
  pause: document.getElementById('pause'),
  reset: document.getElementById('reset'),
  chart: document.getElementById('chart'),
  field: document.getElementById('field'),
};

let field = null;
let fieldLastTs = null;
let rafId = null;
let lastTs = null;
let accumulatedMs = 0;

const state = {
  table: null,
  sex: 'male',
  startAge: 0,
  improvement: 0,
  currentAge: 0,
  playing: false,
  baseline: [],
  improved: [],
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
  recomputeImproved();
}

// The improved curve is always the engine's survivors under the current slider value.
// At 0 it is not drawn, so it is only computed when the slider is above 0.
function recomputeImproved() {
  if (state.improvement === 0) {
    state.improved = [];
    return;
  }
  const qx = applyImprovement(state.table[state.sex], state.improvement);
  state.improved = survivors(COHORT, qx, state.startAge);
}

function onImprovementInput() {
  state.improvement = Number(els.improvement.value) / 100;
  els.improvementValue.textContent = `${els.improvement.value}%`;
  recomputeImproved();
  render();
}

function survivorsAt(age) {
  return state.baseline[age - state.startAge];
}

function render() {
  const alive = survivorsAt(state.currentAge);
  els.age.textContent = `Age ${state.currentAge}`;
  els.alive.textContent = Math.round(alive).toLocaleString('en-GB');
  els.pct.textContent = `${((alive / COHORT) * 100).toFixed(1)}%`;
  if (state.improvement > 0) {
    const improvedAlive = state.improved[state.currentAge - state.startAge];
    els.aliveImproved.textContent = Math.round(improvedAlive).toLocaleString('en-GB');
    const diff = Math.round(improvedAlive - alive);
    els.extra.textContent = `${diff < 0 ? '-' : '+'}${Math.abs(diff).toLocaleString('en-GB')}`;
  } else {
    els.aliveImproved.textContent = '—';
    els.extra.textContent = '—';
  }
  const series = [{ values: state.baseline, colour: BASELINE_COLOUR }];
  if (state.improvement > 0) {
    series.push({ values: state.improved, colour: IMPROVED_COLOUR });
  }
  els.legend.hidden = state.improvement === 0;
  drawChart(els.chart, series, state.currentAge, state.startAge);
}

// Canvas pixel width follows its CSS width so the chart stays sharp and legible.
function syncCanvasSize() {
  const cssWidth = els.chart.clientWidth;
  if (cssWidth > 0 && els.chart.width !== cssWidth) els.chart.width = cssWidth;
}

// Runs for the life of the page, playing or not. It only draws the engine's current
// survivor count as particles; it never computes mortality.
function fieldFrame(ts) {
  if (fieldLastTs === null) fieldLastTs = ts;
  const dtMs = ts - fieldLastTs;
  fieldLastTs = ts;
  if (field && state.baseline.length > 0) {
    const aliveCount = visibleCount(survivorsAt(state.currentAge), COHORT, PARTICLES);
    updateField(field, aliveCount, dtMs);
  }
  requestAnimationFrame(fieldFrame);
}

function onResize() {
  syncCanvasSize();
  render();
}

function stopPlaying() {
  state.playing = false;
  if (rafId !== null) cancelAnimationFrame(rafId);
  rafId = null;
  lastTs = null;
  accumulatedMs = 0;
}

// Accumulates real elapsed time and advances one year per STEP_MS.
// Uses requestAnimationFrame and performance.now(); no setInterval.
function tick() {
  rafId = null;
  if (!state.playing) return;

  const now = performance.now();
  if (lastTs === null) lastTs = now;
  accumulatedMs += now - lastTs;
  lastTs = now;

  while (accumulatedMs >= STEP_MS && state.playing) {
    accumulatedMs -= STEP_MS;
    state.currentAge += 1;
    if (state.currentAge >= END_AGE) {
      state.currentAge = END_AGE;
      stopPlaying();
    }
  }

  render();
  if (state.playing) rafId = requestAnimationFrame(tick);
}

function play() {
  if (state.playing || state.baseline.length === 0) return;
  if (state.currentAge >= END_AGE) state.currentAge = state.startAge;
  state.playing = true;
  lastTs = null;
  accumulatedMs = 0;
  rafId = requestAnimationFrame(tick);
}

function pause() {
  stopPlaying();
}

function reset() {
  stopPlaying();
  state.currentAge = state.startAge;
  render();
}

function onSettingChange() {
  stopPlaying();
  recomputeBaseline();
  render();
}

async function init() {
  const response = await fetch('data/mortality.csv');
  if (!response.ok) {
    throw new Error(`Could not load data/mortality.csv (HTTP ${response.status})`);
  }
  state.table = parseTable(await response.text());
  // Browsers may restore a slider position on reload; the state must follow the control.
  state.improvement = Number(els.improvement.value) / 100;
  els.improvementValue.textContent = `${els.improvement.value}%`;
  syncCanvasSize();
  onSettingChange();
  field = createField(els.field, PARTICLES);
  requestAnimationFrame(fieldFrame);
}

window.addEventListener('resize', onResize);
els.sex.addEventListener('change', onSettingChange);
els.startAge.addEventListener('change', onSettingChange);
els.improvement.addEventListener('input', onImprovementInput);
els.play.addEventListener('click', play);
els.pause.addEventListener('click', pause);
els.reset.addEventListener('click', reset);

init().catch((err) => {
  console.error(err);
  els.age.textContent = 'Could not load the mortality table. Serve this folder over HTTP.';
});
