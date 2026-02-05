const mongoose = require('mongoose');
const User = require('./src/models/User');
const Office = require('./src/models/Office');
require('dotenv').config();

async function fixAdmin() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB');

        // 1. Find or Create "Headquarters" Office
        let office = await Office.findOne({ name: 'Headquarters' });
        if (!office) {
            office = await Office.create({
                name: 'Headquarters',
                location: 'Capital City - Main District',
                description: 'Main central office for all government services.',
                isOpen: true
            });
            console.log('Created default Headquarters office.');
        } else {
            console.log('Headquarters office found.');
        }

        // 2. Find Admin and Assign Office
        const admin = await User.findOne({ phone: '0000000000' });
        if (admin) {
            admin.officeId = office._id;
            admin.role = 'admin'; // Ensure role is correct
            await admin.save();
            console.log(`Assigned Admin to office: ${office.name}`);
        } else {
            console.log('Admin user not found. Run seed_admin.js first.');
        }

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

fixAdmin();
