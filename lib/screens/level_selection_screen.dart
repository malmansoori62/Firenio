import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../logic/progress_manager.dart';
import '../models/difficulty.dart';
import '../themes/app_theme.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: Difficulty.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Select Level'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: Difficulty.values
              .map((d) => Tab(text: '${d.emoji} ${d.label}'))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: Difficulty.values
            .map((d) => _LevelGrid(difficulty: d))
            .toList(),
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final Difficulty difficulty;
  const _LevelGrid({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    const levels = 20;
    final progress = context.watch<ProgressManager>();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: levels,
      itemBuilder: (ctx, i) {
        final level = i + 1;
        final done  = progress.isCompleted(difficulty, level);
        final hs    = progress.highScore(difficulty, level);
        return _LevelCard(
          level: level,
          difficulty: difficulty,
          isCompleted: done,
          highScore: hs,
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final Difficulty difficulty;
  final bool isCompleted;
  final int? highScore;

  const _LevelCard({
    required this.level,
    required this.difficulty,
    required this.isCompleted,
    this.highScore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _start(context),
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.correctGreen.withOpacity(0.15)
              : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? AppTheme.correctGreen.withOpacity(0.6)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted)
              const Text('✅', style: TextStyle(fontSize: 14))
            else
              Text(
                '$level',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            if (highScore != null)
              Text(
                '$highScore',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.accentGold,
                ),
              )
            else
              Text(
                difficulty.emoji,
                style: const TextStyle(fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  void _start(BuildContext ctx) {
    final ctrl = ctx.read<GameController>();
    ctrl.loadPuzzle(difficulty, levelNumber: level);
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: ctrl),
            ChangeNotifierProvider.value(value: ctx.read<ProgressManager>()),
          ],
          child: const GameScreen(),
        ),
      ),
    );
  }
}
