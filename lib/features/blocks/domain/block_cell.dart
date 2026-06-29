import 'package:epic_blocks/features/blocks/domain/block_shape.dart';

/// A filled board cell.
class BlockCell {
  /// Creates a filled cell.
  const BlockCell({required this.shape});

  /// Shape that placed this cell.
  final BlockShape shape;
}
