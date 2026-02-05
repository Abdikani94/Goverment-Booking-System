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
  String _roleFilter = "CITIZEN";
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider(_roleFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F7FB),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        ),
        title: const Text(
          "Users",
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TabChip(
                  label: "Citizens",
                  selected: _roleFilter == "CITIZEN",
                  onTap: () => setState(() => _roleFilter = "CITIZEN"),
                ),
                const SizedBox(width: 10),
                _TabChip(
                  label: "Admins",
                  selected: _roleFilter == "ADMIN",
                  onTap: () => setState(() => _roleFilter = "ADMIN"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 19, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error loading users: $e")),
              data: (users) {
                final filtered = users.where((u) {
                  if (_query.isEmpty) return true;
                  return u.fullName.toLowerCase().contains(_query) || u.phone.toLowerCase().contains(_query);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No users found"));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allUsersProvider(_roleFilter));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 90),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _UserRow(user: filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserSheet(context),
        backgroundColor: const Color(0xFF2456D6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create user", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
    String role = "ADMIN";

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
                            DropdownMenuItem(value: "ADMIN", child: Text("Admin")),
                            DropdownMenuItem(value: "CITIZEN", child: Text("Citizen")),
                          ],
                          onChanged: (value) => setLocalState(() => role = value ?? "ADMIN"),
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
                                SnackBar(content: Text("${role == "ADMIN" ? "Admin" : "Citizen"} created successfully")),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted || !pageContext.mounted) return;
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              SnackBar(content: Text("Create failed: $e")),
                            );
                          }
                      },
                        child: const Text("Create user"),
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

class _TabChip extends StatelessWidget {
  const _TabChip({
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF111827) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF111827) : const Color(0xFF6B7280),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _UserRow extends ConsumerWidget {
  const _UserRow({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.phone,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: user.isActive,
                  activeThumbColor: const Color(0xFF2456D6),
                  onChanged: (_) async {
                    try {
                      await ref.read(adminRepoProvider).toggleUserActive(user.id);
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
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}
