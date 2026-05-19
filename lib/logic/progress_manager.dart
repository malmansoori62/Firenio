import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/difficulty.dart';
import '../models/leaderboard_entry.dart';

class ProgressManager extends ChangeNotifier {
  static const _starsKey       = 'stars';
  static const _gemsKey        = 'gems';
  static const _hintsKey       = 'global_hints';
  static const _streakKey      = 'streak';
  static const _totalLevelsKey = 'total_completed';
  static const _unlockedKey    = 'unlocked_themes';
  static const _boardKey       = 'leaderboard';
  static String _completedKey(Difficulty d) => 'completed_${d.name}';
  static String _hsKey(Difficulty d, int lvl) => 'hs_${d.name}_$lvl';

  int _stars   = 0;
  int _gems    = 0;
  int _hints   = 3;
  int _streak  = 0;
  int _totalCompleted = 0;
  Set<String> _unlockedThemes = {'desert'};
  Map<String, Set<int>> _completed = {};
  Map<String, int> _highScores = {};
  List<LeaderboardEntry> _board = [];

  int             get stars           => _stars;
  int             get gems            => _gems;
  int             get hints           => _hints;
  int             get streak          => _streak;
  int             get totalCompleted  => _totalCompleted;
  Set<String>     get unlockedThemes  => Set.unmodifiable(_unlockedThemes);
  List<LeaderboardEntry> get leaderboard => List.unmodifiable(
    [..._board]..sort((a, b) => b.score.compareTo(a.score)),
  );

  // ---------------------------------------------------------------------------
  // Load / Save
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _stars          = p.getInt(_starsKey)  ?? 0;
    _gems           = p.getInt(_gemsKey)   ?? 0;
    _hints          = p.getInt(_hintsKey)  ?? 3;
    _streak         = p.getInt(_streakKey) ?? 0;
    _totalCompleted = p.getInt(_totalLevelsKey) ?? 0;

    final unlockedRaw = p.getStringList(_unlockedKey) ?? ['desert'];
    _unlockedThemes = Set<String>.from(unlockedRaw);

    for (final d in Difficulty.values) {
      final raw = p.getStringList(_completedKey(d)) ?? [];
      _completed[d.name] = raw.map(int.parse).toSet();
    }

    // Load high scores for all difficulties + 20 levels each
    for (final d in Difficulty.values) {
      for (int lvl = 1; lvl <= 20; lvl++) {
        final key = _hsKey(d, lvl);
        final hs = p.getInt(key);
        if (hs != null) _highScores[key] = hs;
      }
    }

    final boardRaw = p.getString(_boardKey);
    if (boardRaw != null) {
      try {
        _board = LeaderboardEntry.decodeList(boardRaw);
      } catch (_) {
        _board = [];
      }
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Level completion
  // ---------------------------------------------------------------------------

  Future<void> completeLevel({
    required Difficulty difficulty,
    required int levelNumber,
    required int score,
    required int mistakes,
    required Duration elapsed,
    required String playerName,
  }) async {
    final p = await SharedPreferences.getInstance();

    // Mark level complete
    _completed.putIfAbsent(difficulty.name, () => {}).add(levelNumber);
    await p.setStringList(
      _completedKey(difficulty),
      _completed[difficulty.name]!.map((n) => '$n').toList(),
    );

    // Update high score
    final hsKey = _hsKey(difficulty, levelNumber);
    final prev = p.getInt(hsKey) ?? 0;
    if (score > prev) {
      _highScores[hsKey] = score;
      await p.setInt(hsKey, score);
    }

    // Stars reward (1–3 per level)
    final stars = _starsForMistakes(mistakes);
    _stars += stars;
    await p.setInt(_starsKey, _stars);

    // Hints: every 5 completed levels = +1 hint
    _totalCompleted++;
    await p.setInt(_totalLevelsKey, _totalCompleted);
    if (_totalCompleted % 5 == 0) {
      _hints++;
      await p.setInt(_hintsKey, _hints);
    }

    // Streak
    if (mistakes <= 2) {
      _streak++;
    } else {
      _streak = 0;
    }
    await p.setInt(_streakKey, _streak);

    // Leaderboard
    _board.add(LeaderboardEntry(
      playerName:  playerName,
      score:       score,
      difficulty:  difficulty,
      levelNumber: levelNumber,
      elapsed:     elapsed,
      date:        DateTime.now(),
    ));
    if (_board.length > 100) _board.removeAt(0);
    await p.setString(_boardKey, LeaderboardEntry.encodeList(_board));

    // Unlock themes by total completed
    _checkThemeUnlocks();
    await p.setStringList(_unlockedKey, _unlockedThemes.toList());

    notifyListeners();
  }

  void _checkThemeUnlocks() {
    if (_totalCompleted >= 10) _unlockedThemes.add('ocean');
    if (_totalCompleted >= 30) _unlockedThemes.add('volcano');
    if (_totalCompleted >= 60) _unlockedThemes.add('space');
  }

  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  bool isThemeUnlocked(String themeId) => _unlockedThemes.contains(themeId);

  Future<bool> buyThemeWithGems(String themeId, int cost) async {
    if (_gems < cost) return false;
    _gems -= cost;
    _unlockedThemes.add(themeId);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_gemsKey, _gems);
    await p.setStringList(_unlockedKey, _unlockedThemes.toList());
    notifyListeners();
    return true;
  }

  Future<bool> buyHintsWithStars(int count, int starCost) async {
    if (_stars < starCost) return false;
    _stars -= starCost;
    _hints += count;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_starsKey, _stars);
    await p.setInt(_hintsKey, _hints);
    notifyListeners();
    return true;
  }

  Future<void> addGems(int amount) async {
    _gems += amount;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_gemsKey, _gems);
    notifyListeners();
  }

  Future<void> consumeHint() async {
    if (_hints <= 0) return;
    _hints--;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_hintsKey, _hints);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  bool isCompleted(Difficulty d, int level) =>
      _completed[d.name]?.contains(level) ?? false;

  int? highScore(Difficulty d, int level) =>
      _highScores[_hsKey(d, level)];

  int _starsForMistakes(int mistakes) {
    if (mistakes == 0) return 3;
    if (mistakes <= 2) return 2;
    return 1;
  }

  int streakMultiplierPercent() {
    if (_streak >= 5) return 200;
    if (_streak >= 3) return 150;
    return 100;
  }
}
