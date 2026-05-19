import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'level_selection_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo / title
            const Text('🔥💧🌿', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Elements Grid', style: AppTheme.titleStyle),
            const SizedBox(height: 8),
            const Text('Master the Elements', style: AppTheme.subtitleStyle),
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
            _MenuButton(label: '⚙  Settings', onTap: () => _comingSoon(context)),
            const SizedBox(height: 14),
            _MenuButton(label: '💎 Shop',     onTap: () => _comingSoon(context)),
            const Spacer(flex: 2),
            Text(
              'v1.0 — Phase 1',
              style: AppTheme.labelStyle.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Coming in Phase 2 🚀'),
        backgroundColor: AppTheme.surfaceAlt,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
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
