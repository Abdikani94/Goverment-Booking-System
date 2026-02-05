
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectOfficePage extends StatelessWidget {
  const SelectOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Select Office'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OfficeCard(
            name: "Department of Motor Vehicles",
            desc: "Driver's license renewals and vehicle registration services.",
            open: true,
            onTap: () => context.go(
              '/citizen/book/select-service?officeId=dmv&officeName=DMV',
            ),
          ),
          const SizedBox(height: 12),
          _OfficeCard(
            name: "Social Security Office",
            desc: "Retirement benefits, IDs, and registration.",
            open: true,
            onTap: () => context.go(
              '/citizen/book/select-service?officeId=sso&officeName=SSO',
            ),
          ),
          const SizedBox(height: 12),
          _OfficeCard(
            name: "Passport Agency",
            desc: "New passports and renewal services.",
            open: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final String name;
  final String desc;
  final bool open;
  final VoidCallback onTap;

  const _OfficeCard({
    required this.name,
    required this.desc,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECF6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: open ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.apartment, size: 52, color: Color(0xFF1F57D6)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: open ? const Color(0xFF1DB954) : const Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    open ? "OPEN NOW" : "CLOSED",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: open ? const Color(0xFF1DB954) : const Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Color(0xFF667085))),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: open ? onTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: open ? const Color(0xFF1F57D6) : const Color(0xFFE6ECF6),
                    foregroundColor: open ? Colors.white : const Color(0xFF98A2B3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(open ? "Select" : "View"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
