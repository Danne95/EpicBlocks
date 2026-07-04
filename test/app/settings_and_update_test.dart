import 'dart:convert';

import 'package:epic_blocks/app/application/app_update_controller.dart';
import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/app/data/app_update_service.dart';
import 'package:epic_blocks/app/data/settings_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('settings load explicit defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = SettingsController(
      SettingsRepository(preferences: preferences),
    );

    await controller.loadSettings();

    expect(controller.darkMode, isTrue);
    expect(controller.vibrationEnabled, isFalse);
    expect(controller.soundEnabled, isTrue);
  });

  test('version comparison parses v-prefixed and plain semver', () {
    expect(AppVersion.parse('v1.2.3').label, '1.2.3');
    expect(AppVersion.parse('1.2.4').compareTo(AppVersion.parse('1.2.3')), 1);
    expect(AppVersion.parse('1.2.3').compareTo(AppVersion.parse('v1.2.3')), 0);
    expect(
      () => AppVersion.parse('release-one'),
      throwsA(isA<AppUpdateException>()),
    );
  });

  test('release parser accepts EpicBlocks and default APK asset names', () {
    final service = AppUpdateService();
    final labeledRelease = service.parseReleaseJson(
      jsonEncode({
        'tag_name': 'v0.1.1',
        'body': 'Labeled build',
        'assets': [
          {
            'name': 'app-release.apk',
            'label': 'EpicBlocks.apk',
            'browser_download_url': 'https://example.com/app-release.apk',
          },
        ],
      }),
    );
    final epicBlocksRelease = service.parseReleaseJson(
      jsonEncode({
        'tag_name': 'v0.2.0',
        'body': 'New blocks',
        'assets': [
          {
            'name': 'ignored.txt',
            'browser_download_url': 'https://example.com/ignored.txt',
          },
          {
            'name': 'EpicBlocks.apk',
            'browser_download_url': 'https://example.com/EpicBlocks.apk',
          },
        ],
      }),
    );
    final defaultRelease = service.parseReleaseJson(
      jsonEncode({
        'tag_name': '0.3.0',
        'body': 'New build',
        'assets': [
          {
            'name': 'app-release.apk',
            'browser_download_url': 'https://example.com/app-release.apk',
          },
        ],
      }),
    );

    expect(labeledRelease.version.label, '0.1.1');
    expect(
      labeledRelease.downloadUri.toString(),
      'https://example.com/app-release.apk',
    );
    expect(epicBlocksRelease.version.label, '0.2.0');
    expect(defaultRelease.version.label, '0.3.0');
  });

  test('release parser fails when APK asset is missing', () {
    final service = AppUpdateService();

    expect(
      () => service.parseReleaseJson(
        jsonEncode({'tag_name': 'v0.2.0', 'assets': <Object>[]}),
      ),
      throwsA(
        isA<AppUpdateException>().having(
          (error) => error.message,
          'message',
          'Latest release does not include EpicBlocks.apk.',
        ),
      ),
    );
  });

  test(
    'opens install permission settings when permission is disabled',
    () async {
      final service = _FakeAppUpdateService(canInstallPackages: false);
      final controller = AppUpdateController(service);

      await controller.checkForUpdates();
      await controller.getUpdate();

      expect(controller.state, AppUpdateButtonState.updateAvailable);
      expect(controller.errorMessage, isNull);
      expect(service.didDownloadApk, isTrue);
      expect(service.didOpenInstallPermissionSettings, isTrue);
      expect(service.didInstallApk, isFalse);
    },
  );

  test('opens installer when install permission is enabled', () async {
    final service = _FakeAppUpdateService(canInstallPackages: true);
    final controller = AppUpdateController(service);

    await controller.checkForUpdates();
    await controller.getUpdate();

    expect(controller.state, AppUpdateButtonState.updateAvailable);
    expect(controller.errorMessage, isNull);
    expect(service.didDownloadApk, isTrue);
    expect(service.didOpenInstallPermissionSettings, isFalse);
    expect(service.didInstallApk, isTrue);
  });

  test('shows platform install failure message', () async {
    final service = _FakeAppUpdateService(
      canInstallPackages: true,
      installError: PlatformException(
        code: 'installer_unavailable',
        message: 'Could not open installer.',
      ),
    );
    final controller = AppUpdateController(service);

    await controller.checkForUpdates();
    await controller.getUpdate();

    expect(controller.state, AppUpdateButtonState.failed);
    expect(controller.errorMessage, 'Could not open installer.');
    expect(service.didDownloadApk, isTrue);
    expect(service.didInstallApk, isTrue);
  });

  test('fails cleanly when updating before checking', () async {
    final service = _FakeAppUpdateService(canInstallPackages: true);
    final controller = AppUpdateController(service);

    await controller.getUpdate();

    expect(controller.state, AppUpdateButtonState.failed);
    expect(controller.errorMessage, 'Check for updates before updating.');
    expect(service.didDownloadApk, isFalse);
    expect(service.didInstallApk, isFalse);
  });
}

class _FakeAppUpdateService extends AppUpdateService {
  _FakeAppUpdateService({required this.canInstallPackages, this.installError});

  final bool canInstallPackages;
  final PlatformException? installError;
  var didDownloadApk = false;
  var didOpenInstallPermissionSettings = false;
  var didInstallApk = false;

  @override
  Future<AppUpdateCheckResult> checkForUpdates() async {
    return AppUpdateCheckResult(
      isUpdateAvailable: true,
      release: AppRelease(
        version: AppVersion.parse('v0.2.0'),
        downloadUri: Uri.parse('https://example.com/EpicBlocks.apk'),
        releaseNotes: 'Update improvements.',
      ),
    );
  }

  @override
  Future<String> downloadReleaseApk(AppRelease release) async {
    didDownloadApk = true;
    return '/cache/updates/EpicBlocks.apk';
  }

  @override
  Future<bool> canRequestPackageInstalls() async {
    return canInstallPackages;
  }

  @override
  Future<void> openInstallPermissionSettings() async {
    didOpenInstallPermissionSettings = true;
  }

  @override
  Future<void> installApk(String apkPath) async {
    didInstallApk = true;
    final installError = this.installError;
    if (installError != null) {
      throw installError;
    }
  }
}
