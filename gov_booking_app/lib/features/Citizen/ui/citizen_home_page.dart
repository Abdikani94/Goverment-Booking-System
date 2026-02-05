import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/storage/token_store.dart';
import '../../../core/utils/app_error.dart';
import '../../auth/providers/auth_controller.dart';

class CitizenHomePage extends ConsumerWidget {
  const CitizenHomePage({super.key});

  int _countByStatus(List<dynamic> items, String status) {
    return items.where((e) => (e["status"] ?? "").toString().toUpperCase() == status).length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsFuture = ref.watch(dioClientProvider).dio.get("/bookings/mine");
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 700;
    final h1 = isWide ? 38.0 : 30.0;
    final h2 = isWide ? 26.0 : 22.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Citizen Dashboard"),
        backgroundColor: const Color(0xFFF4F6FB),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Notifications coming soon")),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: "Profile",
            onPressed: () => context.go("/citizen/profile"),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go("/welcome");
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([TokenStore.readUserName(), bookingsFuture]),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppError.from(snap.error ?? "", fallback: "Could not load dashboard.")),
              ),
            );
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final data = snap.data!;
          final name = (data[0] ?? "Citizen").toString();
          final bookingRes = data[1] as Response<dynamic>;
          final payload = bookingRes.data;
          final items = payload is Map && payload["data"] is List ? (payload["data"] as List) : <dynamic>[];
          final pending = _countByStatus(items, "PENDING");
          final approved = _countByStatus(items, "APPROVED");

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE0E7FF),
                    child: Icon(Icons.person, color: Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CITIZEN PORTAL", style: TextStyle(letterSpacing: 1, color: Color(0xFF334E8F), fontWeight: FontWeight.w700)),
                        Text("Welcome Back", style: TextStyle(fontSize: h2, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Hello, $name", style: TextStyle(fontSize: h1, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text("What would you like to do today?", style: TextStyle(color: Color(0xFF38518D), fontSize: 16)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF1D4ED8)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Operational Hours: Saturday - Thursday (08:00 AM - 04:00 PM)",
                        style: TextStyle(color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => context.go("/citizen/new"),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text("Book New Appointment"),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => context.go("/citizen/bookings"),
                  icon: const Icon(Icons.bookmark_border_rounded),
                  label: const Text("Manage My Bookings"),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _SummaryCard(title: "Pending", value: "$pending", color: const Color(0xFFF59E0B))),
                  const SizedBox(width: 12),
                  Expanded(child: _SummaryCard(title: "Approved", value: "$approved", color: const Color(0xFF1D4ED8))),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) context.go("/citizen");
          if (i == 1) context.go("/citizen/new");
          if (i == 2) context.go("/citizen/bookings");
          if (i == 3) context.go("/citizen/profile");
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Book"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_rounded), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: "Profile"),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x100F172A), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}