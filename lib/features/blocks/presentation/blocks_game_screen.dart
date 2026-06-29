import 'dart:math' as math;

import 'package:epic_blocks/app/application/settings_controller.dart';
import 'package:epic_blocks/app/presentation/app_shell.dart';
import 'package:epic_blocks/core/services/vibration_service.dart';
import 'package:epic_blocks/features/blocks/application/blocks_controller.dart';
import 'package:epic_blocks/features/blocks/domain/block_cell.dart';
import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:epic_blocks/features/blocks/domain/block_shape.dart';
import 'package:epic_blocks/features/blocks/domain/blocks_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Main playable EpicBlocks screen.
class BlocksGameScreen extends StatelessWidget {
  /// Creates the game screen.
  const BlocksGameScreen({super.key});

  static const _vibrationService = VibrationService();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BlocksController>();
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EpicBlocks'),
        actions: [
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.refresh),
            onPressed: controller.newGame,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => openSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSize = math
                .min(constraints.maxWidth - 24, constraints.maxHeight * 0.58)
                .clamp(280.0, 560.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ScoreHeader(
                        score: controller.score,
                        highScore: controller.highScore,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: _BoardView(
                          boardSize: boardSize,
                          onDrop: (data, origin) async {
                            final placed = await controller.placeShape(
                              data.trayIndex,
                              origin,
                            );
                            if (placed && settings.vibrationEnabled) {
                              await _vibrationService.vibrate();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ShapeTray(shapes: controller.availableShapes),
                      const SizedBox(height: 16),
                      if (controller.isGameOver)
                        _GameOverPanel(
                          score: controller.score,
                          highScore: controller.highScore,
                          onRestart: controller.newGame,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.score, required this.highScore});

  final int score;
  final int highScore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: _ScoreTile(
            label: 'Score',
            value: score,
            style: textTheme.titleLarge,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ScoreTile(
            label: 'High score',
            value: highScore,
            style: textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 2),
            Text('$value', style: style),
          ],
        ),
      ),
    );
  }
}

class _BoardView extends StatefulWidget {
  const _BoardView({required this.boardSize, required this.onDrop});

  final double boardSize;
  final Future<void> Function(_ShapeDragData data, BlockPosition origin) onDrop;

  @override
  State<_BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<_BoardView> {
  final GlobalKey _boardKey = GlobalKey();
  BlockPosition? _hoverOrigin;
  BlockShape? _hoverShape;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BlocksController>();

    return DragTarget<_ShapeDragData>(
      key: const ValueKey('blocks-board-target'),
      onWillAcceptWithDetails: (details) {
        final origin = _originForDrop(details.offset);
        return origin != null &&
            controller.board.canPlace(details.data.shape, origin);
      },
      onMove: (details) {
        setState(() {
          _hoverOrigin = _originForDrop(details.offset);
          _hoverShape = details.data.shape;
        });
      },
      onLeave: (_) {
        setState(() {
          _hoverOrigin = null;
          _hoverShape = null;
        });
      },
      onAcceptWithDetails: (details) async {
        final origin = _originForDrop(details.offset);
        if (origin == null) {
          return;
        }
        setState(() {
          _hoverOrigin = null;
          _hoverShape = null;
        });
        await widget.onDrop(details.data, origin);
      },
      builder: (context, _, _) {
        return SizedBox.square(
          key: _boardKey,
          dimension: widget.boardSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _boardBackground(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gridBorder(context), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: GridView.builder(
                key: const ValueKey('blocks-board'),
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: BlocksBoard.size,
                ),
                itemCount: BlocksBoard.size * BlocksBoard.size,
                itemBuilder: (context, index) {
                  final row = index ~/ BlocksBoard.size;
                  final column = index % BlocksBoard.size;
                  final cell = controller.board.cells[row][column];
                  final preview = _hoverOrigin;
                  final previewShape = _hoverShape;
                  final isPreview =
                      preview != null &&
                      previewShape != null &&
                      _isShapeCell(previewShape, preview, row, column) &&
                      controller.board.canPlace(previewShape, preview);

                  return _BoardCell(cell: cell, isPreview: isPreview);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  BlockPosition? _originForDrop(Offset globalOffset) {
    final renderObject = _boardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) {
      return null;
    }
    final local = renderObject.globalToLocal(globalOffset);
    final cellSize = widget.boardSize / BlocksBoard.size;
    final row = (local.dy / cellSize).floor();
    final column = (local.dx / cellSize).floor();
    final position = BlockPosition(row, column);
    return BlocksBoard.empty().contains(position) ? position : null;
  }

  bool _isShapeCell(
    BlockShape shape,
    BlockPosition origin,
    int row,
    int column,
  ) {
    return shape.cells.any(
      (cell) =>
          origin.row + cell.row == row && origin.column + cell.column == column,
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({required this.cell, required this.isPreview});

  final BlockCell? cell;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final filledColor = cell == null ? null : _shapeColor(context, cell!.shape);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color:
            filledColor ??
            (isPreview
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.42)
                : _emptyCell(context)),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: _gridBorder(context).withValues(alpha: 0.75)),
      ),
    );
  }
}

class _ShapeTray extends StatelessWidget {
  const _ShapeTray({required this.shapes});

  final List<BlockShape?> shapes;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('shape-tray'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var index = 0; index < shapes.length; index += 1)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == shapes.length - 1 ? 0 : 6,
              ),
              child: _ShapeSlot(index: index, shape: shapes[index]),
            ),
          ),
      ],
    );
  }
}

class _ShapeSlot extends StatelessWidget {
  const _ShapeSlot({required this.index, required this.shape});

  final int index;
  final BlockShape? shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentShape = shape;

    return SizedBox(
      height: 112,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: currentShape == null
              ? Icon(Icons.check, color: colorScheme.outline)
              : Draggable<_ShapeDragData>(
                  data: _ShapeDragData(trayIndex: index, shape: currentShape),
                  feedback: Material(
                    color: Colors.transparent,
                    child: _ShapePreview(shape: currentShape, cellSize: 22),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _ShapePreview(shape: currentShape, cellSize: 18),
                  ),
                  child: Semantics(
                    label: currentShape.label,
                    child: _ShapePreview(shape: currentShape, cellSize: 18),
                  ),
                ),
        ),
      ),
    );
  }
}

class _ShapePreview extends StatelessWidget {
  const _ShapePreview({required this.shape, required this.cellSize});

  final BlockShape shape;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: shape.width * cellSize,
      height: shape.height * cellSize,
      child: Stack(
        children: [
          for (final cell in shape.cells)
            Positioned(
              left: cell.column * cellSize,
              top: cell.row * cellSize,
              width: cellSize,
              height: cellSize,
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: _shapeColor(context, shape),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameOverPanel extends StatelessWidget {
  const _GameOverPanel({
    required this.score,
    required this.highScore,
    required this.onRestart,
  });

  final int score;
  final int highScore;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: const ValueKey('game-over-panel'),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'No moves left',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('Score $score  |  High score $highScore'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('new game'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShapeDragData {
  const _ShapeDragData({required this.trayIndex, required this.shape});

  final int trayIndex;
  final BlockShape shape;
}

Color _shapeColor(BuildContext context, BlockShape shape) {
  return Theme.of(context).brightness == Brightness.dark
      ? shape.darkColor
      : shape.lightColor;
}

Color _boardBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1F2937)
      : const Color(0xFFE5E7EB);
}

Color _emptyCell(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF374151)
      : const Color(0xFFF8FAFC);
}

Color _gridBorder(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF4B5563)
      : const Color(0xFFCBD5E1);
}
