import 'package:flutter_test/flutter_test.dart';
import 'package:elements_grid/models/element_type.dart';

void main() {
  group('elementRelation', () {
    test('fire vs water is conflict', () {
      expect(
        elementRelation(ElementType.fire, ElementType.water),
        ElementRelation.conflict,
      );
      expect(
        elementRelation(ElementType.water, ElementType.fire),
        ElementRelation.conflict,
      );
    });

    test('fire vs lightning is alliance', () {
      expect(
        elementRelation(ElementType.fire, ElementType.lightning),
        ElementRelation.alliance,
      );
      expect(
        elementRelation(ElementType.lightning, ElementType.fire),
        ElementRelation.alliance,
      );
    });

    test('water vs ice is alliance', () {
      expect(
        elementRelation(ElementType.water, ElementType.ice),
        ElementRelation.alliance,
      );
      expect(
        elementRelation(ElementType.ice, ElementType.water),
        ElementRelation.alliance,
      );
    });

    test('earth vs wind is alliance', () {
      expect(
        elementRelation(ElementType.earth, ElementType.wind),
        ElementRelation.alliance,
      );
      expect(
        elementRelation(ElementType.wind, ElementType.earth),
        ElementRelation.alliance,
      );
    });

    test('unrelated pairs return none', () {
      expect(elementRelation(ElementType.fire, ElementType.earth), ElementRelation.none);
      expect(elementRelation(ElementType.fire, ElementType.wind), ElementRelation.none);
      expect(elementRelation(ElementType.fire, ElementType.ice), ElementRelation.none);
      expect(elementRelation(ElementType.water, ElementType.earth), ElementRelation.none);
      expect(elementRelation(ElementType.water, ElementType.wind), ElementRelation.none);
      expect(elementRelation(ElementType.water, ElementType.lightning), ElementRelation.none);
      expect(elementRelation(ElementType.earth, ElementType.ice), ElementRelation.none);
      expect(elementRelation(ElementType.lightning, ElementType.wind), ElementRelation.none);
    });

    test('same element returns none', () {
      for (final e in ElementType.values) {
        expect(elementRelation(e, e), ElementRelation.none);
      }
    });
  });
}
