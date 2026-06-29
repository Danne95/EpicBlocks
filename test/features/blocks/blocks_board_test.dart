import 'package:epic_blocks/features/blocks/domain/block_cell.dart';
import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:epic_blocks/features/blocks/domain/block_shapes.dart';
import 'package:epic_blocks/features/blocks/domain/blocks_board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shape catalog has variants and light/dark colors', () {
    final ids = BlockShapes.all.map((shape) => shape.id).toSet();

    expect(
      ids,
      containsAll(['bar_5_h', 'bar_5_v', 'square_3', 't_up', 's_h', 'z_v']),
    );
    expect(BlockShapes.all, hasLength(greaterThanOrEqualTo(24)));
    for (final shape in BlockShapes.all) {
      expect(shape.cells, isNotEmpty);
      expect(shape.lightColor.toARGB32(), isNot(shape.darkColor.toARGB32()));
    }
  });

  test('valid and invalid placements are detected', () {
    final board = BlocksBoard.empty();
    final shape = BlockShapes.all.firstWhere((shape) => shape.id == 'bar_3_h');

    expect(board.canPlace(shape, const BlockPosition(0, 0)), isTrue);
    expect(board.canPlace(shape, const BlockPosition(0, 8)), isFalse);

    final placed = board.place(shape, const BlockPosition(0, 0)).board;
    expect(placed.canPlace(shape, const BlockPosition(0, 0)), isFalse);
  });

  test('row clear scores placement cells plus one-line bonus', () {
    final single = BlockShapes.all.firstWhere((shape) => shape.id == 'single');
    final cells = List.generate(
      BlocksBoard.size,
      (_) => List<BlockCell?>.filled(BlocksBoard.size, null),
    );

    for (var column = 0; column < BlocksBoard.size - 1; column += 1) {
      cells[0][column] = BlockCell(shape: single);
    }

    final result = BlocksBoard(cells).place(single, const BlockPosition(0, 9));

    expect(result.clearedRows, [0]);
    expect(result.clearedColumns, isEmpty);
    expect(result.scoreDelta, 11);
    expect(result.board.cells[0].every((cell) => cell == null), isTrue);
  });

  test('simultaneous row and column clear earns combo bonus', () {
    final single = BlockShapes.all.firstWhere((shape) => shape.id == 'single');
    final cells = List.generate(
      BlocksBoard.size,
      (_) => List<BlockCell?>.filled(BlocksBoard.size, null),
    );

    for (var column = 1; column < BlocksBoard.size; column += 1) {
      cells[0][column] = BlockCell(shape: single);
    }
    for (var row = 1; row < BlocksBoard.size; row += 1) {
      cells[row][0] = BlockCell(shape: single);
    }

    final result = BlocksBoard(cells).place(single, const BlockPosition(0, 0));

    expect(result.clearedRows, [0]);
    expect(result.clearedColumns, [0]);
    expect(result.scoreDelta, 31);
  });

  test('full board has no option to play', () {
    final single = BlockShapes.all.firstWhere((shape) => shape.id == 'single');
    final cells = List.generate(
      BlocksBoard.size,
      (_) =>
          List<BlockCell?>.filled(BlocksBoard.size, BlockCell(shape: single)),
    );

    expect(BlocksBoard(cells).canPlaceAnywhere(single), isFalse);
  });
}
