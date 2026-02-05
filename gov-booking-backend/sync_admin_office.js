const mongoose = require('mongoose');
const User = require('./src/models/User');
const Booking = require('./src/models/Booking');
require('dotenv').config();

async function syncAdmin() {
    try {
        await mongoose.connect(process.env.MONGO_URI);

        // 1. Get Latest Booking
        const booking = await Booking.findOne().sort({ createdAt: -1 });
        if (!booking) {
            console.log("No bookings found in DB.");
            process.exit(0);
        }
        console.log(`Latest Booking Office ID: ${booking.officeId}`);

        // 2. Get Admin
        const admin = await User.findOne({ role: 'admin' });
        if (!admin) {
            console.log("No Admin found.");
            process.exit(0);
        }

        // 3. Update Admin Office
        admin.officeId = booking.officeId;
        await admin.save();
        console.log(`Updated Admin (ID: ${admin._id}) to manage Office ID: ${booking.officeId}`);

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

syncAdmin();
