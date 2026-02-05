
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Color text, Color muted) {
    final base = GoogleFonts.interTextTheme();

    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: text,
        letterSpacing: -0.5,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: text,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: text,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: text,
      ),

      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: text,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: muted,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    );
  }

  // Context-aware helpers
  static TextStyle? h1(BuildContext context) => Theme.of(context).textTheme.displaySmall;
  static TextStyle? section(BuildContext context) => Theme.of(context).textTheme.headlineSmall;
  static TextStyle? titleLarge(BuildContext context) => Theme.of(context).textTheme.titleLarge;
  static TextStyle? body(BuildContext context) => Theme.of(context).textTheme.bodyLarge;
  static TextStyle? bodyMedium(BuildContext context) => Theme.of(context).textTheme.bodyMedium;
  static TextStyle? caption(BuildContext context) => Theme.of(context).textTheme.bodySmall;
  static TextStyle? small(BuildContext context) => Theme.of(context).textTheme.labelSmall;

  // Legacy support for existing widgets
  static TextStyle? h2(BuildContext context) => section(context);
  static TextStyle? h3(BuildContext context) => Theme.of(context).textTheme.titleLarge;
  static TextStyle? label(BuildContext context) => Theme.of(context).textTheme.titleLarge;
  static TextStyle? pageTitle(BuildContext context) => h1(context);
  static TextStyle? bodySmall(BuildContext context) => caption(context);
}



