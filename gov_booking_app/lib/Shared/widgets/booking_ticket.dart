import 'package:flutter/material.dart';
import 'package:gov_booking_app/theme/app_colors.dart';
import 'package:gov_booking_app/theme/app_typography.dart';

class BookingTicket extends StatelessWidget {
  final String serviceName;
  final String officeName;
  final String date;
  final String slot;
  final String referenceNumber;

  const BookingTicket({
    super.key,
    required this.serviceName,
    required this.officeName,
    required this.date,
    required this.slot,
    required this.referenceNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          Text('Booking Confirmed', style: AppTypography.h3(context)),
          const SizedBox(height: 8),
          Text('Reference: #$referenceNumber', style: AppTypography.label(context)?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 24),
          _TicketRow(label: 'Service', value: serviceName),
          const SizedBox(height: 16),
          _TicketRow(label: 'Office', value: officeName),
          const SizedBox(height: 16),
          _TicketRow(label: 'Date', value: date),
          const SizedBox(height: 16),
          _TicketRow(label: 'Time Slot', value: slot),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please arrive 10 minutes early with your national ID.',
                    style: AppTypography.bodySmall(context)?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final String label;
  final String value;
  const _TicketRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
