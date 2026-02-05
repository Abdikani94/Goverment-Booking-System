
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

void main() {
  runApp(const ProviderScope(child: GovBookingApp()));
}

class GovBookingApp extends StatelessWidget {
  const GovBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gov Booking',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1F57D6),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      ),
      routerConfig: router,
    );
  }
}
