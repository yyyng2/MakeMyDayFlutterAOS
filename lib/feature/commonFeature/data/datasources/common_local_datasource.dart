import 'package:shared_preferences/shared_preferences.dart';

class CommonLocalDatasource {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<T?> getDataFromSharedPreferences<T>(String key) async {
    final prefs = await _prefs;
    await prefs.reload();
    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    }
    return null;
  }

  Future<void> setDataFromSharedPreferences<T>(String key, T value) async {
    final prefs = await _prefs;
    if (T == String) {
      await prefs.setString(key, value as String);
    } else if (T == int) {
      await prefs.setInt(key, value as int);
    } else if (T == bool) {
      await prefs.setBool(key, value as bool);
    }
  }

  Future<void> removeDataFromSharedPreferences<T>(String key) async {
    final prefs = await _prefs;
    prefs.reload();
    prefs.remove(key) as T?;
  }
}