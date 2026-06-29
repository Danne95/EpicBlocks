import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Fixed public GitHub Releases source for direct APK updates.
class AppUpdateConfig {
  const AppUpdateConfig._();

  /// Public endpoint for the latest EpicBlocks release.
  static final latestReleaseUri = Uri.https(
    'api.github.com',
    '/repos/Danne95/EpicBlocks/releases/latest',
  );

  /// Exact APK asset expected on each GitHub release.
  static const apkAssetName = 'EpicBlocks.apk';

  /// Default GitHub Actions APK file name.
  static const releaseApkFileName = 'app-release.apk';
}

/// Semantic app version used for update comparisons.
class AppVersion implements Comparable<AppVersion> {
  /// Creates a semantic app version.
  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  /// Parses release tags such as `v1.2.3` or `1.2.3`.
  factory AppVersion.parse(String value) {
    final normalizedValue = value.trim().replaceFirst(RegExp('^[vV]'), '');
    final parts = normalizedValue.split('.');
    if (parts.length != 3) {
      throw const AppUpdateException('Release version is not valid.');
    }

    final major = int.tryParse(parts[0]);
    final minor = int.tryParse(parts[1]);
    final patch = int.tryParse(parts[2]);
    if (major == null || minor == null || patch == null) {
      throw const AppUpdateException('Release version is not valid.');
    }

    return AppVersion(major: major, minor: minor, patch: patch);
  }

  /// Major version number.
  final int major;

  /// Minor version number.
  final int minor;

  /// Patch version number.
  final int patch;

  /// Human-readable version label.
  String get label => '$major.$minor.$patch';

  @override
  int compareTo(AppVersion other) {
    final majorComparison = major.compareTo(other.major);
    if (majorComparison != 0) {
      return majorComparison;
    }
    final minorComparison = minor.compareTo(other.minor);
    if (minorComparison != 0) {
      return minorComparison;
    }
    return patch.compareTo(other.patch);
  }
}

/// Installed Android package metadata.
class InstalledAppVersion {
  /// Creates installed package metadata.
  const InstalledAppVersion({required this.version, required this.versionCode});

  /// Installed semantic version.
  final AppVersion version;

  /// Installed Android version code.
  final int versionCode;
}

/// Parsed GitHub release data for a direct APK update.
class AppRelease {
  /// Creates release update metadata.
  const AppRelease({
    required this.version,
    required this.downloadUri,
    required this.releaseNotes,
  });

  /// Version published by the latest GitHub release tag.
  final AppVersion version;

  /// Direct browser download URL for the APK asset.
  final Uri downloadUri;

  /// Short release notes retained for diagnostics.
  final String releaseNotes;
}

/// Result of comparing the installed app with the latest GitHub release.
class AppUpdateCheckResult {
  /// Creates an update check result.
  const AppUpdateCheckResult({
    required this.release,
    required this.isUpdateAvailable,
  });

  /// Latest release metadata.
  final AppRelease release;

  /// Whether the GitHub release is newer than the installed app.
  final bool isUpdateAvailable;
}

/// Error that can be shown directly in the update section.
class AppUpdateException implements Exception {
  /// Creates a user-facing update exception.
  const AppUpdateException(this.message);

  /// User-facing failure text.
  final String message;

  @override
  String toString() => message;
}

/// Network and Android platform operations for direct APK updates.
class AppUpdateService {
  /// Creates the app update service.
  // ignore: prefer_initializing_formals
  AppUpdateService({HttpClient? httpClient}) : _httpClient = httpClient;

  static const MethodChannel _channel = MethodChannel('epic_blocks/updates');

  HttpClient? _httpClient;

  HttpClient get _client {
    _httpClient ??= HttpClient();
    return _httpClient!;
  }

  /// Checks GitHub Releases for a newer APK.
  Future<AppUpdateCheckResult> checkForUpdates() async {
    final installedVersion = await getInstalledVersion();
    final release = parseReleaseJson(
      await _getText(AppUpdateConfig.latestReleaseUri),
    );

    return AppUpdateCheckResult(
      release: release,
      isUpdateAvailable:
          release.version.compareTo(installedVersion.version) > 0,
    );
  }

