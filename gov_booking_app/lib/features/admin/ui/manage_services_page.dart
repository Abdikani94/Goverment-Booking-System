import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class ManageServicesPage extends ConsumerStatefulWidget {
  const ManageServicesPage({super.key});

  @override
  ConsumerState<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends ConsumerState<ManageServicesPage> {
  String? _officeId;

  @override
  Widget build(BuildContext context) {
    final officesAsync = ref.watch(allOfficesProvider);
    final servicesAsync = ref.watch(servicesByOfficeProvider(_officeId));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text("Manage Services"),
        backgroundColor: const Color(0xFFF4F6FB),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: officesAsync.when(
              data: (offices) => DropdownButtonFormField<String?>(
                initialValue: _officeId,
                decoration: const InputDecoration(
                  labelText: "Filter by office",
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text("All offices")),
                  ...offices.map((o) => DropdownMenuItem<String?>(value: o.id, child: Text(o.name))),
                ],
                onChanged: (v) => setState(() => _officeId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text("Failed to load offices: $e"),
            ),
          ),
          Expanded(
            child: servicesAsync.when(
              data: (services) {
                if (services.isEmpty) return const Center(child: Text("No services found"));
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = services[i];
                    final docs = s.requiredDocuments.join(", ");
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _showServiceDialog(context, ref, serviceId: s.id, initialName: s.name, initialDocs: docs),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () async {
                                  try {
                                    await ref.read(adminRepoProvider).toggleService(s.id);
                                    ref.invalidate(servicesByOfficeProvider(_officeId));
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Toggle failed: $e")));
                                  }
                                },
                                icon: const Icon(Icons.toggle_on_rounded),
                              ),
                            ],
                          ),
                          Text("Office: ${s.officeId ?? '-'}"),
                          const SizedBox(height: 6),
                          Text("Required docs: ${docs.isEmpty ? '-' : docs}"),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Failed to load services: $e")),
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDialog(
    BuildContext context,
    WidgetRef ref, {
    String? serviceId,
    String? initialName,
    String? initialDocs,
  }) {
    final nameCtrl = TextEditingController(text: initialName ?? "");
    final docsCtrl = TextEditingController(text: initialDocs ?? "");
    String? selectedOffice = _officeId;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(serviceId == null ? "Add Service" : "Edit Service"),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final offices = ref.watch(allOfficesProvider);
                    return offices.when(
                      data: (items) => DropdownButtonFormField<String>(
                        initialValue: selectedOffice,
                        decoration: const InputDecoration(labelText: "Office"),
                        items: items
                            .map((o) => DropdownMenuItem<String>(value: o.id, child: Text(o.name)))
                            .toList(),
                        onChanged: (v) => selectedOffice = v,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Service name")),
                const SizedBox(height: 10),
                TextField(
                  controller: docsCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Required docs (comma separated)",
                    hintText: "National ID, Passport photos, Proof of address",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            FilledButton(
              onPressed: () async {
                final officeId = selectedOffice?.trim();
                final name = nameCtrl.text.trim();
                final docs = docsCtrl.text
                    .split(",")
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (officeId == null || officeId.isEmpty || name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Office and service name are required")),
                  );
                  return;
                }

                final payload = {
                  "officeId": officeId,
                  "name": name,
                  "requiredDocs": docs,
                };

                try {
                  final repo = ref.read(adminRepoProvider);
                  if (serviceId == null) {
                    await repo.createService(payload);
                  } else {
                    await repo.updateService(serviceId, payload);
                  }
                  ref.invalidate(servicesByOfficeProvider(_officeId));
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed: $e")));
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
