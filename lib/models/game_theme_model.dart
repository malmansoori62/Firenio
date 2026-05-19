import 'package:flutter/material.dart';

class GameThemeModel {
  final String id;
  final String name;
  final String emoji;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color accent;
  final Color gridBorder;
  final int unlockLevel;   // 0 = free, >0 = unlock by reaching that level
  final int gemCost;       // 0 = not purchasable

  const GameThemeModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.accent,
    required this.gridBorder,
    this.unlockLevel = 0,
    this.gemCost = 0,
  });
}

const kThemes = <GameThemeModel>[
  GameThemeModel(
    id: 'desert',
    name: 'Desert',
    emoji: '🏜️',
    background:  Color(0xFF1A1208),
    surface:     Color(0xFF2A1F0E),
    surfaceAlt:  Color(0xFF3A2C18),
    accent:      Color(0xFFD4841A),
    gridBorder:  Color(0xFF8B6914),
    unlockLevel: 0,
  ),
  GameThemeModel(
    id: 'ocean',
    name: 'Ocean',
    emoji: '🌊',
    background:  Color(0xFF020D1A),
    surface:     Color(0xFF061829),
    surfaceAlt:  Color(0xFF0A2540),
    accent:      Color(0xFF00B4D8),
    gridBorder:  Color(0xFF0077B6),
    unlockLevel: 10,
  ),
  GameThemeModel(
    id: 'volcano',
    name: 'Volcano',
    emoji: '🌋',
    background:  Color(0xFF150402),
    surface:     Color(0xFF200806),
    surfaceAlt:  Color(0xFF350D08),
    accent:      Color(0xFFFF4500),
    gridBorder:  Color(0xFF8B1A00),
    unlockLevel: 30,
  ),
  GameThemeModel(
    id: 'space',
    name: 'Space',
    emoji: '🌌',
    background:  Color(0xFF03030F),
    surface:     Color(0xFF08082A),
    surfaceAlt:  Color(0xFF10103D),
    accent:      Color(0xFF9B5DE5),
    gridBorder:  Color(0xFF5A0EAD),
    unlockLevel: 60,
  ),
  GameThemeModel(
    id: 'castle',
    name: 'Castle',
    emoji: '🏯',
    background:  Color(0xFF0D0D0D),
    surface:     Color(0xFF1A1A1A),
    surfaceAlt:  Color(0xFF2C2C2C),
    accent:      Color(0xFFC0C0C0),
    gridBorder:  Color(0xFF666666),
    gemCost:     100,
  ),
];

GameThemeModel themeById(String id) =>
    kThemes.firstWhere((t) => t.id == id, orElse: () => kThemes.first);
