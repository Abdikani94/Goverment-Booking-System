import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReviewBookingPage extends StatelessWidget {
  final String officeId;
  final String serviceId;
  final String slot;

  const ReviewBookingPage({
    super.key,
    required this.officeId,
    required this.serviceId,
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Review Booking'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Required Documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const _CheckItem("Current Driver's License or Valid ID"),
            const _CheckItem("Proof of Residency (Utility Bill)"),
            const SizedBox(height: 18),

            const Text("Additional Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE6ECF6)),
              ),
              child: const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Add any specific requests or instructions (Optional)",
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // For now: go success screen (later call your backend create booking)
                  context.go('/citizen/book/success?code=GOV-2026-000001');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F57D6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text("Confirm Booking", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1DB954)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
