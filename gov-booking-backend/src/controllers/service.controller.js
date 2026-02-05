
const Service = require("../models/Service");

exports.listByOffice = async (req, res) => {
  const items = await Service.find({ officeId: req.params.officeId, isActive: true }).sort({ createdAt: -1 });
  res.json({ success: true, data: items });
};

exports.adminList = async (req, res) => {
  const items = await Service.find().populate("officeId").sort({ createdAt: -1 });
  res.json({ success: true, data: items });
};

exports.create = async (req, res) => {
  const { officeId, name, requiredDocs } = req.body;
  const service = await Service.create({ officeId, name, requiredDocs: requiredDocs || [] });
  res.status(201).json({ success: true, data: service });
};

exports.update = async (req, res) => {
  const s = await Service.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json({ success: true, data: s });
};

exports.remove = async (req, res) => {
  await Service.findByIdAndDelete(req.params.id);
  res.json({ success: true });
};
