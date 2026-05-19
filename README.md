# Elements Grid

A Sudoku-style mobile puzzle game built with Flutter.  
Instead of numbers, every row, column, and box must contain each **nature element** exactly once.

---

## Elements

| Symbol | Element   | Color  |
|--------|-----------|--------|
| 🔥     | Fire      | Red    |
| 💧     | Water     | Blue   |
| 🌿     | Earth     | Green  |
| ⚡     | Lightning | Yellow |
| 🌪️    | Wind      | Gray   |
| ❄️     | Ice       | Cyan   |

---

## Conflict & Alliance System

| Pair              | Effect              |
|-------------------|---------------------|
| 🔥 + 💧           | ⚠️ Conflict (warning) |
| 🔥 + ⚡           | ✨ Alliance (+20 pts) |
| 💧 + ❄️           | ✨ Alliance (+20 pts) |
| 🌿 + 🌪️          | ✨ Alliance (+20 pts) |

---

## Grid Sizes

| Difficulty | Grid  | Elements |
|------------|-------|----------|
| 🌱 Beginner | 4×4  | 4 (🔥💧🌿⚡) |
| ⚔️ Medium   | 5×5  | 5 (🔥💧🌿⚡🌪️) |
| 🔥 Hard     | 6×6  | 6 (all)  |

---

## Scoring

| Event                    | Points |
|--------------------------|--------|
| Correct cell placed      | +10    |
| Combo (3 in a row)       | +50    |
| Full row/col completed   | +100   |
| Fast completion (<60s)   | +200   |
| Alliance bonus           | +20    |
| Wrong placement          | −20    |
| Hint used                | −50    |

---

## Roadmap

- **Phase 1** ✅ — Core puzzle engine, scoring, conflict/alliance system
- **Phase 2** — Hint system polish, daily puzzles, visual themes, streak system
- **Phase 3** — Shop (gems/stars), global leaderboard, Ramadan/Eid events

---

## Setup

1. Install [Flutter](https://flutter.dev/docs/get-started/install)
2. Clone this repo
3. Scaffold platform files (Android/iOS):
   ```bash
   flutter create --org com.firenio .
   ```
4. Restore the game's main.dart (flutter create overwrites it):
   ```bash
   git restore lib/main.dart
   ```
5. Install dependencies:
   ```bash
   flutter pub get
   ```
6. Run:
   ```bash
   flutter run
   ```

---

## Project Structure

```
lib/
├── main.dart               — app entry, Provider setup
├── models/
│   ├── element_type.dart   — Element enum + conflict/alliance logic
│   ├── difficulty.dart     — Difficulty enum (grid size, removal rate)
│   ├── cell.dart           — Cell data class
│   └── puzzle.dart         — Puzzle model
├── logic/
│   ├── puzzle_generator.dart — Backtracking Sudoku generator
│   └── game_controller.dart  — Game state (ChangeNotifier)
├── screens/
│   ├── splash_screen.dart
│   ├── main_menu_screen.dart
│   ├── level_selection_screen.dart
│   ├── game_screen.dart
│   └── result_screen.dart
├── widgets/
│   ├── game_grid.dart      — Full puzzle grid
│   ├── cell_widget.dart    — Single cell (conflict/alliance visuals)
│   ├── element_palette.dart — Bottom element picker
│   └── score_bar.dart      — Top score/timer/hints bar
└── themes/
    └── app_theme.dart      — Colors, text styles
```
