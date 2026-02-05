
exports.notFound = (req, res) => {
  res.status(404).json({ success: false, message: "Route not found" });
};

exports.errorHandler = (err, req, res, next) => {
  console.error("❌ Error:", err.message);
  const code = res.statusCode !== 200 ? res.statusCode : 500;
  res.status(code).json({ success: false, message: err.message || "Server error" });
};
