import 'package:epic_blocks/app/app.dart';
import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/app/data/settings_repository.dart';
import 'package:epic_blocks/features/blocks/application/blocks_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('game screen renders board, score, high score, and shape tray', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('EpicBlocks'), findsOneWidget);
    expect(find.text('Score'), findsOneWidget);
    expect(find.text('High score'), findsOneWidget);
    expect(find.byKey(const ValueKey('blocks-board')), findsOneWidget);
    expect(find.byKey(const ValueKey('shape-tray')), findsOneWidget);
  });

  testWidgets(
    'settings opens from app-bar cog and shows patch notes and update',
    (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Vibration'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Release 0.1.0'), findsOneWidget);
      expect(find.byKey(const ValueKey('update-button')), findsOneWidget);
    },
  );
}

Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final settingsController = SettingsController(
    SettingsRepository(preferences: preferences),
  );
  await settingsController.loadSettings();
  final blocksController = BlocksController(preferences: preferences);
  await blocksController.load();

  await tester.pumpWidget(
    EpicBlocksApp(
      settingsController: settingsController,
      blocksController: blocksController,
    ),
  );
  await tester.pump();
}
