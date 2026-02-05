
function pad(n, size) {
  return String(n).padStart(size, "0");
}

// Example output: GOV-2026-000001
function makeBookingCode(year, seq) {
  return `GOV-${year}-${pad(seq, 6)}`;
}

module.exports = { makeBookingCode };
