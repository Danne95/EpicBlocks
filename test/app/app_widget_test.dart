import 'package:epic_blocks/app/app.dart';
import 'package:epic_blocks/app/application/app_update_controller.dart';
import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/app/data/app_update_service.dart';
import 'package:epic_blocks/app/data/settings_repository.dart';
import 'package:epic_blocks/features/blocks/application/blocks_controller.dart';
import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:epic_blocks/features/blocks/domain/block_shapes.dart';
import 'package:epic_blocks/features/blocks/presentation/blocks_game_screen.dart';
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
    expect(find.byIcon(Icons.refresh), findsNothing);
  });

  testWidgets('shape can be dragged from the center of its full tray slot', (
    tester,
  ) async {
    final controller = await _pumpApp(tester);
    final slotCenter = tester.getCenter(
      find.byKey(const ValueKey('shape-slot-0')),
    );
    final boardCenter = tester.getCenter(
      find.byKey(const ValueKey('blocks-board')),
    );

    final gesture = await tester.startGesture(slotCenter);
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(boardCenter);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.score, greaterThan(0));
    expect(controller.availableShapes[0], isNull);
    expect(
      controller.board.cells.expand((row) => row).whereType<Object>(),
      isNotEmpty,
    );
  });

  test(
    'centered drag origin maps the pointer to a centered shape placement',
    () {
      final square = BlockShapes.all.firstWhere(
        (shape) => shape.id == 'square_3',
      );

      expect(
        centeredShapeDragOrigin(
          boardLocalPosition: const Offset(150, 150),
          shape: square,
          cellSize: 30,
        ),
        const BlockPosition(4, 4),
      );
    },
  );

  test('centered drag origin keeps board edges reachable', () {
    final bar = BlockShapes.all.firstWhere((shape) => shape.id == 'bar_5_h');

    expect(
      centeredShapeDragOrigin(
        boardLocalPosition: Offset.zero,
        shape: bar,
        cellSize: 30,
      ),
      const BlockPosition(0, 0),
    );
    expect(
      centeredShapeDragOrigin(
        boardLocalPosition: const Offset(300, 300),
        shape: bar,
        cellSize: 30,
      ),
      const BlockPosition(9, 5),
    );
  });

  test('lifted drag anchor places feedback above the pointer', () {
    final square = BlockShapes.all.firstWhere(
      (shape) => shape.id == 'square_2',
    );
    final anchor = liftedShapeDragAnchor(
      shape: square,
      feedbackCellSize: 30,
      liftGap: 30,
    );

    expect(anchor.dx, 30);
    expect(anchor.dy, 90);
  });

  test('shape feedback center drives board preview and placement', () {
    final square = BlockShapes.all.firstWhere(
      (shape) => shape.id == 'square_2',
    );
    final center = shapeFeedbackCenter(shape: square, feedbackCellSize: 30);

    expect(center.dx, 30);
    expect(center.dy, 30);
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
      expect(find.text('Release 1.0.0'), findsOneWidget);
      expect(find.byKey(const ValueKey('update-button')), findsOneWidget);
      expect(find.text('Check for updates'), findsOneWidget);
    },
  );

  testWidgets('settings shows update available as get update', (tester) async {
    final updateController = AppUpdateController(
      _FakeUpdateService(
        result: AppUpdateCheckResult(
          isUpdateAvailable: true,
          release: AppRelease(
            version: AppVersion.parse('v0.2.0'),
            downloadUri: Uri.parse('https://example.com/EpicBlocks.apk'),
            releaseNotes: 'New gameplay polish.',
          ),
        ),
      ),
    );
    await _pumpApp(tester, updateController: updateController);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();

    expect(find.text('get update'), findsOneWidget);
    expect(find.text('Version 0.2.0 is available.'), findsNothing);
    expect(find.text('New gameplay polish.'), findsNothing);
    expect(find.text('Download update'), findsNothing);
  });

  testWidgets('settings shows disabled up to date state', (tester) async {
    final updateController = AppUpdateController(
      _FakeUpdateService(
        result: AppUpdateCheckResult(
          isUpdateAvailable: false,
          release: AppRelease(
            version: AppVersion.parse('v0.1.0'),
            downloadUri: Uri.parse('https://example.com/EpicBlocks.apk'),
            releaseNotes: 'No changes.',
          ),
        ),
      ),
    );
    await _pumpApp(tester, updateController: updateController);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(FilledButton, 'up to date');
    final button = tester.widget<FilledButton>(buttonFinder);

    expect(buttonFinder, findsOneWidget);
    expect(button.onPressed, isNull);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('settings shows update check failure text', (tester) async {
    final updateController = AppUpdateController(
      _FakeUpdateService(errorMessage: 'No GitHub release was found.'),
    );
    await _pumpApp(tester, updateController: updateController);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check for updates'));
    await tester.pumpAndSettle();

    expect(find.text('No GitHub release was found.'), findsOneWidget);
  });
}

Future<BlocksController> _pumpApp(
  WidgetTester tester, {
  AppUpdateController? updateController,
}) async {
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
      updateController: updateController,
    ),
  );
  await tester.pump();

  return blocksController;
}

class _FakeUpdateService extends AppUpdateService {
  _FakeUpdateService({this.result, this.errorMessage});

  final AppUpdateCheckResult? result;
  final String? errorMessage;

  @override
  Future<AppUpdateCheckResult> checkForUpdates() async {
    final errorMessage = this.errorMessage;
    if (errorMessage != null) {
      throw AppUpdateException(errorMessage);
    }

    return result ??
        AppUpdateCheckResult(
          isUpdateAvailable: false,
          release: AppRelease(
            version: AppVersion.parse('v0.1.0'),
            downloadUri: Uri.parse('https://example.com/EpicBlocks.apk'),
            releaseNotes: 'No changes.',
          ),
        );
  }
}
