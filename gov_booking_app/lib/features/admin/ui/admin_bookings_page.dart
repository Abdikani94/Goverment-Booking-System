import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../providers/admin_provider.dart';

class AdminBookingsPage extends ConsumerStatefulWidget {
  const AdminBookingsPage({super.key});

  @override
  ConsumerState<AdminBookingsPage> createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends ConsumerState<AdminBookingsPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(adminRepoProvider);
      final items = await repo.getAllBookings();
      if (!mounted) return;
      setState(() {
        _bookings = items;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final data = e.response?.data;
      final String msg = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : (e.message ?? "Failed to load bookings");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load bookings: $e")));
    }
  }

  Future<void> _approve(String bookingId) async {
    try {
      await ref.read(adminRepoProvider).approveBooking(bookingId);
      await _loadBookings();
      ref.invalidate(adminStatsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Booking approved")));
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final String msg = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : (e.message ?? "Approve failed");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Approve failed: $e")));
    }
  }

  Future<void> _complete(String bookingId) async {
    try {
      await ref.read(adminRepoProvider).completeBooking(bookingId);
      await _loadBookings();
      ref.invalidate(adminStatsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Booking completed")));
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final String msg = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : (e.message ?? "Complete failed");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Complete failed: $e")));
    }
  }

  Future<void> _reject(String bookingId) async {
    final reasonCtrl = TextEditingController();
    final pageContext = context;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Reject Booking"),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Reason",
            hintText: "Enter rejection reason",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel")),
          FilledButton(
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(adminRepoProvider)
                    .rejectBooking(bookingId, reason);
                await _loadBookings();
                ref.invalidate(adminStatsProvider);
                if (!mounted || !pageContext.mounted) return;
                ScaffoldMessenger.of(pageContext).showSnackBar(
                    const SnackBar(content: Text("Booking rejected")));
              } on DioException catch (e) {
                if (!mounted || !pageContext.mounted) return;
                final data = e.response?.data;
                final String msg = (data is Map && data["message"] != null)
                    ? data["message"].toString()
                    : (e.message ?? "Reject failed");
                ScaffoldMessenger.of(pageContext)
                    .showSnackBar(SnackBar(content: Text(msg)));
              } catch (e) {
                if (!mounted || !pageContext.mounted) return;
                ScaffoldMessenger.of(pageContext)
                    .showSnackBar(SnackBar(content: Text("Reject failed: $e")));
              }
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _bookings
        .where((b) => (b["status"] ?? "").toString().toUpperCase() == "PENDING")
        .toList();
    final approved = _bookings
        .where(
            (b) => (b["status"] ?? "").toString().toUpperCase() == "APPROVED")
        .toList();
    final completed = _bookings
        .where(
            (b) => (b["status"] ?? "").toString().toUpperCase() == "COMPLETED")
        .toList();
    final rejected = _bookings
        .where(
            (b) => (b["status"] ?? "").toString().toUpperCase() == "REJECTED")
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          title: const Text("Booking Queue"),
          backgroundColor: const Color(0xFFF4F6FB),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Completed"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _BookingList(
                      items: pending,
                      onApprove: _approve,
                      onReject: _reject,
                      onComplete: _complete),
                  _BookingList(
                      items: approved,
                      onApprove: _approve,
                      onReject: _reject,
                      onComplete: _complete),
                  _BookingList(
                      items: completed,
                      onApprove: _approve,
                      onReject: _reject,
                      onComplete: _complete),
                  _BookingList(
                      items: rejected,
                      onApprove: _approve,
                      onReject: _reject,
                      onComplete: _complete),
                ],
              ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.items,
    required this.onApprove,
    required this.onReject,
    required this.onComplete,
  });

  final List<Map<String, dynamic>> items;
  final Future<void> Function(String) onApprove;
  final Future<void> Function(String) onReject;
  final Future<void> Function(String) onComplete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text("No bookings in this status"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = items[index];
        final id = booking["_id"]?.toString() ?? "";
        final status =
            (booking["status"] ?? "PENDING").toString().toUpperCase();
        final citizen = (booking["citizenId"] as Map?) ?? const {};
        final office = (booking["officeId"] as Map?) ?? const {};
        final service = (booking["serviceId"] as Map?) ?? const {};

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      citizen["fullName"]?.toString() ?? "Unknown Citizen",
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusBg(status),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _statusFg(status)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text("Phone: ${citizen["phone"] ?? "-"}"),
              Text("Office: ${office["name"] ?? "-"}"),
              Text("Service: ${service["name"] ?? "-"}"),
              Text("Date: ${booking["date"] ?? "-"}"),
              Text("Slot: ${booking["slot"] ?? "-"}"),
              const SizedBox(height: 12),
              if (status == "PENDING")
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: id.isEmpty ? null : () => onApprove(id),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981)),
                        child: const Text("Approve"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: id.isEmpty ? null : () => onReject(id),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red),
                        child: const Text("Reject"),
                      ),
                    ),
                  ],
                ),
              if (status == "APPROVED")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: id.isEmpty ? null : () => onComplete(id),
                    child: const Text("Mark Complete"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _statusBg(String status) {
    if (status == "PENDING") return const Color(0xFFFFF4EC);
    if (status == "APPROVED") return const Color(0xFFEFF4FF);
    if (status == "COMPLETED") return const Color(0xFFECFDF3);
    if (status == "REJECTED") return const Color(0xFFFEE2E2);
    return const Color(0xFFF1F5F9);
  }

  Color _statusFg(String status) {
    if (status == "PENDING") return const Color(0xFFB54708);
    if (status == "APPROVED") return const Color(0xFF1D4ED8);
    if (status == "COMPLETED") return const Color(0xFF15803D);
    if (status == "REJECTED") return const Color(0xFFB91C1C);
    return const Color(0xFF334155);
  }
}
