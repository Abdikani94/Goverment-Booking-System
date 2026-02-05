import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/auth_repo.dart';

class AuthState {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({this.loading = false, this.error, this.user});

  AuthState copyWith({
    bool? loading,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error,
      user: user ?? this.user,
    );
  }
}

final authRepoProvider = Provider<AuthRepo>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthRepo(dio);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepoProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());
  final AuthRepo _repo;

  Future<void> register({
    required String fullName,
    required String phone,
    required String nationalId,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _repo.register(
        fullName: fullName,
        phone: phone,
        nationalId: nationalId,
        password: password,
      );
      state = state.copyWith(
        loading: false,
        user: Map<String, dynamic>.from(data['user']),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _repo.login(phone: phone, password: password);
      state = state.copyWith(
        loading: false,
        user: Map<String, dynamic>.from(data['user']),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }
}

// ✅ Backward-compatible alias for existing UI code
final authControllerProvider = authProvider;
