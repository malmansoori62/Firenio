import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/difficulty.dart';
import '../models/element_type.dart';
import '../themes/app_theme.dart';
import 'cell_widget.dart';

class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final puzzle = ctrl.puzzle;
    if (puzzle == null) return const SizedBox.shrink();

    final size = puzzle.size;
    final (boxR, boxC) = puzzle.difficulty.boxDimensions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = constraints.maxWidth.clamp(0.0, constraints.maxHeight);
        final cellSize = (gridSize - (size + 1) * 2) / size;

        return SizedBox(
          width: gridSize,
          height: gridSize,
          child: Stack(
            children: [
              // Grid cells
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: size * size,
                itemBuilder: (context, index) {
                  final row = index ~/ size;
                  final col = index % size;
                  final cell = puzzle.grid[row][col];

                  final isSelected =
                      ctrl.selectedRow == row && ctrl.selectedCol == col;
                  final selRow = ctrl.selectedRow;
                  final selCol = ctrl.selectedCol;

                  final isSameRow = selRow == row;
                  final isSameCol = selCol == col;
                  final isSameBox = boxR > 0 &&
                      selRow != null &&
                      selCol != null &&
                      (row ~/ boxR) == (selRow ~/ boxR) &&
                      (col ~/ boxC) == (selCol ~/ boxC);

                  final relation = ctrl.neighborRelation(row, col);

                  return CellWidget(
                    cell: cell,
                    isSelected: isSelected,
                    isSameRow: isSameRow,
                    isSameCol: isSameCol,
                    isSameBox: isSameBox,
                    relation: relation,
                    onTap: () => ctrl.selectCell(row, col),
                  );
                },
              ),
              // Box dividers (thicker lines between boxes)
              if (boxR > 0 && boxC > 0)
                _BoxDividers(
                  size: size,
                  boxR: boxR,
                  boxC: boxC,
                  gridSize: gridSize,
                  cellSize: cellSize,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BoxDividers extends StatelessWidget {
  final int size;
  final int boxR;
  final int boxC;
  final double gridSize;
  final double cellSize;

  const _BoxDividers({
    required this.size,
    required this.boxR,
    required this.boxC,
    required this.gridSize,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    final lines = <Widget>[];
    final spacing = cellSize + 2;

    // Horizontal box lines
    for (int r = boxR; r < size; r += boxR) {
      final y = r * spacing;
      lines.add(Positioned(
        top: y - 1.5,
        left: 0,
        right: 0,
        child: Container(
          height: 2.5,
          color: AppTheme.textSecondary.withOpacity(0.5),
        ),
      ));
    }
    // Vertical box lines
    for (int c = boxC; c < size; c += boxC) {
      final x = c * spacing;
      lines.add(Positioned(
        left: x - 1.5,
        top: 0,
        bottom: 0,
        child: Container(
          width: 2.5,
          color: AppTheme.textSecondary.withOpacity(0.5),
        ),
      ));
    }

    return Stack(children: lines);
  }
}
