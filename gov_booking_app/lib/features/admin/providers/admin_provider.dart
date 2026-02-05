import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/admin_repo.dart';
import '../../Citizen/models/office_model.dart';
import '../../Citizen/models/service_model.dart';
import '../../auth/models/user_model.dart';

final adminRepoProvider = Provider<AdminRepo>((ref) {
  return AdminRepo(ref.watch(dioClientProvider).dio);
});

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(adminRepoProvider);
  final stats = await repo.getStats();
  final summary = await repo.getSummaryReport();
  
  return {
    ...stats,
    'topServices': summary['topServices'] ?? [],
    'byStatus': summary['byStatus'] ?? {},
  };
});

final allOfficesProvider = FutureProvider<List<Office>>((ref) async {
  return ref.watch(adminRepoProvider).getAllOffices();
});

final allServicesProvider = FutureProvider<List<GovernmentService>>((ref) async {
  return ref.watch(adminRepoProvider).getAllServices();
});

final servicesByOfficeProvider =
    FutureProvider.family<List<GovernmentService>, String?>((ref, officeId) async {
  return ref.watch(adminRepoProvider).getAllServices(officeId: officeId);
});

final allUsersProvider = FutureProvider.family<List<UserModel>, String?>((ref, role) async {
  return ref.watch(adminRepoProvider).getAllUsers(role: role);
});
