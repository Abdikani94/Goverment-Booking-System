
const router = require("express").Router();
const c = require("../controllers/admin.controller");
const { requireAuth, requireRole } = require("../middleware/auth");

// All admin routes require authentication and ADMIN role
router.use(requireAuth, requireRole("ADMIN"));

// Stats & Reports
router.get("/stats", c.getStats);
router.get("/reports/summary", c.getSummaryReport);

// Office Management
router.post("/offices", c.createOffice);
router.get("/offices", c.getAllOffices);
router.patch("/offices/:id", c.updateOffice);
router.patch("/offices/:id/toggle-active", c.toggleOfficeActive);

// Service Management
router.post("/services", c.createService);
router.get("/services", c.getServicesByOffice);
router.patch("/services/:id", c.updateService);
router.patch("/services/:id/toggle-active", c.toggleServiceActive);

// Slot Management
router.post("/offices/:officeId/slots/generate", c.generateSlots);
router.patch("/slots/:id/close", c.closeSlot);
router.patch("/slots/:id/open", c.openSlot);

// Booking Management
router.get("/bookings", c.getAllBookings);
router.get("/bookings/:id", c.getBookingById);
router.patch("/bookings/:id/approve", c.approveBooking);
router.patch("/bookings/:id/reject", c.rejectBooking);
router.patch("/bookings/:id/complete", c.completeBooking);
router.put("/bookings/:id/approve", c.approveBooking);
router.put("/bookings/:id/reject", c.rejectBooking);
router.put("/bookings/:id/complete", c.completeBooking);

// User Management
router.get("/users", c.getAllUsers);
router.post("/users", c.createUser);
router.patch("/users/:id/toggle-active", c.toggleUserActive);

module.exports = router;
