import 'element_type.dart';

class Cell {
  final int row;
  final int col;
  final ElementType solution;
  final bool isGiven;
  ElementType? value;

  Cell({
    required this.row,
    required this.col,
    required this.solution,
    required this.isGiven,
    this.value,
  });

  bool get isEmpty    => value == null;
  bool get isCorrect  => value != null && value == solution;
  bool get isWrong    => value != null && value != solution;
}
