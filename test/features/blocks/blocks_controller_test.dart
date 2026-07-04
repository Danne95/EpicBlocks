import 'package:epic_blocks/features/blocks/application/blocks_controller.dart';
import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('new game clears score and preserves saved high score', () async {
    SharedPreferences.setMockInitialValues({'blocks.high_score': 40});
    final preferences = await SharedPreferences.getInstance();
    final controller = BlocksController(preferences: preferences);

    await controller.load();
    expect(controller.highScore, 40);

    final placed = await controller.placeShape(0, const BlockPosition(0, 0));
    expect(placed, isTrue);
    expect(controller.score, greaterThan(0));

    controller.newGame();

    expect(controller.score, 0);
    expect(controller.highScore, 40);
    expect(controller.isGameOver, isFalse);
  });

  test('high score is saved locally after a scoring move', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = BlocksController(preferences: preferences);

    await controller.load();
    final placed = await controller.placeShape(0, const BlockPosition(0, 0));

    expect(placed, isTrue);
    expect(preferences.getInt('blocks.high_score'), controller.highScore);
  });

  test('active game state is restored from local storage', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = BlocksController(preferences: preferences);

    await controller.load();
    final originalShape = controller.availableShapes[0];
    final placed = await controller.placeShape(0, const BlockPosition(0, 0));

    expect(placed, isTrue);
    expect(originalShape, isNotNull);

    final restored = BlocksController(preferences: preferences);
    await restored.load();

    expect(restored.score, controller.score);
    expect(restored.highScore, controller.highScore);
    expect(restored.isGameOver, controller.isGameOver);
    expect(restored.availableShapes[0], isNull);
    expect(restored.availableShapes[1]?.id, controller.availableShapes[1]?.id);
    expect(restored.availableShapes[2]?.id, controller.availableShapes[2]?.id);
    expect(
      restored.board.cells.expand((row) => row).whereType<Object>().length,
      originalShape!.size,
    );
    expect(
      restored.board.cells[0][0]?.shape.id,
      controller.board.cells[0][0]?.shape.id,
    );
  });

  test('invalid saved game state starts a fresh game', () async {
    SharedPreferences.setMockInitialValues({
      'blocks.state.version': 1,
      'blocks.state.score': 99,
      'blocks.state.is_game_over': false,
      'blocks.state.tray': ['missing_shape', '', ''],
      'blocks.state.board': List<String>.filled(100, ''),
    });
    final preferences = await SharedPreferences.getInstance();
    final controller = BlocksController(preferences: preferences);

    await controller.load();

    expect(controller.score, 0);
    expect(controller.availableShapes.whereType<Object>().length, 3);
    expect(
      controller.board.cells.expand((row) => row).whereType<Object>(),
      isEmpty,
    );
  });
}
