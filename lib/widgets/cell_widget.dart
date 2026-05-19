import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/element_type.dart';
import '../themes/app_theme.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final bool isSameRow;
  final bool isSameCol;
  final bool isSameBox;
  final ElementRelation relation;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.isSameRow,
    required this.isSameCol,
    required this.isSameBox,
    required this.relation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = _backgroundColor();
    final borderColor = _borderColor();
    final borderWidth = isSelected ? 2.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: _buildContent()),
      ),
    );
  }

  Color _backgroundColor() {
    if (isSelected) return AppTheme.accent.withOpacity(0.25);
    if (isSameRow || isSameCol || isSameBox) {
      return AppTheme.surfaceAlt.withOpacity(0.7);
    }
    if (cell.isGiven) return AppTheme.surfaceAlt;
    return AppTheme.surface;
  }

  Color _borderColor() {
    if (isSelected) return AppTheme.accent;
    if (cell.isWrong) return AppTheme.conflictRed;
    if (relation == ElementRelation.conflict) return AppTheme.conflictRed;
    if (relation == ElementRelation.alliance) return AppTheme.allianceGold;
    if (cell.isCorrect && !cell.isGiven) return AppTheme.correctGreen;
    return AppTheme.surfaceAlt;
  }

  Widget _buildContent() {
    if (cell.value == null) return const SizedBox.shrink();

    final element = cell.value!;
    final size = _emojiSize();

    Widget emoji = Text(
      element.emoji,
      style: TextStyle(fontSize: size),
      textAlign: TextAlign.center,
    );

    // Wrong placement: dim with red overlay
    if (cell.isWrong) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.5, child: emoji),
          Icon(Icons.close, color: AppTheme.conflictRed, size: size * 0.8),
        ],
      );
    }

    // Alliance glow
    if (relation == ElementRelation.alliance && cell.isCorrect) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.allianceGold.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: emoji,
      );
    }

    return emoji;
  }

  double _emojiSize() {
    // Caller's cell size determines font — use a reasonable default
    // since CellWidget doesn't know its own size. Parent constrains via LayoutBuilder.
    return 22;
  }
}
