import 'package:flutter_test/flutter_test.dart';
import 'package:elements_grid/logic/puzzle_generator.dart';
import 'package:elements_grid/models/difficulty.dart';

void main() {
  group('PuzzleGenerator', () {
    test('beginner puzzle (4×4) is valid', () {
      final puzzle = PuzzleGenerator.generate(Difficulty.beginner);
      expect(puzzle.size, 4);
      expect(PuzzleGenerator.validatePuzzle(puzzle), isTrue);
    });

    test('medium puzzle (5×5) is valid', () {
      final puzzle = PuzzleGenerator.generate(Difficulty.medium);
      expect(puzzle.size, 5);
      expect(PuzzleGenerator.validatePuzzle(puzzle), isTrue);
    });

    test('hard puzzle (6×6) is valid', () {
      final puzzle = PuzzleGenerator.generate(Difficulty.hard);
      expect(puzzle.size, 6);
      expect(PuzzleGenerator.validatePuzzle(puzzle), isTrue);
    });

    test('given cells already have correct values', () {
      final puzzle = PuzzleGenerator.generate(Difficulty.beginner);
      for (int r = 0; r < puzzle.size; r++) {
        for (int c = 0; c < puzzle.size; c++) {
          final cell = puzzle.grid[r][c];
          if (cell.isGiven) {
            expect(cell.value, cell.solution,
                reason: 'Given cell at ($r,$c) must equal its solution');
          }
        }
      }
    });

    test('non-given cells start empty', () {
      final puzzle = PuzzleGenerator.generate(Difficulty.beginner);
      for (int r = 0; r < puzzle.size; r++) {
        for (int c = 0; c < puzzle.size; c++) {
          final cell = puzzle.grid[r][c];
          if (!cell.isGiven) {
            expect(cell.value, isNull,
                reason: 'Non-given cell at ($r,$c) must start empty');
          }
        }
      }
    });

    test('daily puzzle is deterministic for the same seed', () {
      const seed = 20260101;
      final p1 = PuzzleGenerator.generateWithSeed(Difficulty.hard, seed);
      final p2 = PuzzleGenerator.generateWithSeed(Difficulty.hard, seed);
      for (int r = 0; r < p1.size; r++) {
        for (int c = 0; c < p1.size; c++) {
          expect(p1.grid[r][c].solution, p2.grid[r][c].solution,
              reason: 'Seeded puzzles must be identical at ($r,$c)');
        }
      }
    });

    test('hard has higher removal rate than beginner', () {
      final beginner = PuzzleGenerator.generate(Difficulty.beginner);
      final hard     = PuzzleGenerator.generate(Difficulty.hard);
      final beginnerEmptyFraction =
          1 - (beginner.correctCount / beginner.totalCells);
      final hardEmptyFraction = 1 - (hard.correctCount / hard.totalCells);
      expect(hardEmptyFraction, greaterThan(beginnerEmptyFraction));
    });

    test('puzzle grid dimensions match declared size', () {
      for (final diff in Difficulty.values) {
        final p = PuzzleGenerator.generate(diff);
        expect(p.grid.length, p.size);
        for (final row in p.grid) {
          expect(row.length, p.size);
        }
      }
    });

    test('puzzle isSolved is false when cells are empty', () {
      final puzzle = PuzzleGenerator.generate(Difficulty.beginner);
      final hasEmpty = puzzle.grid.any((row) => row.any((c) => !c.isGiven));
      if (hasEmpty) {
        expect(puzzle.isSolved, isFalse);
      }
    });

    test('elements list length equals grid size', () {
      for (final diff in Difficulty.values) {
        final p = PuzzleGenerator.generate(diff);
        expect(p.elements.length, p.size);
      }
    });
  });
}
