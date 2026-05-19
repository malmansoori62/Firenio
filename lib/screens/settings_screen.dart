import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/progress_manager.dart';
import '../models/app_settings.dart';
import '../models/game_theme_model.dart';
import '../themes/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final progress = context.watch<ProgressManager>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section('Audio'),
          _Toggle(
            label: 'Sound Effects',
            icon: Icons.volume_up,
            value: settings.sound,
            onChanged: settings.setSound,
          ),
          _Toggle(
            label: 'Music',
            icon: Icons.music_note,
            value: settings.music,
            onChanged: settings.setMusic,
          ),
          const SizedBox(height: 16),

          _Section('Gameplay'),
          _Toggle(
            label: 'Vibration on Error',
            icon: Icons.vibration,
            value: settings.vibration,
            onChanged: settings.setVibration,
          ),
          _Toggle(
            label: 'Show Timer',
            icon: Icons.timer,
            value: settings.showTimer,
            onChanged: settings.setShowTimer,
          ),
          const SizedBox(height: 16),

          _Section('Language'),
          _LanguagePicker(settings: settings),
          const SizedBox(height: 16),

          _Section('Visual Theme'),
          _ThemePicker(settings: settings, progress: progress),
          const SizedBox(height: 16),

          _Section('Account'),
          _InfoRow('Total Stars',    '⭐ ${progress.stars}'),
          _InfoRow('Total Gems',     '💎 ${progress.gems}'),
          _InfoRow('Levels Cleared', '🏆 ${progress.totalCompleted}'),
          _InfoRow('Current Streak', '🔥 ${progress.streak}'),
          const SizedBox(height: 8),
          _ActionRow(
            label: 'Sync with Google Play',
            icon: Icons.sync,
            onTap: () => _comingSoon(context),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Coming in Phase 3 🚀'),
        backgroundColor: AppTheme.surfaceAlt,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Toggle row
// ---------------------------------------------------------------------------

class _Toggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _Toggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppTheme.textPrimary)),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppTheme.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language picker
// ---------------------------------------------------------------------------

class _LanguagePicker extends StatelessWidget {
  final AppSettings settings;
  const _LanguagePicker({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          const Text('Language', style: TextStyle(color: AppTheme.textPrimary)),
          const Spacer(),
          _LangButton(
            label: 'EN',
            selected: settings.language == 'en',
            onTap: () => settings.setLanguage('en'),
          ),
          const SizedBox(width: 8),
          _LangButton(
            label: 'AR',
            selected: settings.language == 'ar',
            onTap: () => settings.setLanguage('ar'),
          ),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppTheme.accent : AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Theme picker
// ---------------------------------------------------------------------------

class _ThemePicker extends StatelessWidget {
  final AppSettings settings;
  final ProgressManager progress;
  const _ThemePicker({required this.settings, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: kThemes.map((theme) {
        final unlocked = progress.isThemeUnlocked(theme.id);
        final active   = settings.activeTheme == theme.id;
        return GestureDetector(
          onTap: unlocked ? () => settings.setActiveTheme(theme.id) : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? theme.accent.withOpacity(0.2)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? theme.accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(theme.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(theme.name,
                          style: TextStyle(
                            color: unlocked
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          )),
                      if (!unlocked)
                        Text(
                          theme.gemCost > 0
                              ? '💎 ${theme.gemCost} gems'
                              : '🏆 Reach level ${theme.unlockLevel}',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                    ],
                  ),
                ),
                if (active)
                  const Icon(Icons.check_circle,
                      color: AppTheme.correctGreen, size: 20),
                if (!unlocked)
                  const Icon(Icons.lock_outline,
                      color: AppTheme.textSecondary, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Info / action rows
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.accentGold, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionRow({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
          const Spacer(),
          const Icon(Icons.chevron_right,
              color: AppTheme.textSecondary, size: 18),
        ],
      ),
    ),
  );
}
