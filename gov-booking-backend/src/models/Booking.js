
const mongoose = require("mongoose");

const BookingSchema = new mongoose.Schema(
  {
    bookingCode: { type: String, required: true, unique: true },
    citizenId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    officeId: { type: mongoose.Schema.Types.ObjectId, ref: "Office", required: true },
    serviceId: { type: mongoose.Schema.Types.ObjectId, ref: "Service", required: true },

    date: { type: String, required: true },   // "2026-02-05"
    slot: { type: String, required: true },   // "09:30 AM"
    note: { type: String, default: "" },

    status: { type: String, enum: ["PENDING", "APPROVED", "REJECTED", "COMPLETED"], default: "PENDING" },
    adminNote: { type: String, default: "" }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Booking", BookingSchema);
