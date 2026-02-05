import 'package:dio/dio.dart';
import '../storage/secure_store.dart';
import 'api_endpoints.dart';
import 'api_error.dart';

class DioClient {
  DioClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Content-Type": "application/json"},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStore.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (e, handler) {
          final msg = e.response?.data is Map
              ? (e.response?.data["message"]?.toString() ?? "Request failed")
              : (e.message ?? "Request failed");
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: ApiError(msg, statusCode: e.response?.statusCode),
            ),
          );
        },
      ),
    );

  static ApiError normalizeError(Object e) {
    if (e is DioException && e.error is ApiError) return e.error as ApiError;
    return ApiError("Something went wrong. Please try again.");
  }
}
