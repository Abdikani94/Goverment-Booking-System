const Office = require("../models/Office");

exports.list = async (req, res) => {
  const items = await Office.find({ isActive: true }).sort({ createdAt: -1 });
  res.json({ success: true, data: items });
};

exports.adminList = async (req, res) => {
  const items = await Office.find().sort({ createdAt: -1 });
  res.json({ success: true, data: items });
};

exports.create = async (req, res) => {
  const { name, location } = req.body;
  const office = await Office.create({ name, location });
  res.status(201).json({ success: true, data: office });
};

exports.update = async (req, res) => {
  const office = await Office.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json({ success: true, data: office });
};

exports.remove = async (req, res) => {
  await Office.findByIdAndDelete(req.params.id);
  res.json({ success: true });
};
