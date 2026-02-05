
/**
 * Validates if a date string (YYYY-MM-DD) is a Friday
 * @param {string} dateStr - Date in YYYY-MM-DD format
 * @returns {boolean} - True if Friday, false otherwise
 */
function isFriday(dateStr) {
    const date = new Date(dateStr);
    return date.getDay() === 5; // 5 = Friday
}

/**
 * Validates if a date string (YYYY-MM-DD) is a working day (Sat-Thu)
 * @param {string} dateStr - Date in YYYY-MM-DD format
 * @returns {boolean} - True if working day, false if Friday
 */
function isWorkingDay(dateStr) {
    return !isFriday(dateStr);
}

module.exports = {
    isFriday,
    isWorkingDay,
};
