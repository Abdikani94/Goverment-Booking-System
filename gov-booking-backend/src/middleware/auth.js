
const jwt = require("jsonwebtoken");

exports.requireAuth = (req, res, next) => {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.status(401).json({ success: false, message: "No token" });

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload; // {id, role}
    next();
  } catch (e) {
    return res.status(401).json({ success: false, message: "Invalid token" });
  }
};

exports.requireRole = (role) => (req, res, next) => {
  if (!req.user) return res.status(401).json({ success: false, message: "No auth" });
  if (req.user.role !== role) return res.status(403).json({ success: false, message: "Forbidden" });
  next();
};
