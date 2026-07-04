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

  test('shape orientations share a family color', () {
    expectSameFamilyColor(['bar_2_h', 'bar_2_v']);
    expectSameFamilyColor(['bar_3_h', 'bar_3_v']);
    expectSameFamilyColor(['bar_4_h', 'bar_4_v']);
    expectSameFamilyColor(['bar_5_h', 'bar_5_v']);
    expectSameFamilyColor(['corner_tl', 'corner_tr', 'corner_bl', 'corner_br']);
    expectSameFamilyColor([
      'l_4_down_right',
      'l_4_down_left',
      'l_4_right_down',
      'l_4_right_up',
    ]);
    expectSameFamilyColor(['t_up', 't_down', 't_left', 't_right']);
    expectSameFamilyColor(['s_h', 's_v']);
    expectSameFamilyColor(['z_h', 'z_v']);
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

void expectSameFamilyColor(List<String> ids) {
  final shapes = ids.map(
    (id) => BlockShapes.all.firstWhere((shape) => shape.id == id),
  );
  final lightColors = shapes
      .map((shape) => shape.lightColor.toARGB32())
      .toSet();
  final darkColors = shapes.map((shape) => shape.darkColor.toARGB32()).toSet();

  expect(lightColors, hasLength(1));
  expect(darkColors, hasLength(1));
}
