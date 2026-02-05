import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class GovBookingApp extends StatelessWidget {
  const GovBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Gov Booking",
      theme: AppTheme.light(),

      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
