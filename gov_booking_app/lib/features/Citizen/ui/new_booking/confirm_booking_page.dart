import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:dio/dio.dart";

import "../../../core/network/dio_client.dart";

class ConfirmBookingPage extends ConsumerStatefulWidget {
  const ConfirmBookingPage({
    super.key,
    required this.officeId,
    required this.officeName,
    required this.serviceId,
    required this.serviceName,
    required this.dateIso,
    required this.slotLabel,
  });

  final String officeId;
  final String officeName;
  final String serviceId;
  final String serviceName;
  final String dateIso; // "2026-02-05"
  final String slotLabel; // "09:30 AM"

  @override
  ConsumerState<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends ConsumerState<ConfirmBookingPage> {
  final noteCtrl = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() => loading = true);

    final dio = ref.read(dioClientProvider).dio;

    try {
      final res = await dio.post("/bookings", data: {
        "officeId": widget.officeId,
        "serviceId": widget.serviceId,
        "date": widget.dateIso,
        "slot": widget.slotLabel,
        "note": noteCtrl.text.trim(),
      });

      debugPrint("BOOKING CREATED: ${res.data}");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking created ✅ Waiting for admin approval.")),
      );

      Navigator.pop(context, true);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      debugPrint("BOOKING ERROR => $code | $body");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $code")),
      );
    } catch (e) {
      debugPrint("BOOKING ERROR => $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking failed. Try again.")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Booking")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Card(
            title: "Details",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv("Office", widget.officeName),
                _kv("Service", widget.serviceName),
                _kv("Date", widget.dateIso),
                _kv("Time", widget.slotLabel),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            title: "Additional Notes (optional)",
            child: TextField(
              controller: noteCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Any request for admin…",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : _confirm,
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Confirm Booking"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
