const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const User = require("./src/models/User");

async function createFirstAdmin() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("✅ Connected to MongoDB");

        // Check if admin already exists
        const existingAdmin = await User.findOne({ role: "ADMIN" });
        if (existingAdmin) {
            console.log("⚠️  Admin user already exists:");
            console.log({
                fullName: existingAdmin.fullName,
                phone: existingAdmin.phone,
                nationalId: existingAdmin.nationalId,
            });
            process.exit(0);
        }

        // Create first admin
        const passwordHash = await bcrypt.hash("admin123", 10);

        const admin = await User.create({
            fullName: "System Administrator",
            phone: "0000000000",
            nationalId: "ADMIN001",
            passwordHash,
            role: "ADMIN",
            isActive: true,
        });

        console.log("✅ First admin user created successfully!");
        console.log({
            fullName: admin.fullName,
            phone: admin.phone,
            nationalId: admin.nationalId,
            role: admin.role,
        });
        console.log("\n📝 Login credentials:");
        console.log("Phone: 0000000000");
        console.log("Password: admin123");
        console.log("\n⚠️  Please change the password after first login!");

        process.exit(0);
    } catch (err) {
        console.error("❌ Error creating admin:", err.message);
        process.exit(1);
    }
}

createFirstAdmin();
