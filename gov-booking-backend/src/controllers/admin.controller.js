
const bcrypt = require("bcrypt");
const mongoose = require("mongoose");
const User = require("../models/User");
const Office = require("../models/Office");
const Service = require("../models/Service");
const TimeSlot = require("../models/TimeSlot");
const Booking = require("../models/Booking");
const { isWorkingDay } = require("../validations/bookingValidation");

// ============================================
// STATS & REPORTS
// ============================================

// GET /api/admin/stats
exports.getStats = async (req, res, next) => {
  try {
    const [totalCitizens, totalOffices, totalBookings, pendingBookings, approvedBookings, completedBookings, rejectedBookings] = await Promise.all([
      User.countDocuments({ role: "CITIZEN" }),
      Office.countDocuments(),
      Booking.countDocuments(),
      Booking.countDocuments({ status: { $in: ["PENDING", "pending"] } }),
      Booking.countDocuments({ status: { $in: ["APPROVED", "approved"] } }),
      Booking.countDocuments({ status: { $in: ["COMPLETED", "completed"] } }),
      Booking.countDocuments({ status: { $in: ["REJECTED", "rejected"] } }),
    ]);

    res.json({
      success: true,
      message: "Admin statistics fetched",
      data: {
        totalCitizens,
        totalOffices,
        totalBookings,
        pendingBookings,
        approvedBookings,
        completedBookings,
        rejectedBookings,
      },
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/reports/summary?from=YYYY-MM-DD&to=YYYY-MM-DD
exports.getSummaryReport = async (req, res, next) => {
  try {
    const { from, to } = req.query;

    let filter = {};
    if (from || to) {
      filter.createdAt = {};
      if (from) filter.createdAt.$gte = new Date(from);
      if (to) filter.createdAt.$lte = new Date(to);
    }

    const [
      totalBookings,
      statusCounts,
      topServices,
    ] = await Promise.all([
      Booking.countDocuments(filter),
      Booking.aggregate([
        { $match: filter },
        { $group: { _id: "$status", count: { $sum: 1 } } },
      ]),
      Booking.aggregate([
        { $match: filter },
        { $group: { _id: "$serviceId", count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 5 },
        {
          $lookup: {
            from: "services",
            localField: "_id",
            foreignField: "_id",
            as: "service",
          },
        },
        { $unwind: "$service" },
        {
          $project: {
            serviceName: "$service.name",
            count: 1,
          },
        },
      ]),
    ]);

    const statusMap = {};
    statusCounts.forEach((item) => {
      statusMap[item._id] = item.count;
    });

    res.json({
      success: true,
      message: "Summary report fetched",
      data: {
        totalBookings,
        byStatus: statusMap,
        topServices,
      },
    });
  } catch (err) {
    next(err);
  }
};

// ============================================
// OFFICE MANAGEMENT
// ============================================

// POST /api/admin/offices
exports.createOffice = async (req, res, next) => {
  try {
    const { name, location, workingDays, openTime, closeTime, slotDurationMinutes, defaultCapacityPerSlot } = req.body;

    if (!name) {
      res.status(400);
      throw new Error("Office name is required");
    }

    const office = await Office.create({
      name,
      location: location || "",
      workingDays: workingDays || ["sat", "sun", "mon", "tue", "wed", "thu"],
      openTime: openTime || "09:00",
      closeTime: closeTime || "16:00",
      slotDurationMinutes: slotDurationMinutes || 30,
      defaultCapacityPerSlot: defaultCapacityPerSlot || 10,
      isActive: true,
    });

    res.status(201).json({
      success: true,
      message: "Office created",
      data: office,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/offices/:id
exports.updateOffice = async (req, res, next) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid office id");
    }

    const office = await Office.findByIdAndUpdate(id, updates, { new: true, runValidators: true });

    if (!office) {
      res.status(404);
      throw new Error("Office not found");
    }

    res.json({
      success: true,
      message: "Office updated",
      data: office,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/offices/:id/toggle-active
exports.toggleOfficeActive = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid office id");
    }

    const office = await Office.findById(id);
    if (!office) {
      res.status(404);
      throw new Error("Office not found");
    }

    office.isActive = !office.isActive;
    await office.save();

    res.json({
      success: true,
      message: `Office ${office.isActive ? "activated" : "deactivated"}`,
      data: office,
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/offices
exports.getAllOffices = async (req, res, next) => {
  try {
    const offices = await Office.find().sort({ createdAt: -1 });

    res.json({
      success: true,
      message: "Offices fetched",
      data: offices,
    });
  } catch (err) {
    next(err);
  }
};

// ============================================
// SERVICE MANAGEMENT
// ============================================

// POST /api/admin/services
exports.createService = async (req, res, next) => {
  try {
    const { officeId, name, description, requiredDocs, fee } = req.body;

    if (!officeId || !name) {
      res.status(400);
      throw new Error("officeId and name are required");
    }

    if (!mongoose.Types.ObjectId.isValid(officeId)) {
      res.status(400);
      throw new Error("Invalid officeId");
    }

    const office = await Office.findById(officeId);
    if (!office) {
      res.status(404);
      throw new Error("Office not found");
    }

    const service = await Service.create({
      officeId,
      name,
      description: description || "",
      requiredDocs: requiredDocs || [],
      fee: fee || 0,
      isActive: true,
    });

    res.status(201).json({
      success: true,
      message: "Service created",
      data: service,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/services/:id
exports.updateService = async (req, res, next) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid service id");
    }

    const service = await Service.findByIdAndUpdate(id, updates, { new: true, runValidators: true });

    if (!service) {
      res.status(404);
      throw new Error("Service not found");
    }

    res.json({
      success: true,
      message: "Service updated",
      data: service,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/services/:id/toggle-active
exports.toggleServiceActive = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid service id");
    }

    const service = await Service.findById(id);
    if (!service) {
      res.status(404);
      throw new Error("Service not found");
    }

    service.isActive = !service.isActive;
    await service.save();

    res.json({
      success: true,
      message: `Service ${service.isActive ? "activated" : "deactivated"}`,
      data: service,
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/services?officeId=...
exports.getServicesByOffice = async (req, res, next) => {
  try {
    const { officeId } = req.query;

    let filter = {};
    if (officeId) {
      if (!mongoose.Types.ObjectId.isValid(officeId)) {
        res.status(400);
        throw new Error("Invalid officeId");
      }
      filter.officeId = officeId;
    }

    const services = await Service.find(filter).populate("officeId", "name").sort({ createdAt: -1 });

    res.json({
      success: true,
      message: "Services fetched",
      data: services,
    });
  } catch (err) {
    next(err);
  }
};

// ============================================
// SLOT MANAGEMENT
// ============================================

// Helper function to generate time slots
function generateTimeSlots(openTime, closeTime, durationMinutes) {
  const slots = [];
  const [openHour, openMin] = openTime.split(":").map(Number);
  const [closeHour, closeMin] = closeTime.split(":").map(Number);

  let currentMinutes = openHour * 60 + openMin;
  const closeMinutes = closeHour * 60 + closeMin;

  while (currentMinutes + durationMinutes <= closeMinutes) {
    const startHour = Math.floor(currentMinutes / 60);
    const startMin = currentMinutes % 60;
    const endMinutes = currentMinutes + durationMinutes;
    const endHour = Math.floor(endMinutes / 60);
    const endMin = endMinutes % 60;

    const startTime = `${String(startHour).padStart(2, "0")}:${String(startMin).padStart(2, "0")}`;
    const endTime = `${String(endHour).padStart(2, "0")}:${String(endMin).padStart(2, "0")}`;

    slots.push({ startTime, endTime });
    currentMinutes += durationMinutes;
  }

  return slots;
}

// POST /api/admin/offices/:officeId/slots/generate
// body: { startDate, endDate }
exports.generateSlots = async (req, res, next) => {
  try {
    const { officeId } = req.params;
    const { startDate, endDate } = req.body;

    if (!mongoose.Types.ObjectId.isValid(officeId)) {
      res.status(400);
      throw new Error("Invalid officeId");
    }

    if (!startDate || !endDate) {
      res.status(400);
      throw new Error("startDate and endDate are required (YYYY-MM-DD)");
    }

    const office = await Office.findById(officeId);
    if (!office) {
      res.status(404);
      throw new Error("Office not found");
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start > end) {
      res.status(400);
      throw new Error("startDate must be before or equal to endDate");
    }

    const timeSlots = generateTimeSlots(office.openTime, office.closeTime, office.slotDurationMinutes);
    const slotsToCreate = [];

    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
      const dateStr = d.toISOString().split("T")[0]; // YYYY-MM-DD

      // Skip Fridays (working days are Sat-Thu)
      if (!isWorkingDay(dateStr)) {
        continue;
      }

      for (const { startTime, endTime } of timeSlots) {
        slotsToCreate.push({
          officeId,
          date: dateStr,
          startTime,
          endTime,
          capacity: office.defaultCapacityPerSlot,
          bookedCount: 0,
          status: "open",
        });
      }
    }

    // Use insertMany with ordered: false to skip duplicates
    let inserted = 0;
    try {
      const result = await TimeSlot.insertMany(slotsToCreate, { ordered: false });
      inserted = result.length;
    } catch (err) {
      // Handle duplicate key errors (11000)
      if (err.code === 11000) {
        inserted = err.insertedDocs ? err.insertedDocs.length : 0;
      } else {
        throw err;
      }
    }

    res.status(201).json({
      success: true,
      message: `Generated ${inserted} time slots (Fridays skipped)`,
      data: {
        officeId,
        startDate,
        endDate,
        slotsCreated: inserted,
      },
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/slots/:id/close
exports.closeSlot = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid slot id");
    }

    const slot = await TimeSlot.findByIdAndUpdate(id, { status: "closed" }, { new: true });

    if (!slot) {
      res.status(404);
      throw new Error("Slot not found");
    }

    res.json({
      success: true,
      message: "Slot closed",
      data: slot,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/slots/:id/open
exports.openSlot = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid slot id");
    }

    const slot = await TimeSlot.findByIdAndUpdate(id, { status: "open" }, { new: true });

    if (!slot) {
      res.status(404);
      throw new Error("Slot not found");
    }

    res.json({
      success: true,
      message: "Slot opened",
      data: slot,
    });
  } catch (err) {
    next(err);
  }
};

// ============================================
// BOOKING MANAGEMENT
// ============================================

// GET /api/admin/bookings?status=...
exports.getAllBookings = async (req, res, next) => {
  try {
    const { status } = req.query;

    let filter = {};
    if (status) {
      filter.status = String(status).toUpperCase();
    }

    const bookings = await Booking.find(filter)
      .populate("citizenId", "fullName phone nationalId")
      .populate("officeId", "name location")
      .populate("serviceId", "name fee")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      message: "Bookings fetched",
      data: bookings,
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/bookings/:id
exports.getBookingById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid booking id");
    }

    const booking = await Booking.findById(id)
      .populate("citizenId", "fullName phone nationalId")
      .populate("officeId", "name location")
      .populate("serviceId", "name description fee requiredDocs");

    if (!booking) {
      res.status(404);
      throw new Error("Booking not found");
    }

    res.json({
      success: true,
      message: "Booking fetched",
      data: booking,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/bookings/:id/approve
exports.approveBooking = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid booking id");
    }

    const current = await Booking.findById(id).select("status");
    if (!current) {
      res.status(404);
      throw new Error("Booking not found");
    }

    if (String(current.status).toUpperCase() !== "PENDING") {
      res.status(400);
      throw new Error(`Cannot approve a ${current.status} booking`);
    }

    const booking = await Booking.findByIdAndUpdate(
      id,
      { $set: { status: "APPROVED" } },
      { new: true }
    );

    res.json({
      success: true,
      message: "Booking approved",
      data: booking,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/bookings/:id/reject
// body: { reason }
exports.rejectBooking = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid booking id");
    }

    if (!reason) {
      res.status(400);
      throw new Error("Rejection reason is required");
    }

    const current = await Booking.findById(id).select("status timeSlotId");
    if (!current) {
      res.status(404);
      throw new Error("Booking not found");
    }

    if (String(current.status).toUpperCase() !== "PENDING") {
      res.status(400);
      throw new Error(`Cannot reject a ${current.status} booking`);
    }

    const booking = await Booking.findByIdAndUpdate(
      id,
      { $set: { status: "REJECTED", adminNote: reason } },
      { new: true }
    );

    // Decrement slot bookedCount only when bookings are slot-linked.
    if (current.timeSlotId) {
      await TimeSlot.findByIdAndUpdate(current.timeSlotId, {
        $inc: { bookedCount: -1 },
      });
    }

    res.json({
      success: true,
      message: "Booking rejected",
      data: booking,
    });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/admin/bookings/:id/complete
exports.completeBooking = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid booking id");
    }

    const current = await Booking.findById(id).select("status");
    if (!current) {
      res.status(404);
      throw new Error("Booking not found");
    }

    if (String(current.status).toUpperCase() !== "APPROVED") {
      res.status(400);
      throw new Error(`Cannot complete a ${current.status} booking. Only approved bookings can be completed.`);
    }

    const booking = await Booking.findByIdAndUpdate(
      id,
      { $set: { status: "COMPLETED" } },
      { new: true }
    );

    res.json({
      success: true,
      message: "Booking marked as completed",
      data: booking,
    });
  } catch (err) {
    next(err);
  }
};

// ============================================
// USER MANAGEMENT
// ============================================

// GET /api/admin/users?role=CITIZEN|ADMIN
exports.getAllUsers = async (req, res, next) => {
  try {
    const { role } = req.query;

    let filter = {};
    if (role) {
      if (!["CITIZEN", "ADMIN"].includes(role)) {
        res.status(400);
        throw new Error("Invalid role. Must be CITIZEN or ADMIN");
      }
      filter.role = role;
    }

    const users = await User.find(filter).select("-passwordHash").sort({ createdAt: -1 });

    res.json({
      success: true,
      message: "Users fetched",
      data: users,
    });
  } catch (err) {
    next(err);
  }
};

// POST /api/admin/users
exports.createUser = async (req, res, next) => {
  try {
    const { fullName, phone, nationalId, password, role } = req.body;

    if (!fullName || !phone || !nationalId || !password || !role) {
      res.status(400);
      throw new Error("fullName, phone, nationalId, password, and role are required");
    }

    if (!["ADMIN", "CITIZEN", "OFFICER"].includes(role)) {
      res.status(400);
      throw new Error("Invalid role. Must be ADMIN, CITIZEN, or OFFICER");
    }

    if (String(password).length < 6) {
      res.status(400);
      throw new Error("Password must be at least 6 characters");
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = await User.create({
      fullName,
      phone,
      nationalId,
      passwordHash,
      role,
      isActive: true,
    });

    res.status(201).json({
      success: true,
      message: `${role} user created`,
      data: {
        id: user._id,
        fullName: user.fullName,
        phone: user.phone,
        nationalId: user.nationalId,
        role: user.role,
      },
    });
  } catch (err) {
    if (err.code === 11000) {
      res.status(409);
      return next(new Error("User already exists (phone or nationalId)"));
    }
    next(err);
  }
};

// PATCH /api/admin/users/:id/toggle-active
exports.toggleUserActive = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      res.status(400);
      throw new Error("Invalid user id");
    }

    const user = await User.findById(id).select("-passwordHash");
    if (!user) {
      res.status(404);
      throw new Error("User not found");
    }

    user.isActive = !user.isActive;
    await user.save();

    res.json({
      success: true,
      message: `User ${user.isActive ? "activated" : "deactivated"}`,
      data: user,
    });
  } catch (err) {
    next(err);
  }
};
