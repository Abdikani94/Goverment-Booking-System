import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Citizen/models/office_model.dart';
import '../providers/admin_provider.dart';

class ManageOfficesPage extends ConsumerWidget {
  const ManageOfficesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officesAsync = ref.watch(allOfficesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          title: const Text("Manage Offices"),
          backgroundColor: const Color(0xFFF4F6FB),
          bottom: TabBar(
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Inactive"),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showOfficeDialog(context, ref),
          child: const Icon(Icons.add),
        ),
        body: officesAsync.when(
          data: (offices) {
            final active = offices.where((o) => o.isActive).toList();
            final inactive = offices.where((o) => !o.isActive).toList();
            return TabBarView(
              children: [
                _OfficeList(offices: active),
                _OfficeList(offices: inactive),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error loading offices: $e")),
        ),
      ),
    );
  }

  void _showOfficeDialog(BuildContext context, WidgetRef ref, {String? id, String? name, String? location}) {
    final nameCtrl = TextEditingController(text: name ?? "");
    final locationCtrl = TextEditingController(text: location ?? "");

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? "Add Office" : "Edit Office"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Office name")),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: "Location")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () async {
              final payload = {
                "name": nameCtrl.text.trim(),
                "location": locationCtrl.text.trim(),
                "workingDays": ["sat", "sun", "mon", "tue", "wed", "thu"],
                "openTime": "08:00",
                "closeTime": "17:00",
                "slotDurationMinutes": 30,
                "defaultCapacityPerSlot": 10,
              };

              try {
                final repo = ref.read(adminRepoProvider);
                if (id == null) {
                  await repo.createOffice(payload);
                } else {
                  await repo.updateOffice(id, payload);
                }
                ref.invalidate(allOfficesProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed: $e")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

class _OfficeList extends ConsumerWidget {
  const _OfficeList({required this.offices});

  final List<Office> offices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (offices.isEmpty) return const Center(child: Text("No offices"));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: offices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final o = offices[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEFF4FF),
                child: Icon(Icons.account_balance_rounded, color: Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(o.location, style: const TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditDialog(context, ref, o.id, o.name, o.location),
                icon: const Icon(Icons.edit_outlined),
              ),
              Switch(
                value: o.isActive,
                onChanged: (_) async {
                  try {
                    await ref.read(adminRepoProvider).toggleOffice(o.id);
                    ref.invalidate(allOfficesProvider);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Toggle failed: $e")));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, String id, String name, String location) {
    final nameCtrl = TextEditingController(text: name);
    final locationCtrl = TextEditingController(text: location);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Office"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Office name")),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: "Location")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          FilledButton(
            onPressed: () async {
              final payload = {
                "name": nameCtrl.text.trim(),
                "location": locationCtrl.text.trim(),
              };
              try {
                await ref.read(adminRepoProvider).updateOffice(id, payload);
                ref.invalidate(allOfficesProvider);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
