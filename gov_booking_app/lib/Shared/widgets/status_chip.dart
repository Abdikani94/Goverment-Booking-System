import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum StatusType { pending, approved, rejected, completed, cancelled }

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  StatusType get _type {
    switch (status.toLowerCase()) {
      case "approved":
        return StatusType.approved;
      case "rejected":
        return StatusType.rejected;
      case "completed":
        return StatusType.completed;
      case "cancelled":
        return StatusType.rejected;
      default:
        return StatusType.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _type;
    Color color;
    bool isFilled = false;

    switch (type) {
      case StatusType.approved:
        color = AppColors.success;
        isFilled = true;
        break;
      case StatusType.rejected:
        color = AppColors.danger;
        isFilled = false;
        break;
      case StatusType.completed:
        color = AppColors.textMuted;
        isFilled = true;
        break;
      case StatusType.pending:
      default:
        color = AppColors.primary;
        isFilled = false;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        border: isFilled ? null : Border.all(color: color, width: 1.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isFilled ? Colors.white : color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

