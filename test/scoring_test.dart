import 'package:flutter_test/flutter_test.dart';
import 'package:elements_grid/logic/game_controller.dart';
import 'package:elements_grid/models/difficulty.dart';
import 'package:elements_grid/models/element_type.dart';

void main() {
  late GameController ctrl;

  setUp(() {
    ctrl = GameController();
    ctrl.loadPuzzle(Difficulty.beginner);
  });

  tearDown(() {
    ctrl.dispose();
  });

  group('GameController — initial state', () {
    test('score starts at 0', () => expect(ctrl.score, 0));
    test('mistakes start at 0', () => expect(ctrl.mistakes, 0));
    test('combo starts at 0', () => expect(ctrl.combo, 0));
    test('hints start at 3', () => expect(ctrl.hints, 3));
    test('isComplete is false', () => expect(ctrl.isComplete, isFalse));
    test('puzzle is loaded', () => expect(ctrl.puzzle, isNotNull));
    test('levelNumber defaults to 1', () => expect(ctrl.levelNumber, 1));
  });

  group('GameController — correct placement', () {
    test('correct placement increases score by at least 10', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(solution);
      expect(ctrl.score, greaterThanOrEqualTo(10));
    });

    test('correct placement increments combo', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(solution);
      expect(ctrl.combo, 1);
    });

    test('correct placement does not increment mistakes', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(solution);
      expect(ctrl.mistakes, 0);
    });
  });

  group('GameController — wrong placement', () {
    test('wrong placement increments mistakes', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(_otherElement(solution));
      expect(ctrl.mistakes, 1);
    });

    test('wrong placement resets combo to 0', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(solution);
      expect(ctrl.combo, 1);

      final (r2, c2, solution2) = _firstEmpty(ctrl);
      ctrl.selectCell(r2, c2);
      ctrl.placeElement(_otherElement(solution2));
      expect(ctrl.combo, 0);
    });

    test('score does not go below 0 on wrong placement', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(_otherElement(solution));
      expect(ctrl.score, greaterThanOrEqualTo(0));
    });
  });

  group('GameController — hint', () {
    test('using hint decrements hint count', () {
      ctrl.useHint();
      expect(ctrl.hints, 2);
    });

    test('hint cost floors score at 0 when score is 0', () {
      ctrl.useHint();
      expect(ctrl.score, 0);
    });

    test('using all 3 hints leaves 0 hints', () {
      ctrl.useHint();
      ctrl.useHint();
      ctrl.useHint();
      expect(ctrl.hints, 0);
    });

    test('extra hint call beyond 0 is a no-op', () {
      ctrl.useHint();
      ctrl.useHint();
      ctrl.useHint();
      ctrl.useHint();
      expect(ctrl.hints, 0);
    });
  });

  group('GameController — clear cell', () {
    test('wrong value can be cleared', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(_otherElement(solution));
      expect(ctrl.puzzle!.grid[r][c].value, isNotNull);

      ctrl.selectCell(r, c);
      ctrl.clearCell();
      expect(ctrl.puzzle!.grid[r][c].value, isNull);
    });

    test('clearing a given cell leaves its value unchanged', () {
      final puzzle = ctrl.puzzle!;
      for (int r = 0; r < puzzle.size; r++) {
        for (int c = 0; c < puzzle.size; c++) {
          if (puzzle.grid[r][c].isGiven) {
            final before = puzzle.grid[r][c].value;
            ctrl.selectCell(r, c);
            ctrl.clearCell();
            expect(puzzle.grid[r][c].value, before);
            return;
          }
        }
      }
    });
  });

  group('GameController — consume one-shot messages', () {
    test('consumeAllianceMsg returns null when nothing pending', () {
      expect(ctrl.consumeAllianceMsg(), isNull);
    });

    test('consumeConflict returns false when nothing pending', () {
      expect(ctrl.consumeConflict(), isFalse);
    });

    test('double consume of alliance msg returns null on second call', () {
      ctrl.consumeAllianceMsg();
      expect(ctrl.consumeAllianceMsg(), isNull);
    });
  });

  group('GameController — reload resets state', () {
    test('all state is reset after loadPuzzle', () {
      final (r, c, solution) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      ctrl.placeElement(_otherElement(solution));
      expect(ctrl.mistakes, 1);

      ctrl.loadPuzzle(Difficulty.beginner);
      expect(ctrl.score, 0);
      expect(ctrl.mistakes, 0);
      expect(ctrl.combo, 0);
      expect(ctrl.hints, 3);
      expect(ctrl.isComplete, isFalse);
    });

    test('daily puzzle loads without error', () {
      expect(() => ctrl.loadDailyPuzzle(), returnsNormally);
      expect(ctrl.puzzle, isNotNull);
      expect(ctrl.levelNumber, 0);
    });
  });

  group('GameController — selection', () {
    test('selecting a given cell deselects', () {
      final puzzle = ctrl.puzzle!;
      for (int r = 0; r < puzzle.size; r++) {
        for (int c = 0; c < puzzle.size; c++) {
          if (puzzle.grid[r][c].isGiven) {
            ctrl.selectCell(r, c);
            expect(ctrl.selectedRow, isNull);
            expect(ctrl.selectedCol, isNull);
            return;
          }
        }
      }
    });

    test('selecting same non-given cell twice deselects it', () {
      final (r, c, _) = _firstEmpty(ctrl);
      ctrl.selectCell(r, c);
      expect(ctrl.selectedRow, r);
      ctrl.selectCell(r, c);
      expect(ctrl.selectedRow, isNull);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns (row, col, solution) for the first non-given, non-correct cell.
(int, int, ElementType) _firstEmpty(GameController ctrl) {
  final puzzle = ctrl.puzzle!;
  for (int r = 0; r < puzzle.size; r++) {
    for (int c = 0; c < puzzle.size; c++) {
      final cell = puzzle.grid[r][c];
      if (!cell.isGiven && !cell.isCorrect) {
        return (r, c, cell.solution);
      }
    }
  }
  throw StateError('No empty cells in puzzle');
}

/// Returns any ElementType that is NOT `target`.
ElementType _otherElement(ElementType target) {
  return ElementType.values.firstWhere((e) => e != target);
}
