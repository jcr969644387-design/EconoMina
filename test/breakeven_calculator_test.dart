import 'package:economina/calculators/breakeven_calculator.dart';
import 'package:economina/calculators/project_evaluator.dart';
import 'package:economina/services/case_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const calculator = BreakevenCalculator();
  const evaluator = ProjectEvaluator();

  group('Puntos de equilibrio (VAN = 0)', () {
    test('calcula el precio de equilibrio del proyecto base', () {
      final project = baseProject();
      final result = calculator.price(project);
      expect(result.isAvailable, isTrue);
      expect(result.value, closeTo(3.726884, 1e-5));
      expect(result.safetyMarginPct, closeTo(6.8279, 1e-3));
      final atBreakeven = evaluator.quickNpv(
        project.copyWith(metalPrice: result.value),
      );
      expect(atBreakeven.abs(), lessThan(100));
    });

    test('calcula la ley de equilibrio del proyecto base', () {
      final result = calculator.grade(baseProject());
      expect(result.value, closeTo(0.745377, 1e-5));
      // Precio y ley afectan al ingreso de la misma forma.
      expect(result.safetyMarginPct, closeTo(6.8279, 1e-3));
    });

    test('un proyecto con VAN negativo necesita un precio mayor', () {
      final project = const CaseRepository()
          .byId('caso-2-van-negativo')!
          .project;
      final result = calculator.price(project);
      expect(result.value, closeTo(2100.09, 0.05));
      expect(result.value, greaterThan(project.metalPrice));
      expect(result.safetyMarginPct, closeTo(-5.004, 1e-2));
    });

    test('el margen de seguridad es nulo si no hay equilibrio', () {
      const result = BreakevenResult(
        value: null,
        baseValue: 4,
        message: 'Sin equilibrio',
      );
      expect(result.isAvailable, isFalse);
      expect(result.safetyMarginPct, isNull);
    });
  });
}
