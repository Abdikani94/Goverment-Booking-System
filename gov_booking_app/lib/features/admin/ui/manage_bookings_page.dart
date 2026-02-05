import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gov_booking_app/core/api/api_endpoints.dart';
import 'package:gov_booking_app/core/network/dio_client.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class ManageBookingsPage extends ConsumerStatefulWidget {
  const ManageBookingsPage({super.key});

  @override
  ConsumerState<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends ConsumerState<ManageBookingsPage> {
  List<dynamic> allBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get(ApiEndpoints.adminBookings);
      if (response.data['success']) {
        setState(() {
          allBookings = response.data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  Future<void> _approveBooking(String id) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.patch(ApiEndpoints.adminApproveBooking(id));
      if (response.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking approved')));
        _loadBookings();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectBooking(String id, String reason) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.patch(
        ApiEndpoints.adminRejectBooking(id),
        data: {'reason': reason},
      );
      if (response.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking rejected')));
        _loadBookings();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _completeBooking(String id) async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.patch(ApiEndpoints.adminCompleteBooking(id));
      if (response.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking completed')),
        );
        _loadBookings();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showRejectDialog(String bookingId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Rejection Reason', hintText: 'Enter reason...'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _rejectBooking(bookingId, reasonController.text.trim());
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter bookings
    final pending = allBookings.where((b) => b['status'] == 'pending').toList();
    final approved = allBookings.where((b) => b['status'] == 'approved').toList();
    final completed = allBookings.where((b) => b['status'] == 'completed').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: const Text('All Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              children: [
                _BookingList(bookings: pending, onApprove: _approveBooking, onReject: _showRejectDialog, status: 'pending'),
                _BookingList(bookings: approved, onApprove: _approveBooking, onReject: _showRejectDialog, status: 'approved'),
                _BookingList(bookings: completed, onApprove: _approveBooking, onReject: _showRejectDialog, status: 'completed'),
              ],
            ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<dynamic> bookings;
  final Function(String) onApprove;
  final Function(String) onReject;
  final String status;

  const _BookingList({required this.bookings, required this.onApprove, required this.onReject, required this.status});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return Center(child: Text("No $status bookings"));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _BookingCard(
          booking: bookings[index],
          onApprove: () => onApprove(bookings[index]['_id']),
          onReject: () => onReject(bookings[index]['_id']),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _BookingCard({required this.booking, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] ?? 'pending';
    final citizenName = booking['citizenId']?['fullName'] ?? 'Unknown Citizen';
    final serviceName = booking['serviceId']?['name'] ?? 'Unknown Service';
    final date = booking['date'] ?? '';
    final time = booking['timeSlotId']?['startTime'] ?? '';

    // Mock images based on name using simple logic or assets
    // Since we don't have real images, we'll use an Avatar

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header with Color/Image - Simulated with Container
          Container(
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFFDBA74), // Orange shade like design
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            // In real app, put image here
            child: Center(child: Icon(Icons.person, size: 40, color: Colors.white.withOpacity(0.5))),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(citizenName, style: AppTypography.h3(context)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.work, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(serviceName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (status == 'pending')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Text("NEW", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text("$date, $time", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
                
                if (status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onApprove,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981), // Green
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 20),
                          label: const Text("Approve"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red), // Red border
                            backgroundColor: Colors.red.withOpacity(0.05),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
                  
                if (status == 'approved')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("Approved ✅", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
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
