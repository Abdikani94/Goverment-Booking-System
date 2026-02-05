import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_controller.dart';
import '../providers/admin_provider.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFFF4F6FB),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.go('/admin/profile'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go("/welcome");
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Today's Overview",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Real-time booking status",
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _OverviewChip(
                  title: "Pending",
                  value: (stats["pendingBookings"] ?? 0).toString(),
                  bg: const Color(0xFFFFF4EC),
                  border: const Color(0xFFFDD8B5),
                  color: const Color(0xFFB54708),
                ),
                _OverviewChip(
                  title: "Approved",
                  value: (stats["approvedBookings"] ?? 0).toString(),
                  bg: const Color(0xFFEFF4FF),
                  border: const Color(0xFFC8DBFF),
                  color: const Color(0xFF1D4ED8),
                ),
                _OverviewChip(
                  title: "Completed",
                  value: (stats["completedBookings"] ?? 0).toString(),
                  bg: const Color(0xFFECFDF3),
                  border: const Color(0xFFBBF7D0),
                  color: const Color(0xFF15803D),
                ),
                _OverviewChip(
                  title: "Rejected",
                  value: (stats["rejectedBookings"] ?? 0).toString(),
                  bg: const Color(0xFFFEE2E2),
                  border: const Color(0xFFFECACA),
                  color: const Color(0xFFB91C1C),
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 28),
          const Text(
            "Quick Management",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              _AdminCard(
                title: "Manage Offices",
                subtitle: "Create / edit / disable",
                icon: Icons.account_balance_rounded,
                color: const Color(0xFF2563EB),
                onTap: () => context.go("/admin/offices"),
              ),
              _AdminCard(
                title: "Manage Services",
                subtitle: "Docs and office mapping",
                icon: Icons.design_services_rounded,
                color: const Color(0xFF334155),
                onTap: () => context.go("/admin/services"),
              ),
              _AdminCard(
                title: "Booking Queue",
                subtitle: "Approve / reject / complete",
                icon: Icons.fact_check_outlined,
                color: const Color(0xFF0F766E),
                onTap: () => context.go("/admin/bookings"),
              ),
              _AdminCard(
                title: "Manage Users",
                subtitle: "Create admin / citizen",
                icon: Icons.supervised_user_circle_outlined,
                color: const Color(0xFF7C3AED),
                onTap: () => context.go("/admin/users"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({
    required this.title,
    required this.value,
    required this.bg,
    required this.border,
    required this.color,
  });

  final String title;
  final String value;
  final Color bg;
  final Color border;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 34, color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}