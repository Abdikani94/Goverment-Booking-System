
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CitizenShell extends StatelessWidget {
  final Widget child;
  const CitizenShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/citizen/my-bookings')) return 2;
    if (location.startsWith('/citizen/profile')) return 3;
    if (location.startsWith('/citizen/book')) return 1;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/citizen');
          if (i == 1) context.go('/citizen/book/select-office');
          if (i == 2) context.go('/citizen/my-bookings');
          if (i == 3) context.go('/citizen/profile');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Book'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'My Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
