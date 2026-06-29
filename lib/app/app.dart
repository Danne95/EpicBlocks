import 'package:epic_blocks/app/application/app_update_controller.dart';
import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/app/data/app_update_service.dart';
import 'package:epic_blocks/app/presentation/app_shell.dart';
import 'package:epic_blocks/app/theme/app_theme.dart';
import 'package:epic_blocks/features/blocks/application/blocks_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Top-level EpicBlocks application widget.
class EpicBlocksApp extends StatelessWidget {
  /// Creates the app with already-loaded controllers.
  const EpicBlocksApp({
    required this.settingsController,
    required this.blocksController,
    super.key,
  });

  /// App-wide settings controller.
  final SettingsController settingsController;

  /// Game controller.
  final BlocksController blocksController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsController),
        ChangeNotifierProvider.value(value: blocksController),
        ChangeNotifierProvider(
          create: (_) => AppUpdateController(AppUpdateService()),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'EpicBlocks',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
