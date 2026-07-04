# EpicBlocks

EpicBlocks is a standalone Android-first Flutter puzzle game in the EpicPlay
workspace. It is a 1010-style block placement game with a 10 by 10 grid,
draggable pieces, line clears, score, local high score, Settings, patch notes,
and direct APK updates through GitHub Releases.

## Setup

```powershell
flutter pub get
```

## Run

```powershell
flutter run
```

For local debug without an Android device, use the Windows runner:

```powershell
flutter run -d windows
```

Android remains the release target.

## Verify

```powershell
flutter analyze
flutter test
flutter build apk --release
```

Local release builds fall back to debug signing unless release signing
environment variables are present. Public APK releases should be built through
GitHub Actions with the stable signing secrets documented in
`docs/release_process.md` at the EpicPlay root.

## Release

The release workflow publishes `EpicBlocks.apk` to
`Danne95/EpicBlocks` GitHub Releases. The in-app updater accepts `EpicBlocks.apk`,
an asset labeled `EpicBlocks.apk`, or the default `app-release.apk`. Before a
public release:

- Increase `version` in `pubspec.yaml`.
- Update `AppMetadata.versionLabel`.
- Update player-facing patch notes.
- Run analyze and tests.
- Make sure the GitHub Actions release-signing secrets are configured.
- Always increase Android's build number in `pubspec.yaml`.
- Confirm Android update behavior on a real device when release wiring changes.
