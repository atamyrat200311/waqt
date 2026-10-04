import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

/// Minimal key-value contract so the repository can be tested with a map.
abstract interface class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

/// Production store. `SharedPreferencesAsync` reads through to the platform
/// each time, so the workmanager / widget isolates always see fresh values.
class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore([SharedPreferencesAsync? prefs])
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  @override
  Future<String?> getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, String>? initial]) : data = {...?initial};

  final Map<String, String> data;

  @override
  Future<String?> getString(String key) async => data[key];

  @override
  Future<void> setString(String key, String value) async => data[key] = value;

  @override
  Future<void> remove(String key) async => data.remove(key);
}

class SettingsRepository {
  SettingsRepository(this._store);

  final KeyValueStore _store;

  static const _key = 'waqt.settings.v1';

  Future<AppSettings> load() async {
    final raw = await _store.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) return AppSettings.fromJson(decoded);
    } on FormatException {
      // Corrupt blob: fall back to defaults rather than crash.
    }
    return const AppSettings();
  }

  Future<void> save(AppSettings settings) =>
      _store.setString(_key, jsonEncode(settings.toJson()));

  /// Small flags that are not user settings (e.g. dismissed cards).
  Future<String?> getFlag(String key) => _store.getString('waqt.flag.$key');
  Future<void> setFlag(String key, String value) => _store.setString('waqt.flag.$key', value);
}
