
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/providers.dart';
import '../../../core/storage/token_store.dart';
import '../../../core/utils/app_error.dart';

class AuthState {
  final bool loading;
  final String? error;
  final String? role;
  final String? fullName;

  const AuthState({this.loading = false, this.error, this.role, this.fullName});

  AuthState copyWith({bool? loading, String? error, String? role, String? fullName}) {
    return AuthState(
      loading: loading ?? this.loading,
      error: error,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;
  AuthController(this.ref) : super(const AuthState());

  Future<String?> register({
    required String fullName,
    required String phone,
    required String nationalId,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final dio = ref.read(dioClientProvider).dio;

      final res = await dio.post("/auth/register", data: {
        "fullName": fullName,
        "phone": phone,
        "nationalId": nationalId,
        "password": password,
      });

      final data = res.data["data"];
      await TokenStore.saveToken(data["token"]);
      await TokenStore.saveRole(data["user"]["role"]);
      await TokenStore.saveUserName(data["user"]["fullName"]);
      await TokenStore.savePhone((data["user"]["phone"] ?? phone).toString());

      state = state.copyWith(loading: false, role: data["user"]["role"], fullName: data["user"]["fullName"]);
      return data["user"]["role"];
    } on DioException catch (e) {
      state = state.copyWith(loading: false, error: AppError.from(e));
      return null;
    } catch (e) {
      state = state.copyWith(loading: false, error: AppError.from(e));
      return null;
    }
  }

  Future<String?> login({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final dio = ref.read(dioClientProvider).dio;

      final res = await dio.post("/auth/login", data: {
        "phone": phone,
        "password": password,
      });

      final data = res.data["data"];
      await TokenStore.saveToken(data["token"]);
      await TokenStore.saveRole(data["user"]["role"]);
      await TokenStore.saveUserName(data["user"]["fullName"]);
      await TokenStore.savePhone((data["user"]["phone"] ?? phone).toString());

      state = state.copyWith(loading: false, role: data["user"]["role"], fullName: data["user"]["fullName"]);
      return data["user"]["role"];
    } on DioException catch (e) {
      state = state.copyWith(loading: false, error: AppError.from(e));
      return null;
    } catch (e) {
      state = state.copyWith(loading: false, error: AppError.from(e));
      return null;
    }
  }

  Future<void> logout() async {
    await TokenStore.clear();
    state = const AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
