
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectDateTimePage extends StatefulWidget {
  final String officeId;
  final String serviceId;
  final String serviceName;

  const SelectDateTimePage({
    super.key,
    required this.officeId,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<SelectDateTimePage> createState() => _SelectDateTimePageState();
}

class _SelectDateTimePageState extends State<SelectDateTimePage> {
  String selected = "09:30 AM";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.serviceName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),

            const Text("Time slots", style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                "08:00 AM",
                "08:30 AM",
                "09:30 AM",
                "10:00 AM",
                "10:30 AM",
                "01:00 PM",
                "02:00 PM",
                "02:30 PM",
              ].map((t) {
                final isSel = t == selected;
                return ChoiceChip(
                  label: Text(t),
                  selected: isSel,
                  onSelected: (_) => setState(() => selected = t),
                  selectedColor: const Color(0xFF1F57D6),
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : const Color(0xFF1F57D6),
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSel ? const Color(0xFF1F57D6) : const Color(0xFFBFD0FF),
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  context.go(
                    '/citizen/book/review'
                    '?officeId=${widget.officeId}'
                    '&serviceId=${widget.serviceId}'
                    '&slot=${Uri.encodeComponent(selected)}',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F57D6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
