import 'package:shared_preferences/shared_preferences.dart';

class Store {
  const Store._();

  // Instance (kept in memory after init)
  static SharedPreferences? _preferences;

  // Keys
  static const String _accesstoken = "accestoken";
  static const String _emailKey = "email";
  static const String _typeKey = "type";
  static const String _isLoggedIn = "isLoggedIn";

  // -----------------------------
  // Init - call this in main()
  // -----------------------------
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // -----------------------------
  // Token
  // -----------------------------
  static Future<void> setToken(String value) async {
    await _preferences?.setString(_accesstoken, value);
  }

  static String? getToken() {
    return _preferences?.getString(_accesstoken);
  }

  // -----------------------------
  // Logged In
  // -----------------------------
  static Future<void> setLoggedIn(String value) async {
    await _preferences?.setString(_isLoggedIn, value);
  }

  static String? getLoggedIn() {
    return _preferences?.getString(_isLoggedIn);
  }

  // -----------------------------
  // Email
  // -----------------------------
  static Future<void> setEmail(String email) async {
    await _preferences?.setString(_emailKey, email);
  }

  static String? getEmail() {
    return _preferences?.getString(_emailKey);
  }

  // -----------------------------
  // Type
  // -----------------------------
  static Future<void> setType(String type) async {
    await _preferences?.setString(_typeKey, type);
  }

  static String? getType() {
    return _preferences?.getString(_typeKey);
  }

  // -----------------------------
  // Clear All Data
  // -----------------------------
  static Future<void> clear() async {
    await _preferences?.clear();
  }
}
