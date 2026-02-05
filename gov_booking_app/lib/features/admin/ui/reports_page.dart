import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Shared/widgets/brand_app_bar.dart';
import '../../../Shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../providers/admin_provider.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(title: "Reports", showNotification: false),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Daily"),
              Tab(text: "Monthly"),
              Tab(text: "Yearly"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ReportView(type: "Daily"),
                _ReportView(type: "Monthly"),
                _ReportView(type: "Yearly"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportView extends ConsumerWidget {
  final String type;
  const _ReportView({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, this would fetch specific report data based on 'type' and a date picker
    final statsAsync = ref.watch(adminStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$type Report", style: AppTypography.h3(context)),
              OutlinedButton.icon(
                onPressed: () {}, // Open date picker
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text("Select Date"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          statsAsync.when(
            data: (stats) => Column(
              children: [
                _ReportCard(
                  label: "Total Bookings",
                  value: "${stats['totalToday'] ?? 100}", // Mock fallback if empty
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                 Row(
                  children: [
                    Expanded(child: _ReportCard(label: "Pending", value: "${stats['pending'] ?? 20}", color: Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _ReportCard(label: "Approved", value: "${stats['approved'] ?? 60}", color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _ReportCard(label: "Completed", value: "${stats['completed'] ?? 50}", color: Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _ReportCard(label: "Rejected", value: "${stats['rejected'] ?? 5}", color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Most Requested Service", style: AppTypography.small(context)),
                      const SizedBox(height: 8),
                      Text("Passport Renewal", style: AppTypography.h3(context)),
                      Text("45% of total bookings", style: AppTypography.bodySmall(context)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: "Export PDF",
                  onPressed: () {}, 
                  isSecondary: true,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: "Export CSV",
                  onPressed: () {}, 
                  isSecondary: true,
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e")),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReportCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.small(context)?.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h3(context)?.copyWith(color: color)),
        ],
      ),
    );
  }
}
