import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../themes/app_theme.dart';
import 'level_selection_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final puzzle = ctrl.puzzle!;
    final stars = _starsForScore(ctrl.score);
    final elapsed = ctrl.elapsed;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚡ Puzzle Complete! ⚡',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  )),
              const SizedBox(height: 32),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      i < stars ? '⭐' : '☆',
                      style: TextStyle(
                        fontSize: 40,
                        color: i < stars
                            ? AppTheme.accentGold
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Stats card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceAlt),
                ),
                child: Column(
                  children: [
                    _StatRow('Difficulty',
                        '${puzzle.difficulty.emoji} ${puzzle.difficulty.label}'),
                    _StatRow('Grid', '${puzzle.size}×${puzzle.size}'),
                    _StatRow('Final Score', '${ctrl.score}'),
                    _StatRow(
                      'Time',
                      '${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}'
                      ':${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                    ),
                    _StatRow('Hints Used', '${3 - ctrl.hints}'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _ResultButton(
                      label: '🔄 Play Again',
                      isPrimary: false,
                      onTap: () {
                        ctrl.loadPuzzle(puzzle.difficulty);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultButton(
                      label: '📋 Levels',
                      isPrimary: true,
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LevelSelectionScreen(),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _starsForScore(int score) {
    if (score >= 500) return 3;
    if (score >= 250) return 2;
    if (score > 0) return 1;
    return 0;
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.subtitleStyle),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ResultButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.accent : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
