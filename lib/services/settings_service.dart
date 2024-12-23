// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyDataSync = 'data_sync_enabled';
  static const String _keyDarkMode = 'dark_mode_enabled';
  static const String _keyStepGoal = 'daily_step_goal';
  static const String _keySyncInterval = 'sync_interval';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  bool get notificationsEnabled => _prefs.getBool(_keyNotifications) ?? true;
  bool get dataSyncEnabled => _prefs.getBool(_keyDataSync) ?? true;
  bool get darkModeEnabled => _prefs.getBool(_keyDarkMode) ?? false;
  int get dailyStepGoal => _prefs.getInt(_keyStepGoal) ?? 10000;
  int get syncInterval => _prefs.getInt(_keySyncInterval) ?? 30;

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keyNotifications, value);
  }

  Future<void> setDataSyncEnabled(bool value) async {
    await _prefs.setBool(_keyDataSync, value);
  }

  Future<void> setDarkModeEnabled(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }

  Future<void> setDailyStepGoal(int value) async {
    await _prefs.setInt(_keyStepGoal, value);
  }

  Future<void> setSyncInterval(int minutes) async {
    await _prefs.setInt(_keySyncInterval, minutes);
  }
}