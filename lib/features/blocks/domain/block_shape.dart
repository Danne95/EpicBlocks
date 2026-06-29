import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:flutter/material.dart';

/// A draggable shape definition.
class BlockShape {
  /// Creates a shape.
  const BlockShape({
    required this.id,
    required this.label,
    required this.cells,
    required this.lightColor,
    required this.darkColor,
  });

  /// Stable shape identifier.
  final String id;

  /// User-facing label for accessibility and tests.
  final String label;

  /// Occupied offsets relative to the drop origin.
  final List<BlockPosition> cells;

  /// Shape color in light mode.
  final Color lightColor;

  /// Shape color in dark mode.
  final Color darkColor;

  /// Width in cells.
  int get width => cells.map((cell) => cell.column).reduce(mathMax) + 1;

  /// Height in cells.
  int get height => cells.map((cell) => cell.row).reduce(mathMax) + 1;

  /// Cell count.
  int get size => cells.length;
}

int mathMax(int left, int right) => left > right ? left : right;
