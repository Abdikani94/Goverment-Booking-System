
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
import '../../../core/utils/app_error.dart';

class NewBookingPage extends ConsumerStatefulWidget {
  const NewBookingPage({super.key});

  @override
  ConsumerState<NewBookingPage> createState() => _NewBookingPageState();
}

class _NewBookingPageState extends ConsumerState<NewBookingPage> {
  String? officeId;
  String? serviceId;
  String date = DateTime.now().toIso8601String().split("T")[0];
  String slot = "09:30 AM";
  final note = TextEditingController();

  final List<String> _slots = const [
    "09:00 AM",
    "09:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "01:00 PM",
    "01:30 PM",
    "02:00 PM",
    "02:30 PM",
    "03:00 PM",
    "03:30 PM",
  ];

  List offices = [];
  List services = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    setState(() => loading = true);
    final dio = ref.read(dioClientProvider).dio;
    final res = await dio.get("/offices");
    offices = res.data["data"];
    setState(() => loading = false);
  }

  Future<void> _loadServices() async {
    if (officeId == null) return;
    final dio = ref.read(dioClientProvider).dio;
    final res = await dio.get("/services/by-office/$officeId");
    services = res.data["data"];
    setState(() {});
  }

  Future<void> _createBooking() async {
    final dio = ref.read(dioClientProvider).dio;
    try {
      await dio.post("/bookings", data: {
        "officeId": officeId,
        "serviceId": serviceId,
        "date": date,
        "slot": slot,
        "note": note.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking created")));
      context.go("/citizen/bookings");
    } on DioException catch (e) {
      if (!mounted) return;
      final String message = AppError.from(e, fallback: "Booking failed. Please try again.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(title: const Text("Select Date & Time"), backgroundColor: const Color(0xFFF4F6FB)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: officeId,
                        decoration: const InputDecoration(
                          labelText: "Office",
                          border: OutlineInputBorder(),
                        ),
                        items: offices
                            .map<DropdownMenuItem<String>>((o) => DropdownMenuItem(
                                  value: o["_id"],
                                  child: Text(o["name"]),
                                ))
                            .toList(),
                        onChanged: (v) {
                          officeId = v;
                          serviceId = null;
                          services = [];
                          _loadServices();
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: serviceId,
                        decoration: const InputDecoration(
                          labelText: "Service",
                          border: OutlineInputBorder(),
                        ),
                        items: services
                            .map<DropdownMenuItem<String>>((s) => DropdownMenuItem(
                                  value: s["_id"],
                                  child: Text(s["name"]),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => serviceId = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Date", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      CalendarDatePicker(
                        initialDate: DateTime.tryParse(date) ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        onDateChanged: (d) => setState(() => date = d.toIso8601String().split("T")[0]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Select Time", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _slots
                            .map(
                              (s) => ChoiceChip(
                                label: Text(s),
                                selected: slot == s,
                                onSelected: (_) => setState(() => slot = s),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Note (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: (officeId == null || serviceId == null) ? null : _createBooking,
                    child: const Text("Continue"),
                  ),
                )
              ],
            ),
    );
  }
}
