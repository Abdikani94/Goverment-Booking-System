
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

const User = require("./src/models/User");
const Office = require("./src/models/Office");
const Service = require("./src/models/Service");
const TimeSlot = require("./src/models/TimeSlot");
const Counter = require("./src/models/Counter");

const { timeToMinutes, minutesToTime, toYMD } = require("./src/utils/datetime");

async function seed() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("Connected to MongoDB for heavy seeding...");

        // 1. Clear existing data
        await Promise.all([
            User.deleteMany({}),
            Office.deleteMany({}),
            Service.deleteMany({}),
            TimeSlot.deleteMany({}),
            Counter.deleteMany({}),
        ]);
        console.log("Cleared existing database data.");

        const hash = await bcrypt.hash("password123", 10);

        // 2. Create Offices
        const offices = await Office.insertMany([
            {
                name: "Central Passport Office",
                location: "Downtown, Zone 1",
                openTime: "08:00",
                closeTime: "15:00",
                slotDurationMinutes: 30,
                defaultCapacityPerSlot: 5,
                workingDays: ["sat", "sun", "mon", "tue", "wed", "thu"],
            },
            {
                name: "International Visa Center",
                location: "East Plaza, Zone 4",
                openTime: "09:00",
                closeTime: "17:00",
                slotDurationMinutes: 60,
                defaultCapacityPerSlot: 3,
                workingDays: ["sun", "mon", "tue", "wed", "thu"],
            },
        ]);
        console.log(`Created ${offices.length} offices.`);

        // 3. Create Services
        const servicesData = [
            {
                officeId: offices[0]._id,
                name: "New Passport Issuance",
                description: "Apply for a first-time passport.",
                fee: 50,
            },
            {
                officeId: offices[0]._id,
                name: "Passport Renewal",
                description: "Renew your expired or about to expire passport.",
                fee: 30,
            },
            {
                officeId: offices[1]._id,
                name: "Tourist Visa Entry",
                description: "Single entry tourist visa processing.",
                fee: 100,
            },
            {
                officeId: offices[1]._id,
                name: "Work Permit Residency",
                description: "Long-term work permit application.",
                fee: 250,
            },
        ];
        await Service.insertMany(servicesData);
        console.log(`Created ${servicesData.length} services.`);

        // 4. Create Users
        const usersData = [
            {
                fullName: "System Admin",
                phone: "0100000000",
                nationalId: "1000000000",
                passwordHash: hash,
                role: "ADMIN",
            },
            {
                fullName: "Officer Ahmed (Passport)",
                phone: "0111111111",
                nationalId: "1111111111",
                passwordHash: hash,
                role: "OFFICER",
                officeId: offices[0]._id,
            },
            {
                fullName: "Officer Sara (Visa)",
                phone: "0122222222",
                nationalId: "1222222222",
                passwordHash: hash,
                role: "OFFICER",
                officeId: offices[1]._id,
            },
            {
                fullName: "Test Citizen",
                phone: "0123456789",
                nationalId: "2000000000",
                passwordHash: hash,
                role: "CITIZEN",
            },
        ];
        await User.insertMany(usersData);
        console.log(`Created ${usersData.length} users.`);

        // 5. Generate Time Slots
        console.log("Generating time slots for the next 5 days...");
        const today = new Date();
        for (let i = 0; i < 5; i++) {
            const d = new Date(today);
            d.setDate(today.getDate() + i);
            const dateStr = toYMD(d);
            const dayNames = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
            const dayName = dayNames[d.getDay()];

            for (const office of offices) {
                if (!office.workingDays.includes(dayName)) continue;

                const openMin = timeToMinutes(office.openTime);
                const closeMin = timeToMinutes(office.closeTime);
                const dur = office.slotDurationMinutes;

                for (let t = openMin; t + dur <= closeMin; t += dur) {
                    await TimeSlot.create({
                        officeId: office._id,
                        date: dateStr,
                        startTime: minutesToTime(t),
                        endTime: minutesToTime(t + dur),
                        capacity: office.defaultCapacityPerSlot,
                    });
                }
            }
        }
        console.log("Time slots generated.");

        console.log("Heavy Seeding completed! ✅");
        process.exit(0);
    } catch (err) {
        console.error("Heavy Seeding failed:", err);
        process.exit(1);
    }
}

seed();
