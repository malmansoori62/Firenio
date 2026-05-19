import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
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
  final difficulties = Difficulty.values;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: difficulties.length, vsync: this);
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
          tabs: difficulties
              .map((d) => Tab(text: '${d.emoji} ${d.label}'))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: difficulties
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
    const levelCount = 20;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: levelCount,
      itemBuilder: (ctx, i) => _LevelCard(
        level: i + 1,
        difficulty: difficulty,
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final Difficulty difficulty;

  const _LevelCard({required this.level, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _startLevel(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.surfaceAlt,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$level',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              difficulty.emoji,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _startLevel(BuildContext context) {
    final ctrl = context.read<GameController>();
    ctrl.loadPuzzle(difficulty);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: ctrl,
          child: const GameScreen(),
        ),
      ),
    );
  }
}
