import 'dart:math';
import '../models/cell.dart';
import '../models/difficulty.dart';
import '../models/element_type.dart';
import '../models/puzzle.dart';

class PuzzleGenerator {
  static final Random _rng = Random();

  static Puzzle generate(Difficulty difficulty) {
    final size = difficulty.gridSize;
    final (boxR, boxC) = difficulty.boxDimensions;

    // Build a fully-solved grid, retry up to 20 times if needed
    List<List<int>>? solved;
    for (int attempt = 0; attempt < 20; attempt++) {
      final g = List.generate(size, (_) => List.filled(size, 0));
      if (_backtrack(g, size, boxR, boxC)) {
        solved = g;
        break;
      }
    }
    if (solved == null) throw StateError('Puzzle generation failed');

    // Decide which cells to expose as givens
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
        return false; // Dead end — trigger backtrack
      }
    }
    return true; // All cells filled
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
    // Row
    for (int j = 0; j < size; j++) {
      if (grid[r][j] == v) return false;
    }
    // Column
    for (int i = 0; i < size; i++) {
      if (grid[i][c] == v) return false;
    }
    // Box (only when box dimensions are defined)
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
}
