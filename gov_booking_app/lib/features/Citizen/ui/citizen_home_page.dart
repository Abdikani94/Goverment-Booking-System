import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/storage/token_store.dart';
import '../../../core/utils/app_error.dart';

class CitizenHomePage extends ConsumerWidget {
  const CitizenHomePage({super.key});

  int _countByStatus(List<dynamic> items, String status) {
    return items.where((e) => (e["status"] ?? "").toString().toUpperCase() == status).length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsFuture = ref.watch(dioClientProvider).dio.get("/bookings/mine");

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Citizen Dashboard",
          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
        ),
        backgroundColor: const Color(0xFFF6F7FB),
        actions: [
          IconButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Notifications coming soon")),
            ),
            icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF111827)),
          ),
          const SizedBox(width: 8),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
            children: [
              Text(
                "Hello, $name",
                style: const TextStyle(
                  fontSize: 36,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2456D6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.go("/citizen/new"),
                  child: const Text(
                    "Book appointment",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE7EAF0),
                    foregroundColor: const Color(0xFF111827),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.go("/citizen/bookings"),
                  child: const Text(
                    "My bookings",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Summary",
                style: TextStyle(
                  fontSize: 36,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _SummaryCard(title: "Pending", value: "$pending")),
                  const SizedBox(width: 12),
                  Expanded(child: _SummaryCard(title: "Approved", value: "$approved")),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Working days",
                          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Monday - Friday",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "8:00 AM - 5:00 PM",
                          style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 104,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF2F3F5), Color(0xFFE6E8ED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 20,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 5, color: const Color(0xFFBFC5CE)),
                        ),
                        Positioned(
                          left: 29,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 2, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Row(
                            children: List.generate(
                              4,
                              (index) => Container(
                                margin: const EdgeInsets.only(left: 3),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD5D9DF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF111827),
        unselectedItemColor: const Color(0xFF6B7280),
        showUnselectedLabels: true,
        onTap: (i) {
          if (i == 0) context.go("/citizen");
          if (i == 1) context.go("/citizen/new");
          if (i == 2) context.go("/citizen/bookings");
          if (i == 3) context.go("/citizen/profile");
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Book"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_rounded), label: "My Bookings"),
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
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 38,
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
