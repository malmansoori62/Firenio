import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../logic/progress_manager.dart';
import '../models/difficulty.dart';
import '../themes/app_theme.dart';
import 'level_selection_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl     = context.watch<GameController>();
    final progress = context.watch<ProgressManager>();
    final puzzle   = ctrl.puzzle!;
    final stars    = _starsForMistakes(ctrl.mistakes);
    final streak   = progress.streak;
    final elapsed  = ctrl.elapsed;
    final multiplier = progress.streakMultiplierPercent();
    final finalScore = (ctrl.score * multiplier ~/ 100);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Puzzle Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              if (streak >= 3)
                Text(
                  '🔥 Streak ×$streak   Score ×${multiplier ~/ 100}.${multiplier % 100 ~/ 10}!',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 24),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    i < stars ? '⭐' : '☆',
                    style: TextStyle(
                      fontSize: 42,
                      color: i < stars
                          ? AppTheme.accentGold
                          : AppTheme.textSecondary,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 24),
              // Stats card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceAlt),
                ),
                child: Column(
                  children: [
                    _Row('Difficulty',
                        '${puzzle.difficulty.emoji} ${puzzle.difficulty.label}'),
                    _Row('Grid', '${puzzle.size}×${puzzle.size}'),
                    _Row('Base Score', '${ctrl.score}'),
                    if (multiplier != 100)
                      _Row('Streak Multiplier', '×${multiplier ~/ 100}.${multiplier % 100 ~/ 10}'),
                    _Row('Final Score', '$finalScore',
                        highlight: true),
                    _Row('Mistakes', '${ctrl.mistakes}'),
                    _Row(
                      'Time',
                      '${elapsed.inMinutes.remainder(60).toString().padLeft(2,'0')}'
                      ':${elapsed.inSeconds.remainder(60).toString().padLeft(2,'0')}',
                    ),
                    _Row('Stars Earned', '⭐ ×$stars'),
                    _Row('Total Stars', '⭐ ${progress.stars}'),
                  ],
                ),
              ),
              const Spacer(),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _Btn(
                      label: '🔄 Again',
                      onTap: () {
                        ctrl.loadPuzzle(puzzle.difficulty,
                            levelNumber: ctrl.levelNumber ?? 1);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Btn(
                      label: '▶ Next',
                      primary: true,
                      onTap: () {
                        final next = (ctrl.levelNumber ?? 1) + 1;
                        ctrl.loadPuzzle(puzzle.difficulty, levelNumber: next);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Btn(
                      label: '📋 Levels',
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LevelSelectionScreen(),
                        ),
                        (r) => r.isFirst,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  int _starsForMistakes(int m) {
    if (m == 0) return 3;
    if (m <= 2) return 2;
    return 1;
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Row(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.subtitleStyle),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppTheme.accentGold : AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: highlight ? 17 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;

  const _Btn({required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: primary ? AppTheme.accent : AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      ),
    ),
  );
}
