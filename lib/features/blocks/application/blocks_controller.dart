import 'dart:math';

import 'package:epic_blocks/features/blocks/domain/block_position.dart';
import 'package:epic_blocks/features/blocks/domain/block_shape.dart';
import 'package:epic_blocks/features/blocks/domain/block_shapes.dart';
import 'package:epic_blocks/features/blocks/domain/blocks_board.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mutable game state and orchestration.
class BlocksController extends ChangeNotifier {
  /// Creates the controller.
  BlocksController({required this.preferences, Random? random})
    : _random = random ?? Random();

  static const _highScoreKey = 'blocks.high_score';

  /// Preferences storage.
  final SharedPreferences preferences;
  final Random _random;

  BlocksBoard _board = BlocksBoard.empty();
  List<BlockShape?> _availableShapes = const [null, null, null];
  int _score = 0;
  int _highScore = 0;
  bool _isGameOver = false;

  /// Current board.
  BlocksBoard get board => _board;

  /// Current shape tray. Placed entries become null until refill.
  List<BlockShape?> get availableShapes => List.unmodifiable(_availableShapes);

  /// Current score.
  int get score => _score;

  /// Locally saved high score.
  int get highScore => _highScore;

  /// Whether no remaining available shape can fit.
  bool get isGameOver => _isGameOver;

  /// Loads local high score and starts a game.
  Future<void> load() async {
    _highScore = preferences.getInt(_highScoreKey) ?? 0;
    newGame(notify: false);
  }

  /// Starts a new game while preserving high score.
  void newGame({bool notify = true}) {
    _board = BlocksBoard.empty();
    _availableShapes = _dealShapes();
    _score = 0;
    _isGameOver = false;
    if (notify) {
      notifyListeners();
    }
  }

  /// Tries to place a shape from the tray.
  Future<bool> placeShape(int trayIndex, BlockPosition origin) async {
    if (trayIndex < 0 || trayIndex >= _availableShapes.length || _isGameOver) {
      return false;
    }

    final shape = _availableShapes[trayIndex];
    if (shape == null || !_board.canPlace(shape, origin)) {
      return false;
    }

    final result = _board.place(shape, origin);
    _board = result.board;
    _score += result.scoreDelta;
    _availableShapes = List<BlockShape?>.of(_availableShapes, growable: false)
      ..[trayIndex] = null;

    if (_availableShapes.every((shape) => shape == null)) {
      _availableShapes = _dealShapes();
    }

    if (_score > _highScore) {
      _highScore = _score;
      await preferences.setInt(_highScoreKey, _highScore);
    }

    _isGameOver = !_hasAnyMove();
    notifyListeners();
    return true;
  }

  bool _hasAnyMove() {
    for (final shape in _availableShapes.whereType<BlockShape>()) {
      if (_board.canPlaceAnywhere(shape)) {
        return true;
      }
    }
    return false;
  }

  List<BlockShape?> _dealShapes() {
    return List<BlockShape?>.generate(
      3,
      (_) => BlockShapes.all[_random.nextInt(BlockShapes.all.length)],
      growable: false,
    );
  }
}
