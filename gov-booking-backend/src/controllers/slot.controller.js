
const mongoose = require("mongoose");
const Office = require("../models/Office");
const TimeSlot = require("../models/TimeSlot");
const { timeToMinutes, minutesToTime, fromYMD, toYMD, dayCode } = require("../utils/datetime");

// GET /api/offices/:officeId/slots?date=YYYY-MM-DD
exports.getSlotsByOfficeAndDate = async (req, res, next) => {
  try {
    const { officeId } = req.params;
    const { date } = req.query;

    if (!mongoose.Types.ObjectId.isValid(officeId)) {
      res.status(400);
      throw new Error("Invalid officeId format");
    }
    if (!date) {
      res.status(400);
      throw new Error("date query is required (YYYY-MM-DD)");
    }

    const slots = await TimeSlot.find({ officeId, date }).sort({ startTime: 1 });

    res.json({
      success: true,
      message: "Slots fetched successfully",
      data: slots,
    });
  } catch (err) {
    next(err);
  }
};

// POST /api/offices/:officeId/slots/generate
// body: { fromDate, toDate, capacity?, slotDurationMinutes? }
exports.generateSlots = async (req, res, next) => {
  try {
    const { officeId } = req.params;
    const { fromDate, toDate, capacity, slotDurationMinutes } = req.body;

    if (!mongoose.Types.ObjectId.isValid(officeId)) {
      res.status(400);
      throw new Error("Invalid officeId format");
    }
    if (!fromDate || !toDate) {
      res.status(400);
      throw new Error("fromDate and toDate are required (YYYY-MM-DD)");
    }

    const office = await Office.findById(officeId);
    if (!office) {
      res.status(404);
      throw new Error("Office not found");
    }

    const start = fromYMD(fromDate);
    const end = fromYMD(toDate);

    if (start > end) {
      res.status(400);
      throw new Error("fromDate must be before or equal to toDate");
    }

    const openMin = timeToMinutes(office.openTime);
    const closeMin = timeToMinutes(office.closeTime);

    const dur = Number(slotDurationMinutes || office.slotDurationMinutes);
    if (!dur || dur < 5) {
      res.status(400);
      throw new Error("slotDurationMinutes must be >= 5");
    }

    const cap = Number(capacity || office.defaultCapacityPerSlot);
    if (!cap || cap < 1) {
      res.status(400);
      throw new Error("capacity must be >= 1");
    }

    // loop days
    let created = 0;
    let skipped = 0;

    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
      const code = dayCode(d);

      // Only generate on office working days (Saturday -> Thursday by default)
      if (!office.workingDays.includes(code)) continue;

      const dateStr = toYMD(d);

      // generate slots in that day
      for (let t = openMin; t + dur <= closeMin; t += dur) {
        const startTime = minutesToTime(t);
        const endTime = minutesToTime(t + dur);

        try {
          await TimeSlot.create({
            officeId,
            date: dateStr,
            startTime,
            endTime,
            capacity: cap,
          });
          created++;
        } catch (err) {
          // duplicate slot => skip
          if (err.code === 11000) skipped++;
          else throw err;
        }
      }
    }

    res.status(201).json({
      success: true,
      message: "Slot generation completed",
      data: { created, skipped },
    });
  } catch (err) {
    next(err);
  }
};
