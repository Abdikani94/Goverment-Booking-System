const mongoose = require('mongoose');
const User = require('./src/models/User');
const Office = require('./src/models/Office');
const Booking = require('./src/models/Booking');
require('dotenv').config();

async function debugData() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB');

        console.log('\n--- OFFICES ---');
        const offices = await Office.find({});
        offices.forEach(o => console.log(`Office: ${o.name} | ID: ${o._id}`));

        console.log('\n--- ADMIN USER ---');
        const admin = await User.findOne({ role: 'admin' });
        if (admin) {
            console.log(`Admin: ${admin.fullName} | ID: ${admin._id}`);
            console.log(`Assigned Office ID: ${admin.officeId}`);
        } else {
            console.log('No Admin found.');
        }

        console.log('\n--- RECENT BOOKINGS ---');
        const bookings = await Booking.find({}).sort({ createdAt: -1 }).limit(5);
        bookings.forEach(b => {
            console.log(`Booking: ${b.bookingCode} | Status: ${b.status}`);
            console.log(`  > Office ID: ${b.officeId}`);
            console.log(`  > Citizen ID: ${b.citizenId}`);
        });

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

debugData();
