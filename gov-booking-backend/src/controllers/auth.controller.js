
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

const signToken = (user) =>
  jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: "7d" });

exports.register = async (req, res) => {
  const { fullName, phone, nationalId, password } = req.body;

  if (!fullName || !phone || !nationalId || !password) {
    return res.status(400).json({ success: false, message: "Missing fields" });
  }

  const exists = await User.findOne({ phone });
  if (exists) return res.status(409).json({ success: false, message: "Phone already used" });

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await User.create({
    fullName,
    phone,
    nationalId,
    passwordHash,
    role: "CITIZEN",
  });

  const token = signToken(user);

  return res.status(201).json({
    success: true,
    message: "Registration successful",
    data: {
      token,
      user: { id: user._id, fullName: user.fullName, phone: user.phone, role: user.role },
    },
  });
};

exports.login = async (req, res) => {
  const { phone, password } = req.body;

  if (!phone || !password) return res.status(400).json({ success: false, message: "Missing fields" });

  const user = await User.findOne({ phone });
  if (!user) return res.status(401).json({ success: false, message: "Invalid credentials" });

  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) return res.status(401).json({ success: false, message: "Invalid credentials" });

  if (user.isActive === false) return res.status(403).json({ success: false, message: "Account disabled" });

  const token = signToken(user);

  return res.json({
    success: true,
    message: "Login successful",
    data: {
      token,
      user: { id: user._id, fullName: user.fullName, phone: user.phone, role: user.role },
    },
  });
};

exports.me = async (req, res) => {
  const user = await User.findById(req.user.id).select("-passwordHash");
  if (!user) return res.status(404).json({ success: false, message: "User not found" });

  return res.json({
    success: true,
    data: {
      id: user._id,
      fullName: user.fullName,
      phone: user.phone,
      nationalId: user.nationalId,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt,
    },
  });
};

// Create first admin quickly (dev only)
exports.seedAdmin = async (req, res) => {
  const { fullName, phone, nationalId, password } = req.body;
  const exists = await User.findOne({ phone });
  if (exists) return res.json({ success: true, message: "Admin already exists" });

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({ fullName, phone, nationalId, passwordHash, role: "ADMIN" });
  return res.status(201).json({ success: true, data: { id: user._id, phone: user.phone, role: user.role } });
};
