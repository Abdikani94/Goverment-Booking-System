
const mongoose = require("mongoose");

const TimeSlotSchema = new mongoose.Schema(
  {
    officeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Office",
      required: true,
      index: true,
    },

    // format: "YYYY-MM-DD"
    date: { type: String, required: true, index: true },

    // format: "HH:MM"
    startTime: { type: String, required: true },
    endTime: { type: String, required: true },

    capacity: { type: Number, required: true, min: 1 },
    bookedCount: { type: Number, default: 0, min: 0 },

    status: { type: String, enum: ["open", "closed"], default: "open" },
  },
  { timestamps: true },
);

// prevent duplicates for same office/date/startTime //

TimeSlotSchema.index({ officeId: 1, date: 1, startTime: 1 }, { unique: true });

module.exports = mongoose.model("TimeSlot", TimeSlotSchema);
