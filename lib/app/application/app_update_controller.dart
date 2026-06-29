import 'package:epic_blocks/app/data/app_update_service.dart';
import 'package:flutter/foundation.dart';

/// Visible update state in Settings.
enum AppUpdateButtonState {
  /// The user has not checked yet.
  idle,

  /// The app is checking GitHub Releases.
  checking,

  /// The latest release is installed.
  upToDate,

  /// A newer release can be installed.
  updateAvailable,

  /// The APK is being downloaded or handed to Android.
  gettingUpdate,

  /// A user-facing failure occurred.
  failed,
}

/// Coordinates user-initiated direct APK updates.
class AppUpdateController extends ChangeNotifier {
  /// Creates the controller.
  AppUpdateController(this._service);

  final AppUpdateService _service;

  AppUpdateButtonState _state = AppUpdateButtonState.idle;
  AppRelease? _availableRelease;
  String? _errorMessage;

  /// Current visible update state.
  AppUpdateButtonState get state => _state;

  /// Concise user-facing failure text.
  String? get errorMessage => _errorMessage;

  /// Checks for a newer release.
  Future<void> checkForUpdates() async {
    _setState(AppUpdateButtonState.checking);
    _errorMessage = null;

    try {
      final result = await _service.checkForUpdates();
      _availableRelease = result.isUpdateAvailable ? result.release : null;
      _setState(
        result.isUpdateAvailable
            ? AppUpdateButtonState.updateAvailable
            : AppUpdateButtonState.upToDate,
      );
    } on AppUpdateException catch (error) {
      _fail(error.message);
    } catch (_) {
      _fail('Could not check for updates.');
    }
  }

  /// Downloads and opens the installer for the available release.
  Future<void> getUpdate() async {
    final release = _availableRelease;
    if (release == null) {
      await checkForUpdates();
      return;
    }

    _setState(AppUpdateButtonState.gettingUpdate);
    _errorMessage = null;

    try {
      final apkPath = await _service.downloadReleaseApk(release);
      if (!await _service.canRequestPackageInstalls()) {
        await _service.openInstallPermissionSettings();
      }
      await _service.installApk(apkPath);
      _setState(AppUpdateButtonState.updateAvailable);
    } on AppUpdateException catch (error) {
      _fail(error.message);
    } catch (_) {
      _fail('Could not get the update.');
    }
  }

  void _fail(String message) {
    _errorMessage = message;
    _setState(AppUpdateButtonState.failed);
  }

  void _setState(AppUpdateButtonState value) {
    _state = value;
    notifyListeners();
  }
}
