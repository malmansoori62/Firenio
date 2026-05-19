import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/progress_manager.dart';
import '../models/difficulty.dart';
import '../models/leaderboard_entry.dart';
import '../themes/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressManager>();
    final entries  = progress.leaderboard;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Leaderboard')),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'No scores yet.\nComplete a level to appear here!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (_, i) => _EntryRow(rank: i + 1, entry: entries[i]),
            ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _EntryRow({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final medalEmoji = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '  $rank',
    };

    final elapsed = entry.elapsed;
    final timeStr =
        '${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}'
        ':${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: rank <= 3 ? AppTheme.accentGold.withOpacity(0.08) : AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: rank <= 3
            ? Border.all(
                color: AppTheme.accentGold.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              medalEmoji,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${entry.difficulty.emoji} ${entry.difficulty.label}  '
                  'Lvl ${entry.levelNumber}  ⏱ $timeStr',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
