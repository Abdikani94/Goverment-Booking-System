
import 'package:dio/dio.dart';
import '../../../core/storage/token_store.dart';

class AuthRepo {
  AuthRepo(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String nationalId,
    required String password,
  }) async {
    final res = await _dio.post('/api/auth/register', data: {
      'fullName': fullName,
      'phone': phone,
      'nationalId': nationalId,
      'password': password,
      // ✅ don't send role (backend forces citizen) OR send CITIZEN if your backend requires it
      // 'role': 'CITIZEN',
    });

    final data = Map<String, dynamic>.from(res.data['data'] ?? res.data);

    await TokenStore.saveToken(data['token']);
    await TokenStore.saveRole(data['user']['role']);

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post('/api/auth/login', data: {
      'phone': phone,
      'password': password,
    });

    final data = Map<String, dynamic>.from(res.data['data'] ?? res.data);

    await TokenStore.saveToken(data['token']);
    await TokenStore.saveRole(data['user']['role']);

    return data;
  }

  Future<void> logout() => TokenStore.clear();
}
