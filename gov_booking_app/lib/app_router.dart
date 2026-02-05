import 'package:go_router/go_router.dart';

import 'features/auth/ui/login_page.dart';
import 'features/auth/ui/register_page.dart';
import 'features/citizen/ui/citizen_home_page.dart';
import 'features/citizen/ui/my_bookings_page.dart';
import 'features/citizen/ui/new_booking_page.dart';
import 'features/citizen/ui/profile_page.dart';

import 'features/admin/ui/admin_home_page.dart';
import 'features/admin/ui/admin_bookings_page.dart';
import 'features/admin/ui/manage_offices_page.dart';
import 'features/admin/ui/manage_services_page.dart';
import 'features/admin/ui/manage_users_page.dart';
import 'features/admin/ui/admin_profile_page.dart';

class AppRouter {
  static GoRouter router() {
    return GoRouter(
      initialLocation: "/welcome",
      routes: [
        GoRoute(
          path: "/welcome",
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: "/register",
          builder: (context, state) => const RegisterPage(),
        ),

        // Citizen
        GoRoute(
          path: "/citizen",
          builder: (context, state) => const CitizenHomePage(),
        ),
        GoRoute(
          path: "/citizen/new",
          builder: (context, state) => const NewBookingPage(),
        ),
        GoRoute(
          path: "/citizen/bookings",
          builder: (context, state) => const MyBookingsPage(),
        ),
        GoRoute(
          path: "/citizen/profile",
          builder: (context, state) => const ProfilePage(),
        ),

        // Admin
        GoRoute(
          path: "/admin",
          builder: (context, state) => const AdminHomePage(),
        ),
        GoRoute(
          path: "/admin/bookings",
          builder: (context, state) => const AdminBookingsPage(),
        ),
        GoRoute(
          path: "/admin/offices",
          builder: (context, state) => const ManageOfficesPage(),
        ),
        GoRoute(
          path: "/admin/services",
          builder: (context, state) => const ManageServicesPage(),
        ),
        GoRoute(
          path: "/admin/users",
          builder: (context, state) => const ManageUsersPage(),
        ),
        GoRoute(
          path: "/admin/profile",
          builder: (context, state) => const AdminProfilePage(),
        ),
      ],
    );
  }
}