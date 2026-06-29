import 'package:shared_preferences/shared_preferences.dart';

/// Persisted app settings.
class AppSettings {
  /// Creates app settings.
  const AppSettings({
    required this.darkMode,
    required this.vibrationEnabled,
    required this.soundEnabled,
  });

  /// Dark mode preference.
  final bool darkMode;

  /// Whether gameplay vibration feedback is enabled.
  final bool vibrationEnabled;

  /// Whether gameplay sound feedback is enabled.
  final bool soundEnabled;

  /// Default EpicPlay settings.
  static const defaults = AppSettings(
    darkMode: true,
    vibrationEnabled: false,
    soundEnabled: true,
  );
}

/// SharedPreferences-backed settings repository.
class SettingsRepository {
  /// Creates the repository.
  const SettingsRepository({required this.preferences});

  static const _darkModeKey = 'settings.dark_mode';
  static const _vibrationKey = 'settings.vibration_enabled';
  static const _soundKey = 'settings.sound_enabled';

  /// Preferences storage.
  final SharedPreferences preferences;

  /// Loads persisted settings or explicit defaults.
  AppSettings loadSettings() {
    return AppSettings(
      darkMode:
          preferences.getBool(_darkModeKey) ?? AppSettings.defaults.darkMode,
      vibrationEnabled:
          preferences.getBool(_vibrationKey) ??
          AppSettings.defaults.vibrationEnabled,
      soundEnabled:
          preferences.getBool(_soundKey) ?? AppSettings.defaults.soundEnabled,
    );
  }

  /// Persists dark mode.
  Future<void> setDarkMode(bool value) {
    return preferences.setBool(_darkModeKey, value);
  }

  /// Persists vibration.
  Future<void> setVibrationEnabled(bool value) {
    return preferences.setBool(_vibrationKey, value);
  }

  /// Persists sound.
  Future<void> setSoundEnabled(bool value) {
    return preferences.setBool(_soundKey, value);
  }
}
