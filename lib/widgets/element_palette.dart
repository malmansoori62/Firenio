import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../models/element_type.dart';
import '../themes/app_theme.dart';

class ElementPalette extends StatelessWidget {
  const ElementPalette({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final puzzle = ctrl.puzzle;
    if (puzzle == null) return const SizedBox.shrink();

    final elements = puzzle.elements;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.surfaceAlt, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Clear button
          _ActionButton(
            icon: Icons.backspace_outlined,
            label: 'Clear',
            color: AppTheme.textSecondary,
            onTap: ctrl.selectedRow != null ? () => ctrl.clearCell() : null,
          ),
          // Element buttons
          ...elements.map((e) => _ElementButton(element: e)),
          // Hint button
          _ActionButton(
            icon: Icons.lightbulb_outline,
            label: '${ctrl.hints}',
            color: ctrl.hints > 0 ? AppTheme.accentGold : AppTheme.textSecondary,
            onTap: ctrl.hints > 0 ? () => ctrl.useHint() : null,
          ),
        ],
      ),
    );
  }
}

class _ElementButton extends StatelessWidget {
  final ElementType element;

  const _ElementButton({required this.element});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<GameController>();
    final canPlace = ctrl.selectedRow != null;

    return GestureDetector(
      onTap: canPlace ? () => ctrl.placeElement(element) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: canPlace
              ? element.color.withOpacity(0.15)
              : AppTheme.surfaceAlt.withOpacity(0.3),
          border: Border.all(
            color: canPlace ? element.color.withOpacity(0.6) : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              element.emoji,
              style: const TextStyle(fontSize: 22),
            ),
            Text(
              element.label,
              style: TextStyle(
                fontSize: 8,
                color: canPlace ? element.color : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: onTap != null ? color : color.withOpacity(0.3), size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: onTap != null ? color : color.withOpacity(0.3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
