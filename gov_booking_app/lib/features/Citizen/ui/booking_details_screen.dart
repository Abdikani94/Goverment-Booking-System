import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../Shared/widgets/brand_app_bar.dart';
import '../../../Shared/widgets/primary_button.dart';
import '../../../Shared/widgets/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_theme.dart';
import '../providers/citizen_provider.dart';
import '../models/booking_models.dart';


class BookingDetailsPage extends ConsumerStatefulWidget {
  final String bookingId;
  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends ConsumerState<BookingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: const BrandAppBar(title: "Booking Details", showNotification: false),
      body: bookingsAsync.when(
        data: (bookings) {
          final b = bookings.cast<Booking?>().firstWhere((element) => element?.id == widget.bookingId, orElse: () => null);
          if (b == null) return const Center(child: Text("Booking not found"));


          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: StatusChip(status: b.status)),
                const SizedBox(height: 24),
                
                _InfoSection(
                  title: "Booking Information",
                  children: [
                    _DetailRow(label: "Booking Code", value: b.bookingCode),
                    _DetailRow(label: "Service", value: b.serviceName ?? "N/A"),
                    _DetailRow(
                      label: "Date & Time", 
                      value: "${DateFormat('MMM d, yyyy').format(DateTime.parse(b.date))} • ${b.timeSlot}",
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _InfoSection(
                  title: "Office Details",
                  children: [
                    _DetailRow(label: "Office", value: b.officeName ?? "N/A"),
                    const SizedBox(height: 12),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map_outlined, color: AppColors.primary),
                            SizedBox(height: 4),
                            Text("Map Preview", style: TextStyle(color: AppColors.primary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (b.status == "rejected" && b.rejectionReason != null) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: "Rejection Reason",
                    titleColor: AppColors.danger,
                    children: [
                      Text(b.rejectionReason!, style: AppTypography.body(context)),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
                if (b.status == "pending")
                  PrimaryButton(
                    text: "Cancel Booking",
                    isSecondary: true,
                    onPressed: () => _showCancelModal(context, b.id),
                  ),
                if (b.status == "approved") ...[
                   PrimaryButton(text: "Add to Calendar", onPressed: () {}),
                   const SizedBox(height: 12),
                   PrimaryButton(text: "Get Directions", isSecondary: true, onPressed: () {}),
                ],
                if (b.status == "completed")
                   PrimaryButton(text: "Download Receipt", onPressed: () {}),
                
                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  void _showCancelModal(BuildContext context, String id) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cancel booking?", style: AppTypography.section(context)),
            const SizedBox(height: 8),
            Text("Are you sure you want to cancel this appointment? This action cannot be undone.", style: AppTypography.body(context)),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(hintText: "Reason for cancellation (optional)"),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: "Keep booking",
                    isSecondary: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: "Yes, Cancel",
                    onPressed: () {
                       // Call cancel API
                       Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? titleColor;

  const _InfoSection({required this.title, required this.children, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge(context)?.copyWith(fontSize: 14, color: titleColor ?? AppColors.textMuted)),

          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium(context)?.copyWith(color: AppColors.textMuted)),
          Text(value, style: AppTypography.bodyMedium(context)?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
