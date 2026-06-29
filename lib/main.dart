import 'package:epic_blocks/app/app.dart';
import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/app/data/settings_repository.dart';
import 'package:epic_blocks/features/blocks/application/blocks_controller.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final settingsController = SettingsController(
    SettingsRepository(preferences: preferences),
  );
  await settingsController.loadSettings();

  final blocksController = BlocksController(preferences: preferences);
  await blocksController.load();

  runApp(
    EpicBlocksApp(
      settingsController: settingsController,
      blocksController: blocksController,
    ),
  );
}
