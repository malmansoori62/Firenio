import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../logic/progress_manager.dart';
import '../themes/app_theme.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'level_selection_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressManager>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Currency row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CurrencyBadge(label: '⭐ ${progress.stars}'),
                  const SizedBox(width: 8),
                  _CurrencyBadge(label: '💎 ${progress.gems}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Logo / title
            const Text('🔥💧🌿', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Elements Grid', style: AppTheme.titleStyle),
            const SizedBox(height: 8),
            const Text('Master the Elements', style: AppTheme.subtitleStyle),
            if (progress.streak >= 3) ...[
              const SizedBox(height: 8),
              Text(
                '🔥 Streak ×${progress.streak}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const Spacer(flex: 3),
            // Buttons
            _MenuButton(
              label: '▶  Play',
              isPrimary: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LevelSelectionScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _MenuButton(
              label: '📅 Daily Puzzle',
              onTap: () => _launchDaily(context),
            ),
            const SizedBox(height: 14),
            _MenuButton(
              label: '🏆 Leaderboard',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _MenuButton(
              label: '💎 Shop',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShopScreen()),
              ),
            ),
            const SizedBox(height: 14),
            _MenuButton(
              label: '⚙  Settings',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const Spacer(flex: 2),
            Text(
              'v2.0',
              style: AppTheme.labelStyle.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _launchDaily(BuildContext context) {
    final ctrl = context.read<GameController>();
    ctrl.loadDailyPuzzle();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: ctrl),
            ChangeNotifierProvider.value(
                value: context.read<ProgressManager>()),
          ],
          child: const GameScreen(),
        ),
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  final String label;
  const _CurrencyBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.accentGold,
          ),
        ),
      );
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.accent : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isPrimary ? Colors.white : AppTheme.textPrimary,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
