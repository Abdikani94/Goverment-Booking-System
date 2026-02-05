import 'package:dio/dio.dart';

class AppError {
  static String from(Object error, {String fallback = "Something went wrong. Please try again."}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data["message"] != null) {
        final msg = data["message"].toString().trim();
        if (msg.isNotEmpty) return _normalize(msg);
      }
      return _normalize(error.message ?? fallback);
    }
    final msg = error.toString().replaceFirst("Exception: ", "").trim();
    if (msg.isEmpty) return fallback;
    return _normalize(msg);
  }

  static String _normalize(String input) {
    final lower = input.toLowerCase();
    if (lower.contains("invalid credentials")) return "Invalid phone number or password.";
    if (lower.contains("phone already used")) return "This phone number is already registered.";
    if (lower.contains("no token")) return "You are not logged in. Please login again.";
    if (lower.contains("forbidden")) return "You are not allowed to perform this action.";
    if (lower.contains("network") || lower.contains("socket")) return "Network error. Check your connection and try again.";
    return input;
  }
}

