import 'package:flutter/material.dart';

enum ElementType { fire, water, earth, lightning, wind, ice }

extension ElementTypeX on ElementType {
  String get emoji => switch (this) {
    ElementType.fire      => '🔥',
    ElementType.water     => '💧',
    ElementType.earth     => '🌿',
    ElementType.lightning => '⚡',
    ElementType.wind      => '🌪️',
    ElementType.ice       => '❄️',
  };

  String get label => switch (this) {
    ElementType.fire      => 'Fire',
    ElementType.water     => 'Water',
    ElementType.earth     => 'Earth',
    ElementType.lightning => 'Lightning',
    ElementType.wind      => 'Wind',
    ElementType.ice       => 'Ice',
  };

  Color get color => switch (this) {
    ElementType.fire      => const Color(0xFFE53935),
    ElementType.water     => const Color(0xFF1E88E5),
    ElementType.earth     => const Color(0xFF43A047),
    ElementType.lightning => const Color(0xFFFDD835),
    ElementType.wind      => const Color(0xFF90A4AE),
    ElementType.ice       => const Color(0xFF00BCD4),
  };
}

enum ElementRelation { none, conflict, alliance }

ElementRelation elementRelation(ElementType a, ElementType b) {
  final pair = {a, b};
  if (pair.containsAll([ElementType.fire, ElementType.water])) {
    return ElementRelation.conflict;
  }
  if (pair.containsAll([ElementType.fire, ElementType.lightning]) ||
      pair.containsAll([ElementType.water, ElementType.ice]) ||
      pair.containsAll([ElementType.earth, ElementType.wind])) {
    return ElementRelation.alliance;
  }
  return ElementRelation.none;
}
