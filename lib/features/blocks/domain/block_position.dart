/// Integer board coordinate.
class BlockPosition {
  /// Creates a position.
  const BlockPosition(this.row, this.column);

  /// Row index.
  final int row;

  /// Column index.
  final int column;

  /// Returns this position translated by [other].
  BlockPosition operator +(BlockPosition other) {
    return BlockPosition(row + other.row, column + other.column);
  }

  @override
  bool operator ==(Object other) {
    return other is BlockPosition && other.row == row && other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}
