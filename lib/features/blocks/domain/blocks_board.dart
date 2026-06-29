import 'package:epic_blocks/features/blocks/domain/block_cell.dart';
import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:epic_blocks/features/blocks/domain/block_shape.dart';

/// Immutable 10 by 10 board.
class BlocksBoard {
  /// Creates a board from rows.
  const BlocksBoard(this.cells);

  /// Board size.
  static const size = 10;

  /// Empty board.
  factory BlocksBoard.empty() {
    return BlocksBoard(
      List.generate(
        size,
        (_) => List<BlockCell?>.filled(size, null, growable: false),
        growable: false,
      ),
    );
  }

  /// Filled cells.
  final List<List<BlockCell?>> cells;

  /// Returns whether [position] is inside the board.
  bool contains(BlockPosition position) {
    return position.row >= 0 &&
        position.row < size &&
        position.column >= 0 &&
        position.column < size;
  }

  /// Returns whether [shape] can be placed at [origin].
  bool canPlace(BlockShape shape, BlockPosition origin) {
    for (final offset in shape.cells) {
      final position = origin + offset;
      if (!contains(position) || cells[position.row][position.column] != null) {
        return false;
      }
    }
    return true;
  }

  /// Returns whether [shape] can be placed anywhere.
  bool canPlaceAnywhere(BlockShape shape) {
    for (var row = 0; row < size; row += 1) {
      for (var column = 0; column < size; column += 1) {
        if (canPlace(shape, BlockPosition(row, column))) {
          return true;
        }
      }
    }
    return false;
  }

  /// Places [shape], clears full rows/columns, and returns the result.
  PlacementResult place(BlockShape shape, BlockPosition origin) {
    if (!canPlace(shape, origin)) {
      throw ArgumentError('Shape cannot be placed at the requested position.');
    }

    final nextCells = _copyCells();
    for (final offset in shape.cells) {
      final position = origin + offset;
      nextCells[position.row][position.column] = BlockCell(shape: shape);
    }

    final fullRows = <int>[];
    final fullColumns = <int>[];

    for (var row = 0; row < size; row += 1) {
      if (nextCells[row].every((cell) => cell != null)) {
        fullRows.add(row);
      }
    }

    for (var column = 0; column < size; column += 1) {
      var full = true;
      for (var row = 0; row < size; row += 1) {
        if (nextCells[row][column] == null) {
          full = false;
          break;
        }
      }
      if (full) {
        fullColumns.add(column);
      }
    }

    for (final row in fullRows) {
      for (var column = 0; column < size; column += 1) {
        nextCells[row][column] = null;
      }
    }
    for (final column in fullColumns) {
      for (var row = 0; row < size; row += 1) {
        nextCells[row][column] = null;
      }
    }

    return PlacementResult(
      board: BlocksBoard(nextCells),
      placedCells: shape.size,
      clearedRows: fullRows,
      clearedColumns: fullColumns,
    );
  }

  List<List<BlockCell?>> _copyCells() {
    return List.generate(
      size,
      (row) => List<BlockCell?>.of(cells[row], growable: false),
      growable: false,
    );
  }
}

/// Result of a valid placement.
class PlacementResult {
  /// Creates the placement result.
  const PlacementResult({
    required this.board,
    required this.placedCells,
    required this.clearedRows,
    required this.clearedColumns,
  });

  /// Board after placement and clears.
  final BlocksBoard board;

  /// Number of placed cells.
  final int placedCells;

  /// Cleared row indexes.
  final List<int> clearedRows;

  /// Cleared column indexes.
  final List<int> clearedColumns;

  /// Total cleared lines.
  int get clearedLineCount => clearedRows.length + clearedColumns.length;

  /// Score earned by this placement.
  int get scoreDelta {
    final lines = clearedLineCount;
    return placedCells + (lines == 0 ? 0 : 5 * lines * (lines + 1));
  }
}
