# Release Checklist

- [ ] Update `pubspec.yaml` version name and Android version code.
- [ ] Update `AppMetadata.versionLabel`.
- [ ] Update `AppMetadata.patchNotes` with player-facing changes.
- [ ] Confirm update service points at `Danne95/EpicBlocks`.
- [ ] Confirm accepted APK asset names are `EpicBlocks.apk` and
  `app-release.apk`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Build release APK through GitHub Actions or the stable release-signing
  path.
- [ ] Confirm the GitHub Release contains `EpicBlocks.apk`.
- [ ] Test install/update on a real Android device when release/update wiring
  changed.

If Android shows `App not installed`, verify signing continuity and versionCode
before changing app code.
