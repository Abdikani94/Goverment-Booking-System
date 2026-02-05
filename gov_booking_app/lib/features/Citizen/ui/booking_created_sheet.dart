import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';

class BookingCreatedSheet extends StatelessWidget {
  final String code;
  const BookingCreatedSheet({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.brandSoft,
                child:
                    Icon(Icons.check, size: 34, color: AppColors.brand),
              ),
              const SizedBox(height: 16),
              Text("Booking Created",
                  style: t.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                "Your appointment has been successfully scheduled.",
                style: t.bodyMedium?.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppColors.border, style: BorderStyle.solid),
                  color: AppColors.brandSoft,
                ),
                child: Column(
                  children: [
                    Text("CONFIRMATION CODE",
                        style: t.bodySmall?.copyWith(letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Text(code,
                        style: t.titleLarge?.copyWith(color: AppColors.brand)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: "Go to My bookings",
                onPressed: () {
                  Navigator.pop(context); // close sheet
                },
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_month),
                label: const Text("Add to Calendar"),
              ),
              const SizedBox(height: 8),
              Text(
                "Please bring a valid photo ID and your reference number to the appointment.",
                style: t.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
