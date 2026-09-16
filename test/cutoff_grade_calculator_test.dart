import 'package:economina/calculators/cutoff_grade_calculator.dart';
import 'package:economina/models/cutoff_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const calculator = CutoffGradeCalculator();

  CutoffInput input({
    double price = 4,
    double recovery = 90,
    CutoffMethod method = CutoffMethod.equilibrio,
  }) {
    return CutoffInput(
      metalPrice: price,
      recoveryPct: recovery,
      miningCost: 5,
      processingCost: 10,
      generalCost: 3,
      royaltyPct: 0,
      sellingCost: 0,
      payablePct: 100,
      conversionFactor: 22.0462,
      gradeUnit: '%',
      metalUnit: 'lb',
      method: method,
    );
  }

  group('Ley de corte', () {
    test('aplica la fórmula C / (Pn × R × F)', () {
      final result = calculator.calculate(input());
      // 18 / (4 × 0.9 × 22.0462) = 0.226796...
      expect(result.costPerTonne, 18);
      expect(result.cutoffGrade, closeTo(18 / (4 * 0.9 * 22.0462), 1e-12));
    });

    test('la ley de corte marginal excluye el costo de mina', () {
      final marginal = calculator.calculate(
        input(method: CutoffMethod.marginal),
      );
      final breakEven = calculator.calculate(input());
      expect(marginal.costPerTonne, 13);
      expect(marginal.cutoffGrade, lessThan(breakEven.cutoffGrade));
    });

    test('calcula la ley de corte del proyecto base', () {
      final project = baseProject();
      final result = calculator.calculate(calculator.fromProject(project));
      // (7 + 9 + 11.5) / (4 × 0.97 × 0.88 × 22.0462) ≈ 0.36533 %.
      expect(result.cutoffGrade, closeTo(0.365329, 1e-5));
      expect(result.cutoffGrade, lessThan(project.averageGrade));
      final marginal = calculator.calculate(
        calculator.fromProject(project, method: CutoffMethod.marginal),
      );
      expect(marginal.cutoffGrade, closeTo(0.272336, 1e-5));
    });

    test('sube con los costos y baja con precio y recuperación', () {
      final rows = calculator.sensitivity(input());
      final low = rows.first;
      final high = rows.last;
      expect(high.byPrice, lessThan(low.byPrice));
      expect(high.byRecovery, lessThan(low.byRecovery));
      expect(high.byCost, greaterThan(low.byCost));
    });

    test('rechaza datos que producirían divisiones entre cero', () {
      expect(() => calculator.calculate(input(price: 0)), throwsArgumentError);
      expect(
        () => calculator.calculate(input(recovery: 0)),
        throwsArgumentError,
      );
      expect(
        () => calculator.calculate(input(recovery: 101)),
        throwsArgumentError,
      );
    });
  });
}
