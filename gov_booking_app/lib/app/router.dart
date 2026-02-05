import 'package:go_router/go_router.dart';

import '../features/auth/ui/splash_page.dart';
import '../features/auth/ui/welcome_page.dart';
import '../features/auth/ui/login_page.dart';
import '../features/auth/ui/register_page.dart';
import '../features/citizen/ui/citizen_shell.dart';
import '../features/citizen/ui/select_office_page.dart';
import '../features/citizen/ui/select_service_page.dart';
import '../features/citizen/ui/select_date_time_page.dart';
import '../features/citizen/ui/review_confirm_page.dart';
import '../features/citizen/ui/booking_success_page.dart';
import '../features/citizen/ui/booking_details_screen.dart';
import '../features/citizen/ui/notifications_screen.dart';
import '../features/admin/ui/admin_shell.dart';
import '../features/admin/ui/manage_offices_page.dart';
import '../features/admin/ui/manage_bookings_page.dart';
import '../features/admin/ui/manage_services_page.dart';
import '../features/admin/ui/manage_users_page.dart';
import '../features/admin/ui/reports_page.dart';

final router = GoRouter(
  initialLocation: "/auth/splash",
  routes: [
    GoRoute(path: "/auth/splash", builder: (_, __) => const SplashPage()),
    GoRoute(path: "/welcome", builder: (_, __) => const WelcomePage()),
    GoRoute(path: "/login", builder: (_, __) => const LoginPage()),
    GoRoute(path: "/register", builder: (_, __) => const RegisterPage()),

    // Citizen shell (tabs)
    GoRoute(
      path: "/citizen",
      builder: (context, state) {
        final tab = state.uri.queryParameters['tab'];
        int index = 0;
        if (tab == 'book') index = 1;
        if (tab == 'bookings') index = 2;
        if (tab == 'profile') index = 3;
        return CitizenShell(initialIndex: index);
      },
    ),

    // Admin shell (tabs)
    GoRoute(
      path: "/admin",
      builder: (context, state) {
        final tab = state.uri.queryParameters['tab'];
        int index = 0;
        if (tab == 'offices') index = 1;
        if (tab == 'bookings') index = 2;
        if (tab == 'users') index = 3;
        return AdminShell(initialIndex: index);
      },
    ),

    // Admin Management Pages (if needed as separate routes)
    GoRoute(
        path: "/admin/offices", builder: (_, __) => const ManageOfficesPage()),
    GoRoute(
        path: "/admin/services",
        builder: (_, __) => const ManageServicesPage()),
    GoRoute(path: "/admin/users", builder: (_, __) => const ManageUsersPage()),
    GoRoute(
        path: "/admin/staff",
        builder: (_, __) => const ManageUsersPage()), // Alias for users
    GoRoute(
        path: "/admin/bookings",
        builder: (_, __) => const ManageBookingsPage()),
    GoRoute(path: "/admin/reports", builder: (_, __) => const ReportsPage()),

    // Booking Flow Sub-pages (Pushed on top of shell for focus)
    GoRoute(
      path: "/citizen/book/select-office",
      builder: (context, state) => const SelectOfficePage(),
    ),
    GoRoute(
      path: "/citizen/book/select-service/:officeId",
      builder: (context, state) => SelectServicePage(
        officeId: state.pathParameters['officeId']!,
      ),
    ),
    GoRoute(
      path: "/citizen/book/select-date-time/:officeId/:serviceId",
      builder: (context, state) => SelectDateTimePage(
        officeId: state.pathParameters['officeId']!,
        serviceId: state.pathParameters['serviceId']!,
      ),
    ),
    GoRoute(
      path: "/citizen/book/review-confirm/:officeId/:serviceId/:slotId",
      builder: (context, state) => ReviewConfirmPage(
        officeId: state.pathParameters['officeId']!,
        serviceId: state.pathParameters['serviceId']!,
        slotId: state.pathParameters['slotId']!,
        date: state.uri.queryParameters['date']!,
        time: state.uri.queryParameters['time']!,
      ),
    ),
    GoRoute(
      path: "/citizen/book/success",
      builder: (context, state) => BookingSuccessPage(
        code: state.uri.queryParameters['code']!,
      ),
    ),

    // Other Global Pages
    GoRoute(
      path: "/citizen/booking-details/:id",
      builder: (context, state) => BookingDetailsPage(
        bookingId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: "/citizen/notifications",
      builder: (context, state) => const NotificationsScreen(),
    ),
  ],
);
