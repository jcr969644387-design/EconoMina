import 'package:economina/calculators/project_evaluator.dart';
import 'package:economina/calculators/sensitivity_calculator.dart';
import 'package:economina/models/sensitivity_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const calculator = SensitivityCalculator();
  const evaluator = ProjectEvaluator();

  group('Sensibilidad', () {
    test('analiza las ocho variables con cinco puntos', () {
      final results = calculator.analyzeAll(baseProject());
      expect(results, hasLength(SensitivityVariable.values.length));
      for (final result in results) {
        expect(result.isAvailable, isTrue, reason: result.variable.label);
        expect(result.points, hasLength(5));
      }
    });

    test('el punto sin variación reproduce el VAN base', () {
      final project = baseProject();
      final baseNpv = evaluator.quickNpv(project);
      for (final variable in SensitivityVariable.values) {
        final result = calculator.analyze(project, variable);
        final zero = result.points.firstWhere((point) => point.changePct == 0);
        expect(zero.npv, closeTo(baseNpv, 1), reason: variable.label);
      }
    });

    test('el VAN sube con el precio y baja con CAPEX, OPEX y la tasa', () {
      final project = baseProject();
      double npvAt(SensitivityVariable variable, int index) =>
          calculator.analyze(project, variable).points[index].npv;

      expect(
        npvAt(SensitivityVariable.precio, 4),
        greaterThan(npvAt(SensitivityVariable.precio, 0)),
      );
      expect(
        npvAt(SensitivityVariable.ley, 4),
        greaterThan(npvAt(SensitivityVariable.ley, 0)),
      );
      expect(
        npvAt(SensitivityVariable.capex, 4),
        lessThan(npvAt(SensitivityVariable.capex, 0)),
      );
      expect(
        npvAt(SensitivityVariable.opex, 4),
        lessThan(npvAt(SensitivityVariable.opex, 0)),
      );
      expect(
        npvAt(SensitivityVariable.tasaDescuento, 4),
        lessThan(npvAt(SensitivityVariable.tasaDescuento, 0)),
      );
    });

    test('una caída de 20 % en el precio vuelve negativo el VAN base', () {
      final result = calculator.analyze(
        baseProject(),
        SensitivityVariable.precio,
      );
      expect(result.points.first.changePct, -20);
      expect(result.points.first.npv, lessThan(0));
      expect(result.npvSwing, greaterThan(0));
    });

    test('la recuperación sensibilizada no supera 100 %', () {
      final project = baseProject().copyWith(recoveryPct: 95);
      final varied = calculator.vary(
        project,
        SensitivityVariable.recuperacion,
        20,
      );
      expect(varied.recoveryPct, 100);
    });

    test('la ley de corte no se analiza si la ley promedio no la supera', () {
      final project = baseProject().copyWith(averageGrade: 0.3);
      final result = calculator.analyze(project, SensitivityVariable.leyCorte);
      expect(result.isAvailable, isFalse);
      expect(result.message, isNotNull);
    });

    test('subir la ley de corte reduce el tonelaje y sube la ley media', () {
      final project = baseProject();
      final varied = calculator.vary(project, SensitivityVariable.leyCorte, 20);
      expect(varied.reservesTonnes, lessThan(project.reservesTonnes));
      expect(varied.averageGrade, greaterThan(project.averageGrade));
    });
  });
}
