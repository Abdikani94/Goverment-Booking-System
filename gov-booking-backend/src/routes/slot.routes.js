
const router = require("express").Router({ mergeParams: true });
const c = require("../controllers/slot.controller");

// /api/offices/:officeId/slots
router.get("/", c.getSlotsByOfficeAndDate);

// /api/offices/:officeId/slots/generate
router.post("/generate", c.generateSlots);

module.exports = router;
