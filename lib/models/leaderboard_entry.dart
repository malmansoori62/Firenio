import 'dart:convert';
import '../models/difficulty.dart';

class LeaderboardEntry {
  final String playerName;
  final int score;
  final Difficulty difficulty;
  final int levelNumber;
  final Duration elapsed;
  final DateTime date;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.difficulty,
    required this.levelNumber,
    required this.elapsed,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'name':       playerName,
    'score':      score,
    'difficulty': difficulty.name,
    'level':      levelNumber,
    'elapsedSec': elapsed.inSeconds,
    'date':       date.toIso8601String(),
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) =>
      LeaderboardEntry(
        playerName: j['name'] as String,
        score:      j['score'] as int,
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == j['difficulty'],
          orElse: () => Difficulty.beginner,
        ),
        levelNumber: j['level'] as int,
        elapsed:    Duration(seconds: j['elapsedSec'] as int),
        date:       DateTime.parse(j['date'] as String),
      );

  static List<LeaderboardEntry> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String encodeList(List<LeaderboardEntry> entries) =>
      jsonEncode(entries.map((e) => e.toJson()).toList());
}
