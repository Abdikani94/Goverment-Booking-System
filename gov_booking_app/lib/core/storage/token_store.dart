
import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _kToken = 'token';
  static const _kRole = 'role';
  static const _kUser = 'user_fullname';
  static const _kPhone = 'user_phone';

  static Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
  }

  static Future<String?> readToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<void> saveRole(String role) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kRole, role);
  }

  static Future<String?> readRole() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRole);
  }

  static Future<void> saveUserName(String name) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kUser, name);
  }

  static Future<String?> readUserName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kUser);
  }

  static Future<void> savePhone(String phone) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kPhone, phone);
  }

  static Future<String?> readPhone() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kPhone);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kRole);
    await sp.remove(_kUser);
    await sp.remove(_kPhone);
  }
}
