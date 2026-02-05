
import 'package:dio/dio.dart';
import '../storage/token_store.dart';

class DioClient {
  // IMPORTANT: must be http on web
  static const baseUrl = "http://localhost:5000/api";

  final Dio dio;

  DioClient._(this.dio);

  factory DioClient() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {"Content-Type": "application/json"},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStore.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
      ),
    );

    return DioClient._(dio);
  }
}
