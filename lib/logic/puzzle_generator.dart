import 'dart:math';
import '../models/cell.dart';
import '../models/difficulty.dart';
import '../models/element_type.dart';
import '../models/puzzle.dart';

class PuzzleGenerator {
  static Random _rng = Random();

  // Standard random puzzle
  static Puzzle generate(Difficulty difficulty) =>
      _build(difficulty, Random());

  // Date-seeded puzzle — same result for every player on a given day
  static Puzzle generateWithSeed(Difficulty difficulty, int seed) =>
      _build(difficulty, Random(seed));

  // ---------------------------------------------------------------------------

  static Puzzle _build(Difficulty difficulty, Random rng) {
    _rng = rng;
    final size = difficulty.gridSize;
    final (boxR, boxC) = difficulty.boxDimensions;

    List<List<int>>? solved;
    for (int attempt = 0; attempt < 30; attempt++) {
      final g = List.generate(size, (_) => List.filled(size, 0));
      if (_backtrack(g, size, boxR, boxC)) {
        solved = g;
        break;
      }
    }
    if (solved == null) throw StateError('Puzzle generation failed after 30 attempts');

    // Validate the solved grid before using it
    assert(_isSolvedGridValid(solved, size, boxR, boxC),
        'Generated grid is invalid — bug in solver');

    final totalCells = size * size;
    final toRemove = (totalCells * difficulty.removalRate).round();
    final positions = [
      for (int r = 0; r < size; r++)
        for (int c = 0; c < size; c++) (r, c)
    ]..shuffle(_rng);
    final removed = positions.take(toRemove).toSet();

    final grid = List.generate(
      size,
      (r) => List.generate(size, (c) {
        final isGiven = !removed.contains((r, c));
        return Cell(
          row: r,
          col: c,
          solution: ElementType.values[solved![r][c] - 1],
          isGiven: isGiven,
          value: isGiven ? ElementType.values[solved[r][c] - 1] : null,
        );
      }),
    );

    return Puzzle(difficulty: difficulty, grid: grid, size: size);
  }

  // ---------------------------------------------------------------------------
  // Backtracking solver
  // ---------------------------------------------------------------------------

  static bool _backtrack(List<List<int>> grid, int size, int boxR, int boxC) {
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] != 0) continue;
        final candidates = List.generate(size, (i) => i + 1)..shuffle(_rng);
        for (final v in candidates) {
          if (_isValid(grid, r, c, v, size, boxR, boxC)) {
            grid[r][c] = v;
            if (_backtrack(grid, size, boxR, boxC)) return true;
            grid[r][c] = 0;
          }
        }
        return false;
      }
    }
    return true;
  }

  static bool _isValid(
    List<List<int>> grid,
    int r,
    int c,
    int v,
    int size,
    int boxR,
    int boxC,
  ) {
    for (int j = 0; j < size; j++) {
      if (grid[r][j] == v) return false;
    }
    for (int i = 0; i < size; i++) {
      if (grid[i][c] == v) return false;
    }
    if (boxR > 0 && boxC > 0) {
      final sr = (r ~/ boxR) * boxR;
      final sc = (c ~/ boxC) * boxC;
      for (int i = sr; i < sr + boxR; i++) {
        for (int j = sc; j < sc + boxC; j++) {
          if (grid[i][j] == v) return false;
        }
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Validation helper (used in assertions & tests)
  // ---------------------------------------------------------------------------

  static bool _isSolvedGridValid(
      List<List<int>> grid, int size, int boxR, int boxC) {
    final expected = List.generate(size, (i) => i + 1).toSet();

    // Rows
    for (int r = 0; r < size; r++) {
      if (grid[r].toSet() != expected) return false;
    }
    // Columns
    for (int c = 0; c < size; c++) {
      if (List.generate(size, (r) => grid[r][c]).toSet() != expected) {
        return false;
      }
    }
    // Boxes
    if (boxR > 0 && boxC > 0) {
      for (int br = 0; br < size ~/ boxR; br++) {
        for (int bc = 0; bc < size ~/ boxC; bc++) {
          final vals = <int>{};
          for (int r = br * boxR; r < (br + 1) * boxR; r++) {
            for (int c = bc * boxC; c < (bc + 1) * boxC; c++) {
              vals.add(grid[r][c]);
            }
          }
          if (vals != expected) return false;
        }
      }
    }
    return true;
  }

  /// Exposed for unit tests
  static bool validatePuzzle(Puzzle p) {
    final (boxR, boxC) = p.difficulty.boxDimensions;
    final solved =
        List.generate(p.size, (r) => List.generate(p.size, (c) {
          return p.grid[r][c].solution.index + 1;
        }));
    return _isSolvedGridValid(solved, p.size, boxR, boxC);
  }
}
