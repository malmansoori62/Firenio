import 'cell.dart';
import 'difficulty.dart';
import 'element_type.dart';

class Puzzle {
  final Difficulty difficulty;
  final List<List<Cell>> grid;
  final int size;

  Puzzle({
    required this.difficulty,
    required this.grid,
    required this.size,
  });

  /// Elements used in this puzzle (first [size] elements)
  List<ElementType> get elements => ElementType.values.take(size).toList();

  bool get isSolved =>
      grid.every((row) => row.every((c) => c.isCorrect));

  int get correctCount =>
      grid.expand((r) => r).where((c) => c.isCorrect).length;

  int get totalCells => size * size;
}
