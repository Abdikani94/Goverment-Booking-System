// Check database state for debugging booking issues
const mongoose = require("mongoose");
require("dotenv").config();

const Office = require("./src/models/Office");
const TimeSlot = require("./src/models/TimeSlot");
const Service = require("./src/models/Service");

async function checkDB() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("✓ Connected to MongoDB");

        const offices = await Office.find({});
        console.log(`\n📍 Offices: ${offices.length}`);
        offices.forEach(o => console.log(`  - ${o.name} (${o._id}) - Active: ${o.isActive}`));

        const services = await Service.find({});
        console.log(`\n🔧 Services: ${services.length}`);
        services.forEach(s => console.log(`  - ${s.name} for office ${s.officeId}`));

        const slots = await TimeSlot.find({});
        console.log(`\n⏰ Time Slots: ${slots.length}`);
        if (slots.length > 0) {
            console.log(`  First slot: ${slots[0].date} ${slots[0].startTime}-${slots[0].endTime} for office ${slots[0].officeId}`);
            console.log(`  Last slot: ${slots[slots.length - 1].date} ${slots[slots.length - 1].startTime}-${slots[slots.length - 1].endTime}`);
        } else {
            console.log("  ⚠️  NO SLOTS FOUND - This is why booking fails!");
        }

        await mongoose.disconnect();
    } catch (err) {
        console.error("Error:", err.message);
        process.exit(1);
    }
}

checkDB();
