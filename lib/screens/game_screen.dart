import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_controller.dart';
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
  bool _conflictFlash = false;

  @override
  void initState() {
    super.initState();
    // Listen for game completion or special events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameController>().addListener(_onGameChange);
    });
  }

  void _onGameChange() {
    final ctrl = context.read<GameController>();

    if (ctrl.isComplete) {
      // Short delay so the last cell can animate before navigating
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: ctrl,
                child: const ResultScreen(),
              ),
            ),
          );
        }
      });
      return;
    }

    // Alliance / conflict toasts
    if (ctrl.lastAllianceMsg != null) {
      _showToast(ctrl.lastAllianceMsg!, isGold: true);
    } else if (ctrl.lastWasConflict) {
      _showConflictFlash();
    }
  }

  void _showToast(String msg, {bool isGold = false}) {
    if (!mounted) return;
    setState(() => _toastMsg = msg);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  void _showConflictFlash() {
    if (!mounted) return;
    setState(() => _conflictFlash = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _conflictFlash = false);
    });
  }

  @override
  void dispose() {
    context.read<GameController>().removeListener(_onGameChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GameController>();
    final puzzle = ctrl.puzzle;
    if (puzzle == null) return const Scaffold();

    return Scaffold(
      backgroundColor: _conflictFlash
          ? AppTheme.conflictRed.withOpacity(0.08)
          : AppTheme.background,
      appBar: AppBar(
        title: Text(
          '${puzzle.difficulty.emoji} ${puzzle.difficulty.label}  '
          '${puzzle.size}×${puzzle.size}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
            onPressed: () => ctrl.loadPuzzle(puzzle.difficulty),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const ScoreBar(),
                // Progress indicator
                LinearProgressIndicator(
                  value: puzzle.correctCount / puzzle.totalCells,
                  backgroundColor: AppTheme.surfaceAlt,
                  color: AppTheme.correctGreen,
                  minHeight: 3,
                ),
                // Grid takes remaining space
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
            // Alliance / conflict toast
            if (_toastMsg != null)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: _Toast(message: _toastMsg!),
                ),
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
