import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
import '../logic/progress_manager.dart';
import '../models/difficulty.dart';
import '../themes/app_theme.dart';
import '../widgets/element_palette.dart';
import '../widgets/game_grid.dart';
import '../widgets/score_bar.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? _toastMsg;
  bool    _conflictFlash = false;
  bool    _navigating    = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().addListener(_onGameChange);
    });
  }

  void _onGameChange() {
    if (!mounted) return;
    final ctrl = context.read<GameController>();

    // Consume one-shot messages immediately so timer ticks don't re-fire them
    final allianceMsg = ctrl.consumeAllianceMsg();
    final conflict    = ctrl.consumeConflict();

    if (ctrl.isComplete && !_navigating) {
      _navigating = true;
      Future.delayed(const Duration(milliseconds: 350), _goToResult);
      return;
    }

    if (allianceMsg != null) _showToast(allianceMsg);
    if (conflict)            _flashConflict();
  }

  Future<void> _goToResult() async {
    if (!mounted) return;
    final ctrl     = context.read<GameController>();
    final progress = context.read<ProgressManager>();

    await progress.completeLevel(
      difficulty:   ctrl.puzzle!.difficulty,
      levelNumber:  ctrl.levelNumber ?? 1,
      score:        ctrl.score,
      mistakes:     ctrl.mistakes,
      elapsed:      ctrl.elapsed,
      playerName:   'Player',
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: ctrl),
            ChangeNotifierProvider.value(value: progress),
          ],
          child: const ResultScreen(),
        ),
      ),
    );
  }

  void _showToast(String msg) {
    if (!mounted) return;
    setState(() => _toastMsg = msg);
    Future.delayed(const Duration(milliseconds: 1800),
        () { if (mounted) setState(() => _toastMsg = null); });
  }

  void _flashConflict() {
    if (!mounted) return;
    setState(() => _conflictFlash = true);
    Future.delayed(const Duration(milliseconds: 350),
        () { if (mounted) setState(() => _conflictFlash = false); });
  }

  @override
  void dispose() {
    context.read<GameController>().removeListener(_onGameChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl   = context.watch<GameController>();
    final puzzle = ctrl.puzzle;
    if (puzzle == null) return const Scaffold();

    return Scaffold(
      backgroundColor: _conflictFlash
          ? AppTheme.conflictRed.withOpacity(0.07)
          : AppTheme.background,
      appBar: AppBar(
        title: Text(
          '${puzzle.difficulty.emoji} ${puzzle.difficulty.label}  '
          '${puzzle.size}×${puzzle.size}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Streak badge
          if (context.watch<ProgressManager>().streak >= 3)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '🔥 ×${context.watch<ProgressManager>().streak}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
            onPressed: () {
              _navigating = false;
              ctrl.loadPuzzle(puzzle.difficulty,
                  levelNumber: ctrl.levelNumber ?? 1);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const ScoreBar(),
                LinearProgressIndicator(
                  value: puzzle.correctCount / puzzle.totalCells,
                  backgroundColor: AppTheme.surfaceAlt,
                  color: AppTheme.correctGreen,
                  minHeight: 3,
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: const GameGrid(),
                      ),
                    ),
                  ),
                ),
                const ElementPalette(),
              ],
            ),
            if (_toastMsg != null)
              Positioned(
                top: 72,
                left: 0,
                right: 0,
                child: Center(child: _Toast(message: _toastMsg!)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  final String message;
  const _Toast({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.allianceGold,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.allianceGold.withOpacity(0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
