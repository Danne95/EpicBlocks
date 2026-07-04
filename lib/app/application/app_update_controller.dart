import 'package:epic_blocks/app/data/app_update_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  /// The APK is being downloaded.
  downloading,

  /// The APK has downloaded and can be handed to Android.
  readyToInstall,

  /// The APK is being downloaded or handed to Android.
  gettingUpdate,

  /// A user-facing failure occurred.
  failed,
}

/// Coordinates user-initiated direct APK updates.
class AppUpdateController extends ChangeNotifier {
  /// Creates the controller.
  AppUpdateController(this.service);

  /// Service used for GitHub and Android update operations.
  final AppUpdateService service;

  AppUpdateButtonState _state = AppUpdateButtonState.idle;
  AppRelease? _availableRelease;
  String? _downloadedApkPath;
  String? _errorMessage;

  /// Current visible update state.
  AppUpdateButtonState get state => _state;

  /// Latest release information when an update is available.
  AppRelease? get availableRelease => _availableRelease;

  /// Concise user-facing failure text.
  String? get errorMessage => _errorMessage;

  /// Whether a downloaded APK is ready for Android's installer.
  bool get hasDownloadedApk => _downloadedApkPath != null;

  /// Checks for a newer release.
  Future<void> checkForUpdates() async {
    _availableRelease = null;
    _downloadedApkPath = null;
    _setState(AppUpdateButtonState.checking);
    _errorMessage = null;

    try {
      final result = await service.checkForUpdates();
      _availableRelease = result.release;
      _setState(
        result.isUpdateAvailable
            ? AppUpdateButtonState.updateAvailable
            : AppUpdateButtonState.upToDate,
      );
    } on AppUpdateException catch (error) {
      _fail(error.message);
    } on PlatformException catch (error) {
      _fail(_platformErrorMessage(error));
    } catch (_) {
      _fail('Could not check for updates.');
    }
  }

  /// Downloads and opens the installer for the available release.
  Future<void> getUpdate() async {
    final release = _availableRelease;
    if (release == null) {
      _fail('Check for updates before updating.');
      return;
    }

    _setState(AppUpdateButtonState.downloading);
    _errorMessage = null;

    try {
      _downloadedApkPath ??= await service.downloadReleaseApk(release);
      await _installDownloadedUpdate();
    } on AppUpdateException catch (error) {
      _fail(error.message);
    } on PlatformException catch (error) {
      _fail(_platformErrorMessage(error));
    } catch (_) {
      _fail('Could not get the update.');
    }
  }

  /// Downloads the latest APK into local app cache storage.
  Future<void> downloadUpdate() async {
    final release = _availableRelease;
    if (release == null) {
      _fail('Check for updates before downloading.');
      return;
    }

    _setState(AppUpdateButtonState.downloading);
    _errorMessage = null;

    try {
      _downloadedApkPath = await service.downloadReleaseApk(release);
      _setState(AppUpdateButtonState.readyToInstall);
    } on AppUpdateException catch (error) {
      _fail(error.message);
    } on PlatformException catch (error) {
      _fail(_platformErrorMessage(error));
    } catch (_) {
      _fail('Could not download the update.');
    }
  }

  /// Opens Android's installer for a previously downloaded APK.
  Future<void> installDownloadedUpdate() async {
    try {
      await _installDownloadedUpdate();
    } on AppUpdateException catch (error) {
      _fail(error.message);
    } on PlatformException catch (error) {
      _fail(_platformErrorMessage(error));
    } catch (_) {
      _fail('Could not start the Android installer.');
    }
  }

  Future<void> _installDownloadedUpdate() async {
    final apkPath = _downloadedApkPath;
    if (apkPath == null) {
      _fail('Download the update before installing.');
      return;
    }

    if (!await service.canRequestPackageInstalls()) {
      await service.openInstallPermissionSettings();
      _setState(AppUpdateButtonState.updateAvailable);
      return;
    }

    _setState(AppUpdateButtonState.gettingUpdate);
    await service.installApk(apkPath);
    _setState(AppUpdateButtonState.updateAvailable);
  }

  String _platformErrorMessage(PlatformException error) {
    final message = error.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return switch (error.code) {
      'apk_missing' => 'Downloaded update was not found.',
      'installer_unavailable' => 'Could not open installer.',
      'install_permission_settings_unavailable' =>
        'Could not open install permission settings.',
      'cache_directory_unavailable' => 'Could not prepare the update download.',
      _ => 'Could not get the update.',
    };
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
