import 'user_model.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Your backend returns:
    // { success: true, data: { token: "...", user: {...} } }
    final data = (json["data"] as Map<String, dynamic>? ?? {});
    return AuthResponse(
      token: data["token"]?.toString() ?? "",
      user: UserModel.fromJson(data["user"] ?? {}),
    );
  }
}
