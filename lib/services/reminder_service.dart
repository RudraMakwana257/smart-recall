import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderService extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _reminderEnabledKey = 'reminder_enabled';
  static const String _dailyGoalKey = 'daily_goal';

  ReminderService(this._prefs) {
    _loadSettings();
  }

  bool _isReminderEnabled = false;
  int _dailyGoal = 10;

  bool get isReminderEnabled => _isReminderEnabled;
  int get dailyGoal => _dailyGoal;

  void _loadSettings() {
    _isReminderEnabled = _prefs.getBool(_reminderEnabledKey) ?? false;
    _dailyGoal = _prefs.getInt(_dailyGoalKey) ?? 10;
    notifyListeners();
  }

  Future<void> toggleReminder(bool value) async {
    _isReminderEnabled = value;
    await _prefs.setBool(_reminderEnabledKey, value);
    notifyListeners();
  }

  Future<void> setDailyGoal(int value) async {
    _dailyGoal = value;
    await _prefs.setInt(_dailyGoalKey, value);
    notifyListeners();
  }
}
