import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/storage/token_store.dart';
import '../../../core/utils/app_error.dart';
import '../../auth/providers/auth_controller.dart';

class AdminProfilePage extends ConsumerStatefulWidget {
  const AdminProfilePage({super.key});

  @override
  ConsumerState<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends ConsumerState<AdminProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get('/auth/me');
      final data = response.data;

      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? (data['message']?.toString() ?? '') : '';
      final isMissingRoute = e.response?.statusCode == 404 && message.toLowerCase().contains('route not found');
      if (isMissingRoute) {
        final name = await TokenStore.readUserName();
        final phone = await TokenStore.readPhone();
        final role = await TokenStore.readRole();
        return <String, dynamic>{
          'fullName': name ?? 'Admin',
          'phone': phone ?? '-',
          'role': role ?? 'ADMIN',
          'nationalId': '-',
          'isActive': true,
        };
      }
      rethrow;
    }
    return <String, dynamic>{};
  }

  Future<void> _refresh() async {
    final next = _loadProfile();
    setState(() => _profileFuture = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FB),
        title: const Text('Admin Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppError.from(snapshot.error!, fallback: 'Unable to load admin profile.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final user = snapshot.data ?? <String, dynamic>{};
          final fullName = (user['fullName'] ?? 'Admin').toString();
          final phone = (user['phone'] ?? '-').toString();
          final role = (user['role'] ?? 'ADMIN').toString().toUpperCase();
          final isActive = (user['isActive'] ?? true) == true;
          final nationalId = (user['nationalId'] ?? '-').toString();
          final createdAt = (user['createdAt'] ?? '').toString();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF1D4ED8),
                        child: Text(
                          fullName.trim().isEmpty ? 'A' : fullName.trim()[0].toUpperCase(),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(phone, style: const TextStyle(color: Color(0xFFCBD5E1))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Badge(
                      text: isActive ? 'Active Account' : 'Inactive Account',
                      fg: isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      bg: isActive ? const Color(0xFFECFDF3) : const Color(0xFFFEE2E2),
                    ),
                    _Badge(text: role, fg: const Color(0xFF1D4ED8), bg: const Color(0xFFEFF4FF)),
                  ],
                ),
                const SizedBox(height: 14),
                _AdminInfoTile(icon: Icons.badge_outlined, label: 'Full Name', value: fullName),
                const SizedBox(height: 10),
                _AdminInfoTile(icon: Icons.phone_outlined, label: 'Phone', value: phone),
                const SizedBox(height: 10),
                _AdminInfoTile(icon: Icons.credit_card_outlined, label: 'National ID', value: nationalId),
                const SizedBox(height: 10),
                _AdminInfoTile(icon: Icons.shield_outlined, label: 'Role', value: role),
                const SizedBox(height: 10),
                _AdminInfoTile(
                  icon: Icons.event_outlined,
                  label: 'Member Since',
                  value: createdAt.isEmpty ? '-' : createdAt.split('T').first,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go('/welcome');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminInfoTile extends StatelessWidget {
  const _AdminInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.fg,
    required this.bg,
  });

  final String text;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}
