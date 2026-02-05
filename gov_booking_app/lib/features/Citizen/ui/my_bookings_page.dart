
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/utils/app_error.dart';

class MyBookingsPage extends ConsumerStatefulWidget {
  const MyBookingsPage({super.key});

  @override
  ConsumerState<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends ConsumerState<MyBookingsPage> {
  List items = [];
  bool loading = true;
  String filter = "ALL";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final res = await dio.get("/bookings/mine");
      items = res.data["data"];
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppError.from(e, fallback: "Could not load bookings."))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filter == "ALL"
        ? items
        : items.where((e) => (e["status"] ?? "").toString().toUpperCase() == filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(title: const Text("Bookings"), backgroundColor: const Color(0xFFF4F6FB)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _StatusChip(
                        label: "All",
                        selected: filter == "ALL",
                        onTap: () => setState(() => filter = "ALL"),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: "Pending",
                        selected: filter == "PENDING",
                        onTap: () => setState(() => filter = "PENDING"),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: "Approved",
                        selected: filter == "APPROVED",
                        onTap: () => setState(() => filter = "APPROVED"),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(
                        label: "Completed",
                        selected: filter == "COMPLETED",
                        onTap: () => setState(() => filter = "COMPLETED"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final b = filtered[i];
                      final service = (b["serviceId"] is Map ? b["serviceId"]["name"] : "-") ?? "-";
                      final office = (b["officeId"] is Map ? b["officeId"]["name"] : "-") ?? "-";
                      final status = (b["status"] ?? "-").toString().toUpperCase();

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    service.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusBg(status),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(fontWeight: FontWeight.w800, color: _statusFg(status)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Office: $office"),
                            Text("Date: ${b["date"] ?? "-"} | Slot: ${b["slot"] ?? "-"}"),
                            if ((b["adminNote"] ?? "").toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text("Admin note: ${b["adminNote"]}"),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : const Color(0xFF334155), fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
