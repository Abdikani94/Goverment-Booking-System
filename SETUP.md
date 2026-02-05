# Gov Booking System - Setup Guide

## Prerequisites

- **Node.js** (v16 or higher)
- **MongoDB** (running locally or cloud instance)
- **Flutter** (v3.3.0 or higher)
- **Android Studio** / **Xcode** (for mobile development)

---

## Backend Setup

### 1. Navigate to Backend Directory
```bash
cd gov-booking-backend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Configure Environment Variables
Create a `.env` file in the `gov-booking-backend` directory:

```env
MONGO_URI=mongodb://localhost:27017/gov-booking
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
PORT=5000
```

**Important**: Change `JWT_SECRET` to a secure random string in production.

### 4. Start MongoDB
Make sure MongoDB is running on your system:
```bash
# Windows (if installed as service)
net start MongoDB

# macOS/Linux
sudo systemctl start mongod
```

### 5. Create First Admin User
```bash
node seed_admin.js
```

This creates an admin user with:
- **Phone**: `0000000000`
- **Password**: `admin123`

⚠️ **Change this password after first login!**

### 6. (Optional) Seed Sample Data
```bash
node seed.js
```

This creates sample offices, services, and time slots for testing.

### 7. Start Backend Server
```bash
npm run dev
```

The API will be running at `http://localhost:5000`

Test it by visiting: `http://localhost:5000` - you should see:
```json
{
  "success": true,
  "message": "Government Booking API is running ✅"
}
```

---

## Frontend Setup

### 1. Navigate to Flutter App Directory
```bash
cd gov_booking_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure API Base URL

**For Android Emulator**: Update `lib/Core/api/api_endpoints.dart`:
```dart
static const baseUrl = "http://10.0.2.2:5000";
```

**For iOS Simulator**: Keep as:
```dart
static const baseUrl = "http://localhost:5000";
```

**For Real Device**: Use your computer's IP address:
```dart
static const baseUrl = "http://YOUR_PC_IP:5000";
```

To find your PC's IP:
- **Windows**: `ipconfig` (look for IPv4 Address)
- **macOS/Linux**: `ifconfig` or `ip addr`

### 4. Run the App
```bash
flutter run
```

Select your target device (Android emulator, iOS simulator, or physical device).

---

## Testing the System

### Test Citizen Flow

1. **Register** a new citizen account
2. **Login** with your credentials
3. Navigate to **Book Appointment**
4. Select an office → service → date (Friday should be disabled) → time slot
5. **Confirm** booking → see booking code
6. Go to **My Bookings** → view your booking
7. Click booking → see details → **Cancel** if needed

### Test Admin Flow

1. **Login** with admin credentials:
   - Phone: `0000000000`
   - Password: `admin123`

2. **Dashboard**: View stats (total citizens, bookings, pending count)

3. **Offices**:
   - Create a new office
   - Edit office details
   - Toggle active/inactive

4. **Services**:
   - Create services for an office
   - Edit service details

5. **Bookings**:
   - View all bookings
   - Filter by status (pending, approved, etc.)
   - **Approve** a pending booking
   - **Reject** a booking (requires reason)
   - **Complete** an approved booking

6. **Users**:
   - View all citizens and admins
   - Create new admin users
   - Toggle user active status

---

## API Testing with Postman/Thunder Client

### 1. Register Citizen
```http
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "fullName": "John Doe",
  "phone": "1234567890",
  "nationalId": "ID12345",
  "password": "password123"
}
```

### 2. Login
```http
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "phone": "1234567890",
  "password": "password123"
}
```

Copy the `token` from the response.

### 3. Get My Profile
```http
GET http://localhost:5000/api/auth/me
Authorization: Bearer YOUR_TOKEN_HERE
```

### 4. Get Offices
```http
GET http://localhost:5000/api/offices
```

### 5. Create Booking (Citizen)
```http
POST http://localhost:5000/api/bookings
Authorization: Bearer YOUR_CITIZEN_TOKEN
Content-Type: application/json

{
  "officeId": "OFFICE_ID_HERE",
  "serviceId": "SERVICE_ID_HERE",
  "timeSlotId": "SLOT_ID_HERE",
  "date": "2026-02-08"
}
```

### 6. Admin - Approve Booking
```http
PATCH http://localhost:5000/api/admin/bookings/BOOKING_ID/approve
Authorization: Bearer YOUR_ADMIN_TOKEN
```

---

## Troubleshooting

### Backend Issues

**MongoDB Connection Error**:
- Ensure MongoDB is running
- Check `MONGO_URI` in `.env` file
- Try: `mongodb://127.0.0.1:27017/gov-booking` instead of `localhost`

**Port Already in Use**:
- Change `PORT` in `.env` to a different port (e.g., `5001`)
- Update Flutter app's `baseUrl` accordingly

### Frontend Issues

**Network Error / Cannot Connect to Backend**:
- Verify backend is running (`npm run dev`)
- Check `baseUrl` in `api_endpoints.dart` matches your setup
- For Android emulator, use `http://10.0.2.2:5000`
- For real device, ensure phone and PC are on same WiFi network

**Build Errors**:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Project Structure

### Backend
```
gov-booking-backend/
├── src/
│   ├── app.js              # Express app configuration
│   ├── server.js           # Server entry point
│   ├── config/db.js        # MongoDB connection
│   ├── models/             # Mongoose models
│   ├── controllers/        # Route handlers
│   ├── routes/             # API routes
│   ├── middleware/         # Auth & error handling
│   ├── utils/              # Helper functions
│   └── validations/        # Validation logic
├── seed_admin.js           # Create first admin
├── seed.js                 # Sample data
└── .env                    # Environment variables
```

### Frontend
```
gov_booking_app/
├── lib/
│   ├── main.dart           # App entry point
│   ├── app/                # App configuration & routing
│   ├── theme/              # Design system & colors
│   ├── Core/               # API client, storage, utils
│   ├── Shared/             # Reusable widgets
│   └── features/
│       ├── auth/           # Login, register, splash
│       ├── Citizen/        # Citizen booking flow
│       └── admin/          # Admin management interface
└── pubspec.yaml            # Dependencies
```

---

## Key Features

✅ **Two Roles Only**: CITIZEN and ADMIN (no officer/staff)  
✅ **Working Days**: Saturday to Thursday (Friday disabled)  
✅ **Booking Code**: Format `GOV-YYYY-000001` (auto-increment per year)  
✅ **Slot Management**: Atomic capacity tracking, prevents overbooking  
✅ **Admin Controls**: Full CRUD for offices, services, slots, bookings, users  
✅ **Material 3 Design**: Modern UI with Inter font, 24px radius, consistent colors  

---

## Default Credentials

**Admin**:
- Phone: `0000000000`
- Password: `admin123`

⚠️ **Change these credentials immediately after first login!**

---

## Support

For issues or questions, check:
1. Backend logs in terminal
2. Flutter console output
3. MongoDB connection status
4. API endpoint responses in Postman

---

**Happy Booking! 🎉**
