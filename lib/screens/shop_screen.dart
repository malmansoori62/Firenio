import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/progress_manager.dart';
import '../models/game_theme_model.dart';
import '../themes/app_theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressManager>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Text('⭐ ${progress.stars}',
                    style: const TextStyle(
                        color: AppTheme.accentGold, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Text('💎 ${progress.gems}',
                    style: const TextStyle(
                        color: AppTheme.accent, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section('Hints'),
          _HintRow(
            label: '3 Hints',
            starCost: 5,
            count: 3,
            progress: progress,
            context: context,
          ),
          _HintRow(
            label: '10 Hints',
            starCost: 15,
            count: 10,
            progress: progress,
            context: context,
          ),
          const SizedBox(height: 16),
          _Section('Themes'),
          ...kThemes.where((t) => t.gemCost > 0).map(
                (theme) => _ThemeRow(theme: theme, progress: progress, ctx: context),
              ),
          const SizedBox(height: 16),
          _Section('Coming Soon'),
          _ComingSoonRow(label: '🚀 Remove Ads'),
          _ComingSoonRow(label: '🌈 Animated Themes'),
          _ComingSoonRow(label: '🎵 Custom Music Packs'),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: AppTheme.labelStyle.copyWith(
            fontSize: 11,
            letterSpacing: 1.4,
            color: AppTheme.accent,
          ),
        ),
      );
}

class _HintRow extends StatelessWidget {
  final String label;
  final int starCost;
  final int count;
  final ProgressManager progress;
  final BuildContext context;

  const _HintRow({
    required this.label,
    required this.starCost,
    required this.count,
    required this.progress,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final canAfford = progress.stars >= starCost;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                Text('Costs ⭐ $starCost stars',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          _BuyButton(
            label: '⭐ $starCost',
            enabled: canAfford,
            onTap: () async {
              final ok = await progress.buyHintsWithStars(count, starCost);
              if (!ok) _showToast(context, 'Not enough stars!');
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final GameThemeModel theme;
  final ProgressManager progress;
  final BuildContext ctx;

  const _ThemeRow({
    required this.theme,
    required this.progress,
    required this.ctx,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.isThemeUnlocked(theme.id);
    final canAfford = progress.gems >= theme.gemCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: unlocked
            ? Border.all(color: theme.accent.withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Text(theme.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(theme.name,
                    style: TextStyle(
                      color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
                if (!unlocked)
                  Text('💎 ${theme.gemCost} gems',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          if (unlocked)
            const Text('✅ Owned',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.correctGreen,
                    fontWeight: FontWeight.w700))
          else
            _BuyButton(
              label: '💎 ${theme.gemCost}',
              enabled: canAfford,
              onTap: () async {
                final ok = await progress.buyThemeWithGems(theme.id, theme.gemCost);
                if (!ok) _showToast(ctx, 'Not enough gems!');
              },
            ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _BuyButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? AppTheme.accent : AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: enabled ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      );
}

class _ComingSoonRow extends StatelessWidget {
  final String label;
  const _ComingSoonRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: AppTheme.textSecondary))),
          const Text('Coming Soon',
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

void _showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.conflictRed,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
