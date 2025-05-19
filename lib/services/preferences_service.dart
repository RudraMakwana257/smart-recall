import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static final PreferencesService _instance = PreferencesService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<bool> get hasSeenOnboarding async {
    await init();
    return _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await init();
    await _prefs.setBool(_hasSeenOnboardingKey, value);
  }
}
