
import '../../../core/dio_client.dart';
import '../../../core/token_store.dart';

class AuthApi {
  Future<void> login(String phone, String password) async {
    final res = await DioClient.dio.post("/auth/login", data: {
      "phone": phone,
      "password": password,
    });

    final token = res.data["data"]["token"];
    await TokenStore.saveToken(token);

    // ignore: avoid_print
    print("✅ saved token: ${token.toString().substring(0, 20)}...");
  }
}
