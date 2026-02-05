const Booking = require("../models/Booking");
const Counter = require("../models/Counter");
const { makeBookingCode } = require("../utils/bookingCode");

exports.create = async (req, res) => {
  const { officeId, serviceId, date, slot, note } = req.body;
  const citizenId = req.user.id;
  const year = new Date().getFullYear();
  const counterKey = `booking-${year}`;

  // Align counter with historical booking codes if data existed before Counter records.
  const latestForYear = await Booking.findOne({
    bookingCode: { $regex: `^GOV-${year}-` },
  })
    .sort({ bookingCode: -1 })
    .select("bookingCode")
    .lean();

  const latestSeq = (() => {
    if (!latestForYear || !latestForYear.bookingCode) return 0;
    const parts = String(latestForYear.bookingCode).split("-");
    const n = Number(parts[2]);
    return Number.isFinite(n) ? n : 0;
  })();

  if (latestSeq > 0) {
    await Counter.findOneAndUpdate(
      { key: counterKey },
      { $max: { seq: latestSeq } },
      { upsert: true }
    );
  }

  let attempts = 0;

  while (attempts < 5) {
    attempts += 1;

    const counter = await Counter.findOneAndUpdate(
      { key: counterKey },
      { $inc: { seq: 1 } },
      { new: true, upsert: true }
    );

    try {
      const booking = await Booking.create({
        bookingCode: makeBookingCode(year, counter.seq),
        citizenId,
        officeId,
        serviceId,
        date,
        slot,
        note: note || "",
      });

      return res.status(201).json({ success: true, data: booking });
    } catch (e) {
      // If bookingCode collides with historical data, retry with next sequence.
      if (e && e.code === 11000 && e.keyPattern && e.keyPattern.bookingCode) {
        continue;
      }
      throw e;
    }
  }

  res.status(500).json({ success: false, message: "Could not generate unique booking code" });
};

exports.myBookings = async (req, res) => {
  const citizenId = req.user.id;
  const items = await Booking.find({ citizenId })
    .populate("officeId")
    .populate("serviceId")
    .sort({ createdAt: -1 });

  res.json({ success: true, data: items });
};

exports.adminAll = async (req, res) => {
  const items = await Booking.find()
    .populate("citizenId")
    .populate("officeId")
    .populate("serviceId")
    .sort({ createdAt: -1 });

  res.json({ success: true, data: items });
};

exports.setStatus = async (req, res) => {
  const { status, adminNote } = req.body; // APPROVED / REJECTED
  const b = await Booking.findByIdAndUpdate(
    req.params.id,
    { status, adminNote: adminNote || "" },
    { new: true }
  );

  res.json({ success: true, data: b });
};
