
function pad2(n) {
  return String(n).padStart(2, "0");
}

// "09:30" -> 570 minutes
function timeToMinutes(t) {
  const [hh, mm] = t.split(":").map(Number);
  return hh * 60 + mm;
}

// 570 -> "09:30"
function minutesToTime(m) {
  const hh = Math.floor(m / 60);
  const mm = m % 60;
  return `${pad2(hh)}:${pad2(mm)}`;
}

// Date object -> "YYYY-MM-DD"
function toYMD(dateObj) {
  const y = dateObj.getFullYear();
  const m = pad2(dateObj.getMonth() + 1);
  const d = pad2(dateObj.getDate());
  return `${y}-${m}-${d}`;
}

// "YYYY-MM-DD" -> Date object (local)
function fromYMD(ymd) {
  const [y, m, d] = ymd.split("-").map(Number);
  return new Date(y, m - 1, d);
}

// JS day -> our code
// JS: 0 Sun,1 Mon,2 Tue,3 Wed,4 Thu,5 Fri,6 Sat
function dayCode(dateObj) {
  const map = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
  return map[dateObj.getDay()];
}

module.exports = {
  timeToMinutes,
  minutesToTime,
  toYMD,
  fromYMD,
  dayCode,
};
