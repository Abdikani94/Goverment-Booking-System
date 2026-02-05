
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const connectDB = require("./config/db");

const authRoutes = require("./routes/auth.routes");
const officeRoutes = require("./routes/office.routes");
const serviceRoutes = require("./routes/service.routes");
const bookingRoutes = require("./routes/booking.routes");
const adminRoutes = require("./routes/admin.routes");


const { notFound, errorHandler } = require("./middleware/error");

const app = express();
connectDB();

// IMPORTANT: CORS for Flutter Web
app.use(
  cors({
    origin: true,            // allow any origin in dev
    credentials: true,
  })
);

app.use(express.json());
app.use(morgan("dev"));

app.get("/", (req, res) => res.json({ ok: true, message: "Gov Booking API" }));

app.use("/api/auth", authRoutes);
app.use("/api/offices", officeRoutes);
app.use("/api/services", serviceRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/admin", adminRoutes);



app.use(notFound);
app.use(errorHandler);

module.exports = app;
