import 'package:epic_blocks/features/blocks/presentation/blocks_game_screen.dart';
import 'package:epic_blocks/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';

/// Main app shell. Gameplay is the default and primary route.
class AppShell extends StatelessWidget {
  /// Creates the shell.
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const BlocksGameScreen();
  }
}

/// Opens Settings as a secondary flow from the app bar cog.
Future<void> openSettings(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
}
