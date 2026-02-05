
const mongoose = require("mongoose");

const ServiceSchema = new mongoose.Schema(
  {
    officeId: { type: mongoose.Schema.Types.ObjectId, ref: "Office", required: true },
    name: { type: String, required: true, trim: true },
    requiredDocs: { type: [String], default: [] },
    isActive: { type: Boolean, default: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model("Service", ServiceSchema);
