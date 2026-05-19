import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cell.dart';
import '../models/difficulty.dart';
import '../models/element_type.dart';
import '../models/puzzle.dart';
import 'puzzle_generator.dart';

class GameController extends ChangeNotifier {
  Puzzle? _puzzle;
  int? _selectedRow;
  int? _selectedCol;
  int _score = 0;
  int _hints = 3;
  int _combo = 0;
  bool _isComplete = false;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;
  Timer? _timer;
  // Tracks cell-pair keys where alliance bonus has already been awarded
  final Set<String> _alliancePairs = {};
  // Last placed cell coords for overlay animations (exposed to UI)
  String? lastAllianceMsg;
  bool lastWasConflict = false;

  Puzzle?  get puzzle       => _puzzle;
  int?     get selectedRow  => _selectedRow;
  int?     get selectedCol  => _selectedCol;
  int      get score        => _score;
  int      get hints        => _hints;
  int      get combo        => _combo;
  Duration get elapsed      => _elapsed;
  bool     get isComplete   => _isComplete;

  String get elapsedDisplay {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void loadPuzzle(Difficulty difficulty) {
    _puzzle = PuzzleGenerator.generate(difficulty);
    _reset();
    notifyListeners();
  }

  void _reset() {
    _selectedRow = null;
    _selectedCol = null;
    _score = 0;
    _hints = 3;
    _combo = 0;
    _isComplete = false;
    _elapsed = Duration.zero;
    _alliancePairs.clear();
    lastAllianceMsg = null;
    lastWasConflict = false;
    _startTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------------
  // Cell selection
  // ---------------------------------------------------------------------------

  void selectCell(int row, int col) {
    final cell = _puzzle!.grid[row][col];
    if (cell.isGiven) {
      _selectedRow = null;
      _selectedCol = null;
    } else if (_selectedRow == row && _selectedCol == col) {
      _selectedRow = null;
      _selectedCol = null;
    } else {
      _selectedRow = row;
      _selectedCol = col;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Element placement
  // ---------------------------------------------------------------------------

  void placeElement(ElementType element) {
    if (_puzzle == null || _selectedRow == null || _selectedCol == null) return;
    final cell = _puzzle!.grid[_selectedRow!][_selectedCol!];
    if (cell.isGiven || cell.isCorrect) return;

    cell.value = element;
    lastAllianceMsg = null;
    lastWasConflict = false;

    if (element == cell.solution) {
      _score += 10;
      _combo++;
      if (_combo >= 3) _score += 50;

      if (_isRowComplete(_selectedRow!)) _score += 100;
      if (_isColComplete(_selectedCol!)) _score += 100;

      _checkAlliances(_selectedRow!, _selectedCol!);
      _checkConflict(_selectedRow!, _selectedCol!);
      _checkComplete();
    } else {
      _score = (_score - 20).clamp(0, 999999);
      _combo = 0;
    }

    notifyListeners();
  }

  void clearCell() {
    if (_puzzle == null || _selectedRow == null || _selectedCol == null) return;
    final cell = _puzzle!.grid[_selectedRow!][_selectedCol!];
    if (cell.isGiven || cell.isCorrect) return;
    cell.value = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Hint
  // ---------------------------------------------------------------------------

  void useHint() {
    if (_hints <= 0 || _puzzle == null) return;
    final wrong = [
      for (int r = 0; r < _puzzle!.size; r++)
        for (int c = 0; c < _puzzle!.size; c++)
          if (!_puzzle!.grid[r][c].isGiven && !_puzzle!.grid[r][c].isCorrect)
            (r, c)
    ];
    if (wrong.isEmpty) return;
    wrong.shuffle();
    final (r, c) = wrong.first;
    _puzzle!.grid[r][c].value = _puzzle!.grid[r][c].solution;
    _hints--;
    _score = (_score - 50).clamp(0, 999999);
    _selectedRow = r;
    _selectedCol = c;
    _checkComplete();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isRowComplete(int row) =>
      _puzzle!.grid[row].every((c) => c.isCorrect);

  bool _isColComplete(int col) =>
      List.generate(_puzzle!.size, (r) => _puzzle!.grid[r][col])
          .every((c) => c.isCorrect);

  void _checkAlliances(int row, int col) {
    final cell = _puzzle!.grid[row][col];
    const dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dr, dc) in dirs) {
      final nr = row + dr;
      final nc = col + dc;
      if (nr < 0 || nr >= _puzzle!.size) continue;
      if (nc < 0 || nc >= _puzzle!.size) continue;
      final neighbor = _puzzle!.grid[nr][nc];
      if (neighbor.value == null) continue;
      final rel = elementRelation(cell.solution, neighbor.value!);
      if (rel == ElementRelation.alliance) {
        final key =
            '${row < nr ? row : nr},${col < nc ? col : nc}-${row > nr ? row : nr},${col > nc ? col : nc}';
        if (!_alliancePairs.contains(key)) {
          _alliancePairs.add(key);
          _score += 20;
          lastAllianceMsg =
              '${cell.solution.emoji}+${neighbor.value!.emoji} Alliance! +20';
        }
      }
      if (rel == ElementRelation.conflict) {
        lastWasConflict = true;
      }
    }
  }

  void _checkConflict(int row, int col) {
    final cell = _puzzle!.grid[row][col];
    const dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dr, dc) in dirs) {
      final nr = row + dr;
      final nc = col + dc;
      if (nr < 0 || nr >= _puzzle!.size) continue;
      if (nc < 0 || nc >= _puzzle!.size) continue;
      final neighbor = _puzzle!.grid[nr][nc];
      if (neighbor.value == null) continue;
      if (elementRelation(cell.solution, neighbor.value!) ==
          ElementRelation.conflict) {
        lastWasConflict = true;
        return;
      }
    }
  }

  ElementRelation neighborRelation(int row, int col) {
    final cell = _puzzle!.grid[row][col];
    if (cell.value == null) return ElementRelation.none;
    ElementRelation best = ElementRelation.none;
    const dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    for (final (dr, dc) in dirs) {
      final nr = row + dr;
      final nc = col + dc;
      if (nr < 0 || nr >= _puzzle!.size) continue;
      if (nc < 0 || nc >= _puzzle!.size) continue;
      final neighbor = _puzzle!.grid[nr][nc];
      if (neighbor.value == null) continue;
      final rel = elementRelation(cell.value!, neighbor.value!);
      if (rel == ElementRelation.conflict) return ElementRelation.conflict;
      if (rel == ElementRelation.alliance) best = ElementRelation.alliance;
    }
    return best;
  }

  void _checkComplete() {
    if (!(_puzzle!.isSolved)) return;
    _isComplete = true;
    _timer?.cancel();
    final seconds = _elapsed.inSeconds;
    if (seconds < 60)  _score += 200;
    else if (seconds < 180) _score += 100;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
