
const router = require("express").Router();
const c = require("../controllers/booking.controller");
const { requireAuth, requireRole } = require("../middleware/auth");

// Citizen
router.post("/", requireAuth, requireRole("CITIZEN"), c.create);
router.get("/mine", requireAuth, requireRole("CITIZEN"), c.myBookings);

// Admin
router.get("/admin/all", requireAuth, requireRole("ADMIN"), c.adminAll);
router.put("/:id/status", requireAuth, requireRole("ADMIN"), c.setStatus);

module.exports = router;
