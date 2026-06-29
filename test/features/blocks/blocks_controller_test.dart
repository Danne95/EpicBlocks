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
}
