class ApiEndpoints {
  // IMPORTANT:
  // Android Emulator: http://10.0.2.2:5000
  // iOS Simulator: http://localhost:5000
  // Real device: http://YOUR_PC_IP:5000

  static const baseUrl = "http://localhost:5000";

  // Auth
  static const login = "/api/auth/login";
  static const register = "/api/auth/register";
  static const me = "/api/auth/me";

  // Offices
  static const offices = "/api/offices";
  static String officeSlots(String officeId) => "/api/offices/$officeId/slots";

  // Services
  static const services = "/api/services";

  // Bookings
  static const bookings = "/api/bookings";
  static const myBookings = "/api/bookings/my";
  static String bookingById(String id) => "/api/bookings/$id";
  static String cancelBooking(String id) => "/api/bookings/$id/cancel";

  // Admin - Stats & Reports
  static const adminStats = "/api/admin/stats";
  static const adminReportsSummary = "/api/admin/reports/summary";

  // Admin - Offices
  static const adminOffices = "/api/admin/offices";
  static String adminOfficeById(String id) => "/api/admin/offices/$id";
  static String adminOfficeToggleActive(String id) =>
      "/api/admin/offices/$id/toggle-active";

  // Admin - Services
  static const adminServices = "/api/admin/services";
  static String adminServiceById(String id) => "/api/admin/services/$id";
  static String adminServiceToggleActive(String id) =>
      "/api/admin/services/$id/toggle-active";

  // Admin - Slots
  static String adminGenerateSlots(String officeId) =>
      "/api/admin/offices/$officeId/slots/generate";
  static String adminCloseSlot(String id) => "/api/admin/slots/$id/close";
  static String adminOpenSlot(String id) => "/api/admin/slots/$id/open";

  // Admin - Bookings
  static const adminBookings = "/api/admin/bookings";
  static String adminBookingById(String id) => "/api/admin/bookings/$id";
  static String adminApproveBooking(String id) =>
      "/api/admin/bookings/$id/approve";
  static String adminRejectBooking(String id) =>
      "/api/admin/bookings/$id/reject";
  static String adminCompleteBooking(String id) =>
      "/api/admin/bookings/$id/complete";

  // Admin - Users
  static const adminUsers = "/api/admin/users";
  static const adminCreateAdmin = "/api/admin/users/admin";
  static String adminToggleUserActive(String id) =>
      "/api/admin/users/$id/toggle-active";
}
