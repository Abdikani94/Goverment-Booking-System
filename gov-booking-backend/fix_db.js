
const mongoose = require("mongoose");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

async function fix() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log("Connected to MongoDB...");

        // Drop email index if it exists
        try {
            await mongoose.connection.collection("users").dropIndex("email_1");
            console.log("Dropped email_1 index");
        } catch (e) {
            console.log("email_1 index not found or already dropped");
        }

        process.exit(0);
    } catch (err) {
        console.error("Fix failed:", err);
        process.exit(1);
    }
}

fix();
