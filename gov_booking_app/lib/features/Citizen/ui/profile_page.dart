import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/storage/token_store.dart';
import '../../../core/utils/app_error.dart';
import '../../auth/providers/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
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
      return <String, dynamic>{};
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? (data['message']?.toString() ?? '') : '';
      final isMissingRoute = e.response?.statusCode == 404 && message.toLowerCase().contains('route not found');
      if (isMissingRoute) {
        final name = await TokenStore.readUserName();
        final phone = await TokenStore.readPhone();
        final role = await TokenStore.readRole();
        return <String, dynamic>{
          'fullName': name ?? 'Citizen',
          'phone': phone ?? '-',
          'role': role ?? 'CITIZEN',
          'isActive': true,
        };
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _refresh() async {
    final fresh = _loadProfile();
    setState(() => _profileFuture = fresh);
    await fresh;
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'C';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFF4F6FB),
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
                      AppError.from(snapshot.error!, fallback: 'Could not load profile.'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = snapshot.data ?? <String, dynamic>{};
          final name = (user['fullName'] ?? '').toString().trim();
          final phone = (user['phone'] ?? '').toString().trim();
          final role = (user['role'] ?? 'CITIZEN').toString().toUpperCase();
          final isActive = (user['isActive'] ?? true) == true;
          final createdAt = (user['createdAt'] ?? '').toString();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x110F172A), blurRadius: 14, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFE0E7FF),
                        child: Text(
                          _initial(name.isEmpty ? 'Citizen' : name),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Citizen User' : name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phone.isEmpty ? '-' : phone,
                              style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600),
                            ),
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
                    _StatusBadge(
                      label: isActive ? 'Active Account' : 'Inactive Account',
                      color: isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      bg: isActive ? const Color(0xFFECFDF3) : const Color(0xFFFEE2E2),
                    ),
                    _StatusBadge(
                      label: role,
                      color: const Color(0xFF1D4ED8),
                      bg: const Color(0xFFEFF4FF),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoTile(label: 'Full Name', value: name.isEmpty ? '-' : name, icon: Icons.badge_outlined),
                const SizedBox(height: 10),
                _InfoTile(label: 'Phone Number', value: phone.isEmpty ? '-' : phone, icon: Icons.phone_outlined),
                const SizedBox(height: 10),
                _InfoTile(label: 'Role', value: role, icon: Icons.verified_user_outlined),
                const SizedBox(height: 10),
                _InfoTile(
                  label: 'Member Since',
                  value: createdAt.isEmpty ? '-' : createdAt.split('T').first,
                  icon: Icons.event_outlined,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go('/welcome');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0) context.go('/citizen');
          if (i == 1) context.go('/citizen/new');
          if (i == 2) context.go('/citizen/bookings');
          if (i == 3) context.go('/citizen/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Book'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border_rounded), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
