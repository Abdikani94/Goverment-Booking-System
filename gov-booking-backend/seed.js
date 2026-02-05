
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

const User = require("./src/models/User");

async function seed() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("Connected to MongoDB for seeding...");

        // Clear existing users? No, just add if not present
        const hash = await bcrypt.hash("password123", 10);

        const users = [
            {
                fullName: "System Admin",
                phone: "0100000000",
                nationalId: "1000000000",
                passwordHash: hash,
                role: "admin",
            },
            {
                fullName: "Government Officer",
                phone: "0111111111",
                nationalId: "1111111111",
                passwordHash: hash,
                role: "officer",
            },
            {
                fullName: "Test Citizen",
                phone: "0123456789",
                nationalId: "2000000000",
                passwordHash: hash,
                role: "citizen",
            },
        ];

        for (const u of users) {
            const exists = await User.findOne({ phone: u.phone });
            if (!exists) {
                await User.create(u);
                console.log(`Created ${u.role}: ${u.phone}`);
            } else {
                console.log(`${u.role} already exists: ${u.phone}`);
            }
        }

        console.log("Seeding completed! ✅");
        process.exit(0);
    } catch (err) {
        console.error("Seeding failed:", err);
        process.exit(1);
    }
}

seed();