  /// Reads installed Android package metadata from the native host app.
  Future<InstalledAppVersion> getInstalledVersion() async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'getInstalledVersion',
    );
    final versionName = result?['versionName'] as String?;
    final versionCode = result?['versionCode'];

    if (versionName == null || versionCode == null) {
      throw const AppUpdateException('Could not read the installed version.');
    }

    return InstalledAppVersion(
      version: AppVersion.parse(versionName),
      versionCode: (versionCode as num).toInt(),
    );
  }

  /// Parses GitHub's latest release JSON into update metadata.
  AppRelease parseReleaseJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const AppUpdateException('Release information is not valid.');
    }

    if (decoded is! Map<String, Object?>) {
      throw const AppUpdateException('Release information is not valid.');
    }

    final tagName = decoded['tag_name'] as String?;
    final assets = decoded['assets'];
    if (tagName == null || assets is! List) {
      throw const AppUpdateException('Release information is not valid.');
    }

    Map<String, Object?>? apkAsset;
    for (final asset in assets) {
      if (asset is Map<String, Object?> && _isAcceptedApkAsset(asset)) {
        apkAsset = asset;
        break;
      }
    }

    final downloadUrl = apkAsset?['browser_download_url'] as String?;
    if (downloadUrl == null) {
      throw const AppUpdateException(
        'Latest release does not include EpicBlocks.apk.',
      );
    }

    return AppRelease(
      version: AppVersion.parse(tagName),
      downloadUri: Uri.parse(downloadUrl),
      releaseNotes: _shortenReleaseNotes(decoded['body'] as String?),
    );
  }

  /// Downloads a release APK into app cache and returns its local path.
  Future<String> downloadReleaseApk(AppRelease release) async {
    final updatesDirectory = Directory(await getUpdateCacheDirectory());
    if (!updatesDirectory.existsSync()) {
      updatesDirectory.createSync(recursive: true);
    }

    final apkFile = File(
      '${updatesDirectory.path}/${AppUpdateConfig.apkAssetName}',
    );
    final request = await _client.getUrl(release.downloadUri);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw const AppUpdateException('Could not download the update.');
    }

    final sink = apkFile.openWrite();
    try {
      await response.pipe(sink);
    } finally {
      await sink.close();
    }

    return apkFile.path;
  }

  /// Android cache directory exposed through the update FileProvider.
  Future<String> getUpdateCacheDirectory() async {
    final directory = await _channel.invokeMethod<String>(
      'getUpdateCacheDirectory',
    );
    if (directory == null || directory.isEmpty) {
      throw const AppUpdateException('Could not prepare the update download.');
    }

    return directory;
  }

  /// Whether Android currently allows this app to request package installs.
  Future<bool> canRequestPackageInstalls() async {
    return await _channel.invokeMethod<bool>('canRequestPackageInstalls') ??
        false;
  }

  /// Opens Android's per-app permission screen for unknown app installs.
  Future<void> openInstallPermissionSettings() async {
    await _channel.invokeMethod<void>('openInstallPermissionSettings');
  }

  /// Starts Android's installer for the downloaded APK.
  Future<void> installApk(String apkPath) async {
    await _channel.invokeMethod<void>('installApk', apkPath);
  }

  Future<String> _getText(Uri uri) async {
    final request = await _client.getUrl(uri);
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    request.headers.set('X-GitHub-Api-Version', '2022-11-28');
    request.headers.set(HttpHeaders.userAgentHeader, 'EpicBlocks');

    final response = await request.close();
    if (response.statusCode == HttpStatus.notFound) {
      throw const AppUpdateException('No GitHub release was found.');
    }
    if (response.statusCode != HttpStatus.ok) {
      throw const AppUpdateException('Could not reach GitHub releases.');
    }

    return response.transform(utf8.decoder).join();
  }

  String _shortenReleaseNotes(String? notes) {
    final trimmedNotes = notes?.trim();
    if (trimmedNotes == null || trimmedNotes.isEmpty) {
      return 'No release notes were published.';
    }

    const maximumLength = 240;
    if (trimmedNotes.length <= maximumLength) {
      return trimmedNotes;
    }

    return '${trimmedNotes.substring(0, maximumLength).trimRight()}...';
  }

  bool _isAcceptedApkAsset(Map<String, Object?> asset) {
    return asset['label'] == AppUpdateConfig.apkAssetName ||
        asset['name'] == AppUpdateConfig.apkAssetName ||
        asset['name'] == AppUpdateConfig.releaseApkFileName;
  }
}
