
const router = require("express").Router();
const c = require("../controllers/service.controller");
const { requireAuth, requireRole } = require("../middleware/auth");

router.get("/by-office/:officeId", c.listByOffice);

// admin
router.get("/admin/all", requireAuth, requireRole("ADMIN"), c.adminList);
router.post("/", requireAuth, requireRole("ADMIN"), c.create);
router.put("/:id", requireAuth, requireRole("ADMIN"), c.update);
router.delete("/:id", requireAuth, requireRole("ADMIN"), c.remove);

module.exports = router;
