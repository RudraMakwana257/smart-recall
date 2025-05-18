import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeService extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _darkModeKey = 'darkMode';

  ThemeService(this._prefs) {
    darkMode = _prefs.getBool(_darkModeKey) ?? false;
  }

  bool _darkMode = false;
  bool get darkMode => _darkMode;

  ThemeData get theme => _darkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  set darkMode(bool value) {
    _darkMode = value;
    _prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  void toggleTheme() {
    darkMode = !darkMode;
  }

  Color get backgroundColor =>
      darkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
  Color get cardBackground =>
      darkMode ? AppTheme.darkCardBackground : AppTheme.lightCardBackground;
  Color get secondaryBackground =>
      darkMode ? AppTheme.darkSecondaryBackground : AppTheme.lightBackground;
  Color get textPrimary =>
      darkMode ? AppTheme.darkTextPrimary : AppTheme.darkNavy;
  Color get textSecondary =>
      darkMode ? AppTheme.darkTextSecondary : Colors.grey[600]!;

  LinearGradient get primaryGradient =>
      darkMode ? AppTheme.darkModeGradient : AppTheme.primaryGradient;
  LinearGradient get blueGradient => darkMode
      ? AppTheme.darkBlueGradient
      : LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
  LinearGradient get purpleGradient => darkMode
      ? AppTheme.darkPurpleGradient
      : LinearGradient(
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryPurple.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  List<BoxShadow> get shadows =>
      darkMode ? AppTheme.darkModeShadows : AppTheme.lightModeShadows;
}
