enum Difficulty { beginner, medium, hard }

extension DifficultyX on Difficulty {
  String get label => switch (this) {
    Difficulty.beginner => 'Beginner',
    Difficulty.medium   => 'Medium',
    Difficulty.hard     => 'Hard',
  };

  String get emoji => switch (this) {
    Difficulty.beginner => '🌱',
    Difficulty.medium   => '⚔️',
    Difficulty.hard     => '🔥',
  };

  int get gridSize => switch (this) {
    Difficulty.beginner => 4,
    Difficulty.medium   => 5,
    Difficulty.hard     => 6,
  };

  // Fraction of cells removed to form the puzzle (rest are given/pre-filled)
  double get removalRate => switch (this) {
    Difficulty.beginner => 0.44,  // ~7 of 16 removed
    Difficulty.medium   => 0.44,  // ~11 of 25 removed
    Difficulty.hard     => 0.50,  // ~18 of 36 removed
  };

  // Box dimensions (rows × cols per box). (0,0) = no box constraint.
  (int, int) get boxDimensions => switch (this) {
    Difficulty.beginner => (2, 2),  // four 2×2 boxes
    Difficulty.medium   => (0, 0),  // 5×5 has no clean box factoring
    Difficulty.hard     => (2, 3),  // six 2×3 boxes
  };
}
