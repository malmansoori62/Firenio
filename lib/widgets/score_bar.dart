import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../themes/app_theme.dart';

class ScoreBar extends StatelessWidget {
  const ScoreBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.surfaceAlt, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Score
          _Stat(
            label: 'SCORE',
            value: '${ctrl.score}',
            valueStyle: AppTheme.scoreStyle,
          ),
          const Spacer(),
          // Combo
          if (ctrl.combo >= 2)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _Stat(
                label: 'COMBO',
                value: '×${ctrl.combo}',
                valueStyle: AppTheme.scoreStyle.copyWith(
                  color: AppTheme.accent,
                  fontSize: 18,
                ),
              ),
            ),
          // Timer
          _Stat(
            label: 'TIME',
            value: ctrl.elapsedDisplay,
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          // Hints remaining
          _Stat(
            label: 'HINTS',
            value: '💡×${ctrl.hints}',
            valueStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ctrl.hints > 0
                  ? AppTheme.accentGold
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;

  const _Stat({
    required this.label,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTheme.labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
