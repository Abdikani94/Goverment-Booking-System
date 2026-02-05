
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingSuccessPage extends StatelessWidget {
  final String code;
  const BookingSuccessPage({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.20),
      body: Center(
        child: Container(
          width: 420,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 34, color: Color(0xFF1F57D6)),
              ),
              const SizedBox(height: 14),
              const Text("Booking Created", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text(
                "Your appointment has been successfully scheduled.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF667085)),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBFD0FF), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    const Text("CONFIRMATION CODE", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF98A2B3))),
                    const SizedBox(height: 6),
                    Text(code, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1F57D6))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/citizen/my-bookings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F57D6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text("Go to My bookings", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/citizen'),
                child: const Text("Back to Home"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
