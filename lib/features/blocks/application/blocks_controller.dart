import 'dart:async';
import 'dart:math';

import 'package:epic_blocks/features/blocks/domain/block_cell.dart';
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
  static const _stateVersionKey = 'blocks.state.version';
  static const _scoreKey = 'blocks.state.score';
  static const _isGameOverKey = 'blocks.state.is_game_over';
  static const _trayKey = 'blocks.state.tray';
  static const _boardKey = 'blocks.state.board';
  static const _stateVersion = 1;

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

  /// Loads local high score and resumes the saved game when available.
  Future<void> load() async {
    _highScore = preferences.getInt(_highScoreKey) ?? 0;
    if (!_restoreSavedGame()) {
      _startNewGame();
      await _saveGameState();
    }
  }

  /// Starts a new game while preserving high score.
  void newGame({bool notify = true}) {
    _startNewGame();
    unawaited(_saveGameState());
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
    await _saveGameState();
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

  void _startNewGame() {
    _board = BlocksBoard.empty();
    _availableShapes = _dealShapes();
    _score = 0;
    _isGameOver = false;
  }

  bool _restoreSavedGame() {
    if (preferences.getInt(_stateVersionKey) != _stateVersion) {
      return false;
    }

    final score = preferences.getInt(_scoreKey);
    final isGameOver = preferences.getBool(_isGameOverKey);
    final trayShapeIds = preferences.getStringList(_trayKey);
    final boardShapeIds = preferences.getStringList(_boardKey);
    if (score == null ||
        isGameOver == null ||
        trayShapeIds == null ||
        boardShapeIds == null ||
        trayShapeIds.length != 3 ||
        boardShapeIds.length != BlocksBoard.size * BlocksBoard.size) {
      return false;
    }

    final tray = <BlockShape?>[];
    for (final shapeId in trayShapeIds) {
      final shape = _shapeFromId(shapeId);
      if (shapeId.isNotEmpty && shape == null) {
        return false;
      }
      tray.add(shape);
    }

    final rows = <List<BlockCell?>>[];
    for (var row = 0; row < BlocksBoard.size; row += 1) {
      final cells = <BlockCell?>[];
      for (var column = 0; column < BlocksBoard.size; column += 1) {
        final shapeId = boardShapeIds[(row * BlocksBoard.size) + column];
        final shape = _shapeFromId(shapeId);
        if (shapeId.isNotEmpty && shape == null) {
          return false;
        }
        cells.add(shape == null ? null : BlockCell(shape: shape));
      }
      rows.add(List<BlockCell?>.of(cells, growable: false));
    }

    _board = BlocksBoard(List<List<BlockCell?>>.of(rows, growable: false));
    _availableShapes = List<BlockShape?>.of(tray, growable: false);
    _score = score;
    _isGameOver = isGameOver;
    return true;
  }

  Future<void> _saveGameState() async {
    await Future.wait([
      preferences.setInt(_stateVersionKey, _stateVersion),
      preferences.setInt(_scoreKey, _score),
      preferences.setBool(_isGameOverKey, _isGameOver),
      preferences.setStringList(
        _trayKey,
        _availableShapes.map((shape) => shape?.id ?? '').toList(),
      ),
      preferences.setStringList(_boardKey, [
        for (final row in _board.cells)
          for (final cell in row) cell?.shape.id ?? '',
      ]),
    ]);
  }

  BlockShape? _shapeFromId(String shapeId) {
    if (shapeId.isEmpty) {
      return null;
    }

    for (final shape in BlockShapes.all) {
      if (shape.id == shapeId) {
        return shape;
      }
    }
    return null;
  }
}
