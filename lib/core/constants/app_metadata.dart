/// Static application metadata shown in the UI.
class AppMetadata {
  const AppMetadata._();

  /// Human-readable app version.
  static const versionLabel = '1.0.1';

  /// Player-facing patch notes for the current app version.
  static const patchNotes = [
    PatchNote(
      title: 'Release 1.0.1',
      changes: [
        'Improved drag pickup so shapes are easier to grab from the tray.',
        'Centered held shapes and placement previews around the drag position.',
        'Improved board placement handling so valid drops are not ignored.',
      ],
    ),
    PatchNote(
      title: 'Release 1.0.0',
      changes: [
        'Added the first playable EpicBlocks puzzle.',
        'Added drag-and-drop block placement on a 10 by 10 board.',
        'Made shape colors consistent by type.',
        'Added score, local high score, line clears, and game-over detection.',
        'Added dark mode, vibration, sound, patch notes, and update checks.',
        'Improved in-app update handling for direct APK releases.',
      ],
    ),
  ];

  /// Signature shown on the settings screen.
  static const signature = 'Made by EpicBrain';
}

/// User-facing changes for one released app version.
class PatchNote {
  /// Creates patch notes for a single app release.
  const PatchNote({required this.title, required this.changes});

  /// Version or release title shown above the changes.
  final String title;

  /// Short change descriptions shown to users.
  final List<String> changes;
}
