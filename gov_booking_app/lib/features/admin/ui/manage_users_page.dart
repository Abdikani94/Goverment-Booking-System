import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import '../providers/admin_provider.dart';

class ManageUsersPage extends ConsumerStatefulWidget {
  const ManageUsersPage({super.key});

  @override
  ConsumerState<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends ConsumerState<ManageUsersPage> {
  String? _roleFilter;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider(_roleFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Manage Users"),
        backgroundColor: const Color(0xFFF4F6FB),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserSheet(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text("Create User"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: "All",
                  selected: _roleFilter == null,
                  onTap: () => setState(() => _roleFilter = null),
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: "Admins",
                  selected: _roleFilter == "ADMIN",
                  onTap: () => setState(() => _roleFilter = "ADMIN"),
                ),
                const SizedBox(width: 10),
                _FilterChip(
                  label: "Citizens",
                  selected: _roleFilter == "CITIZEN",
                  onTap: () => setState(() => _roleFilter = "CITIZEN"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error loading users: $e")),
              data: (users) {
                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allUsersProvider(_roleFilter));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _UserCard(user: users[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateUserSheet(BuildContext context) async {
    final pageContext = this.context;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final nationalIdCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String role = "CITIZEN";

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create User",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    const Text("Admin can create Citizen or Admin accounts"),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Full Name"),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: "Phone"),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: nationalIdCtrl,
                      decoration: const InputDecoration(labelText: "National ID"),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Password"),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if (v.length < 6) return "Minimum 6 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (context, setLocalState) {
                        return DropdownButtonFormField<String>(
                          initialValue: role,
                          decoration: const InputDecoration(labelText: "Role"),
                          items: const [
                            DropdownMenuItem(value: "CITIZEN", child: Text("Citizen")),
                            DropdownMenuItem(value: "ADMIN", child: Text("Admin")),
                          ],
                          onChanged: (v) => setLocalState(() => role = v ?? "CITIZEN"),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          try {
                            await ref.read(adminRepoProvider).createUser({
                              "fullName": nameCtrl.text.trim(),
                              "phone": phoneCtrl.text.trim(),
                              "nationalId": nationalIdCtrl.text.trim(),
                              "password": passwordCtrl.text,
                              "role": role,
                            });
                            ref.invalidate(allUsersProvider(_roleFilter));
                            if (context.mounted && pageContext.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(pageContext).showSnackBar(
                                const SnackBar(content: Text("User created successfully")),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted || !pageContext.mounted) return;
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              SnackBar(content: Text("Create failed: $e")),
                            );
                          }
                        },
                        child: const Text("Create"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF334155),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = user.role.toUpperCase();
    final initials = user.fullName.trim().isEmpty
        ? "?"
        : user.fullName
            .trim()
            .split(" ")
            .where((e) => e.isNotEmpty)
            .take(2)
            .map((e) => e[0].toUpperCase())
            .join();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEFF4FF),
                child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 2),
                    Text(user.phone, style: const TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
              ),
              _RoleBadge(role: role),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text("National ID: ${user.nationalId}", style: const TextStyle(color: Color(0xFF475569)))),
              Row(
                children: [
                  Text(
                    user.isActive ? "Active" : "Disabled",
                    style: TextStyle(
                      color: user.isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Switch(
                    value: user.isActive,
                    onChanged: (_) async {
                      try {
                        await ref.read(adminRepoProvider).toggleUserActive(user.id);
                        ref.invalidate(allUsersProvider(null));
                        ref.invalidate(allUsersProvider("ADMIN"));
                        ref.invalidate(allUsersProvider("CITIZEN"));
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Update failed: $e")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == "ADMIN";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFEEF2FF) : const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isAdmin ? const Color(0xFF4338CA) : const Color(0xFF15803D),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
