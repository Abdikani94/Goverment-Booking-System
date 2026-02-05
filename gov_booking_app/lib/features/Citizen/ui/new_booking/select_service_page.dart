
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectServicePage extends StatelessWidget {
  final String officeId;
  final String officeName;

  const SelectServicePage({super.key, required this.officeId, required this.officeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text('Services • $officeName'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ServiceTile(
            title: "Passport Renewal",
            onTap: () => context.go(
              '/citizen/book/select-datetime?officeId=$officeId&serviceId=passport_renew&serviceName=Passport%20Renewal',
            ),
          ),
          const SizedBox(height: 10),
          _ServiceTile(
            title: "New ID Card",
            onTap: () => context.go(
              '/citizen/book/select-datetime?officeId=$officeId&serviceId=id_new&serviceName=New%20ID%20Card',
            ),
          ),
          const SizedBox(height: 10),
          _ServiceTile(
            title: "Notary Service",
            onTap: () => context.go(
              '/citizen/book/select-datetime?officeId=$officeId&serviceId=notary&serviceName=Notary%20Service',
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _ServiceTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6ECF6)),
        ),
        child: Row(
          children: [
            const Icon(Icons.badge_outlined, color: Color(0xFF1F57D6)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
