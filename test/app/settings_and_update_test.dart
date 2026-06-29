import 'dart:convert';

import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/app/data/app_update_service.dart';
import 'package:epic_blocks/app/data/settings_repository.dart';
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
  });

  test('release parser accepts EpicBlocks and default APK asset names', () {
    final service = AppUpdateService();
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

    expect(epicBlocksRelease.version.label, '0.2.0');
    expect(defaultRelease.version.label, '0.3.0');
  });
}
