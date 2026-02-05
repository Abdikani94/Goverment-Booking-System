import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gov_booking_app/core/network/dio_client.dart';
import '../data/citizen_repo.dart';
import '../models/booking_models.dart';

final citizenRepoProvider = Provider<CitizenRepo>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return CitizenRepo(dio);
});

final officesProvider = FutureProvider<List<Office>>((ref) async {
  return ref.watch(citizenRepoProvider).getOffices();
});

final servicesProvider =
    FutureProvider.family<List<GovernmentService>, String>((ref, officeId) async {
  return ref.watch(citizenRepoProvider).getServicesForOffice(officeId);
});

final slotsProvider =
    FutureProvider.family<List<TimeSlot>, ({String officeId, String date})>(
        (ref, args) async {
  return ref
      .watch(citizenRepoProvider)
      .getSlots(officeId: args.officeId, date: args.date);
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  return ref.watch(citizenRepoProvider).myBookings();
});

