import 'package:flutter/material.dart';
import '../../../Shared/widgets/brand_app_bar.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notifications
    final notifications = [
      {
        "title": "Booking Approved",
        "body": "Your booking GOV-2026-000001 was approved for Feb 5.",
        "time": "2h ago",
        "isRead": false,
      },
      {
        "title": "Office Update",
        "body": "City Hall Main Office changed working hours for the holiday.",
        "time": "1d ago",
        "isRead": true,
      },
      {
        "title": "Welcome",
        "body": "Thanks for joining Gov Booking! You can now book services easily.",
        "time": "2d ago",
        "isRead": true,
      },
    ];

    return Scaffold(
      appBar: const BrandAppBar(title: "Notifications", showNotification: false),
      body: notifications.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text("Your inbox is empty", style: AppTypography.body(context)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final isRead = n['isRead'] as bool;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(

                  color: isRead ? Colors.transparent : AppColors.primarySoft.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.2)),


                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                       Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isRead ? AppColors.background : AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                          color: isRead ? AppColors.textMuted : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      if (!isRead)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),

                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(n['title'] as String, style: AppTypography.bodyMedium(context)?.copyWith(fontWeight: FontWeight.bold)),
                      Text(n['time'] as String, style: AppTypography.small(context)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(n['body'] as String, style: AppTypography.bodySmall(context)),
                  ),
                  onTap: () {},
                ),
              );
            },
          ),
    );
  }
}
