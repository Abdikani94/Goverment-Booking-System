
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/admin/offices')) return 1;
    if (loc.startsWith('/admin/services')) return 2;
    if (loc.startsWith('/admin/bookings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final index = _indexFromLocation(loc);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/admin');
          if (i == 1) context.go('/admin/offices');
          if (i == 2) context.go('/admin/services');
          if (i == 3) context.go('/admin/bookings');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), label: 'Offices'),
          NavigationDestination(icon: Icon(Icons.miscellaneous_services_outlined), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'Bookings'),
        ],
      ),
    );
  }
}
