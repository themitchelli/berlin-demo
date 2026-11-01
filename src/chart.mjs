// Survival curve on canvas. Display only: it draws the arrays it is given and
// computes nothing about mortality.
//
// drawChart(canvas, series, currentAge, startAge)
//   series: array of { values, colour }. values[i] is the survivor count at age startAge + i
//           and the final element is age 121.
//   currentAge: age for the marker, drawn on the first series.

const BG_COLOUR = '#0b0f14';
const AXIS_COLOUR = '#5a6672';
const LABEL_COLOUR = '#c9d1d9';
const MARKER_COLOUR = '#ffffff';
const COHORT = 1000000;
const END_AGE = 121;
const AGE_TICK_EVERY = 20;
const COUNT_TICK_EVERY = 200000;
const MARGIN = { left: 70, right: 20, top: 20, bottom: 40 };

function formatCount(n) {
  return n === 0 ? '0' : `${n / 1000}k`;
}

export function drawChart(canvas, series, currentAge, startAge) {
  const ctx = canvas.getContext('2d');
  const width = canvas.width;
  const height = canvas.height;

  ctx.fillStyle = BG_COLOUR;
  ctx.fillRect(0, 0, width, height);

  const plotLeft = MARGIN.left;
  const plotRight = width - MARGIN.right;
  const plotTop = MARGIN.top;
  const plotBottom = height - MARGIN.bottom;
  const plotW = plotRight - plotLeft;
  const plotH = plotBottom - plotTop;
  const ageSpan = END_AGE - startAge;

  const xOf = (age) => plotLeft + ((age - startAge) / ageSpan) * plotW;
  const yOf = (count) => plotBottom - (count / COHORT) * plotH;

  // Axes
  ctx.strokeStyle = AXIS_COLOUR;
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(plotLeft, plotTop);
  ctx.lineTo(plotLeft, plotBottom);
  ctx.lineTo(plotRight, plotBottom);
  ctx.stroke();

  ctx.fillStyle = LABEL_COLOUR;
  ctx.font = '12px sans-serif';

  // X ticks: every 20 years, from the first multiple of 20 at or after startAge.
  ctx.textAlign = 'center';
  ctx.textBaseline = 'top';
  for (let age = Math.ceil(startAge / AGE_TICK_EVERY) * AGE_TICK_EVERY; age <= END_AGE; age += AGE_TICK_EVERY) {
    const x = xOf(age);
    ctx.beginPath();
    ctx.moveTo(x, plotBottom);
    ctx.lineTo(x, plotBottom + 5);
    ctx.stroke();
    ctx.fillText(String(age), x, plotBottom + 8);
  }

  // Y ticks: every 200,000 from 0 to 1,000,000.
  ctx.textAlign = 'right';
  ctx.textBaseline = 'middle';
  for (let count = 0; count <= COHORT; count += COUNT_TICK_EVERY) {
    const y = yOf(count);
    ctx.beginPath();
    ctx.moveTo(plotLeft - 5, y);
    ctx.lineTo(plotLeft, y);
    ctx.stroke();
    ctx.fillText(formatCount(count), plotLeft - 8, y);
  }

  // Survival curves, 2px lines.
  ctx.lineWidth = 2;
  for (const { values, colour } of series) {
    ctx.strokeStyle = colour;
    ctx.beginPath();
    values.forEach((count, i) => {
      const x = xOf(startAge + i);
      const y = yOf(count);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    });
    ctx.stroke();
  }

  // Current-age marker on the first series.
  if (series.length > 0 && currentAge >= startAge && currentAge <= END_AGE) {
    const first = series[0];
    const x = xOf(currentAge);
    const count = first.values[currentAge - startAge];

    ctx.strokeStyle = MARKER_COLOUR;
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(x, plotTop);
    ctx.lineTo(x, plotBottom);
    ctx.stroke();

    ctx.fillStyle = first.colour;
    ctx.beginPath();
    ctx.arc(x, yOf(count), 6, 0, Math.PI * 2);
    ctx.fill();
  }
}
