import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'firebase_token';
  static late SharedPreferences _prefs; 

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  static bool isLoggedIn() {
    final token = _prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty; 
  }

  static Future<void> logout() async {
    await _prefs.remove(_tokenKey);
  }
}