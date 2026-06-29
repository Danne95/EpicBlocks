import 'package:epic_blocks/app/data/settings_repository.dart';
import 'package:flutter/foundation.dart';

/// App-wide settings state.
class SettingsController extends ChangeNotifier {
  /// Creates the controller.
  SettingsController(this._repository);

  final SettingsRepository _repository;

  AppSettings _settings = AppSettings.defaults;

  /// Whether dark mode is enabled.
  bool get darkMode => _settings.darkMode;

  /// Whether vibration feedback is enabled.
  bool get vibrationEnabled => _settings.vibrationEnabled;

  /// Whether sound feedback is enabled.
  bool get soundEnabled => _settings.soundEnabled;

  /// Loads persisted settings before startup.
  Future<void> loadSettings() async {
    _settings = _repository.loadSettings();
    notifyListeners();
  }

  /// Updates dark mode.
  Future<void> setDarkMode(bool value) async {
    if (value == darkMode) {
      return;
    }
    await _repository.setDarkMode(value);
    _settings = AppSettings(
      darkMode: value,
      vibrationEnabled: vibrationEnabled,
      soundEnabled: soundEnabled,
    );
    notifyListeners();
  }

  /// Updates vibration.
  Future<void> setVibrationEnabled(bool value) async {
    if (value == vibrationEnabled) {
      return;
    }
    await _repository.setVibrationEnabled(value);
    _settings = AppSettings(
      darkMode: darkMode,
      vibrationEnabled: value,
      soundEnabled: soundEnabled,
    );
    notifyListeners();
  }

  /// Updates sound.
  Future<void> setSoundEnabled(bool value) async {
    if (value == soundEnabled) {
      return;
    }
    await _repository.setSoundEnabled(value);
    _settings = AppSettings(
      darkMode: darkMode,
      vibrationEnabled: vibrationEnabled,
      soundEnabled: value,
    );
    notifyListeners();
  }
}
