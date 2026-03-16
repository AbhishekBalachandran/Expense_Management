import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  final SharedPreferences _prefs;
  PrefsService({required SharedPreferences prefs}) : _prefs = prefs;

  static const String authToken = "auth_token";
  static const String name = "user_name";
  static const String hasOnboarded = "has_onboarded";

  // save token
  Future<void> saveToken(String token) async {
    await _prefs.setString(authToken, token);
  }

  // get token
  String? getToken() => _prefs.getString(authToken);

  // clear token
  Future<void> clearToken() async {
    await _prefs.remove(authToken);
  }

  // has token
  bool get hasToken => (_prefs.getString(authToken) ?? '').isNotEmpty;
  //get name
  String? getNickName() => _prefs.getString(name);
  // save name
  Future<void> saveName(String userName) async {
    await _prefs.setString(name, userName);
  }

  // set onboard
  Future<void> setOnboarded() async {
    await _prefs.setBool(hasOnboarded, true);
  }

  // has onboarded
  bool get isOnboarded => _prefs.getBool(hasOnboarded) ?? false;

  // clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
