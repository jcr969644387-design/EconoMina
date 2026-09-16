import 'package:economina/calculators/cost_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const calculator = CostCalculator();

  group('Costos', () {
    test('agrupa costos variables, fijos e inversión', () {
      expect(simpleCosts.variableUnitCost, closeTo(10, 1e-9));
      expect(simpleCosts.miningUnitCost, closeTo(5, 1e-9));
      expect(simpleCosts.annualFixedCost, closeTo(100, 1e-9));
      expect(simpleCosts.initialInvestment, closeTo(1200, 1e-9));
    });

    test('calcula el OPEX anual y el costo total anual', () {
      // OPEX = 10 × 100 + 100 = 1100.
      expect(
        calculator.annualOperatingCost(simpleCosts, 100),
        closeTo(1100, 1e-9),
      );
      // Costo total = 1100 + (1200 + 100) / 5 = 1360.
      expect(
        calculator.totalAnnualCost(simpleCosts, 100, 5),
        closeTo(1360, 1e-9),
      );
      expect(
        calculator.totalOperatingCost(simpleCosts, 100, 5),
        closeTo(5500, 1e-9),
      );
    });

    test('calcula el costo total del proyecto base', () {
      final project = baseProject();
      // OPEX = 18.5 × 2 000 000 + 18 000 000 = 55 000 000.
      expect(
        calculator.annualOperatingCost(
          project.costs,
          project.annualProductionTonnes,
        ),
        closeTo(55e6, 1e-3),
      );
      // Costo total anual = 55 M + (340 M + 30 M) / 10 = 92 M.
      expect(
        calculator.totalAnnualCost(
          project.costs,
          project.annualProductionTonnes,
          10,
        ),
        closeTo(92e6, 1e-3),
      );
    });

    test('calcula el costo unitario', () {
      expect(calculator.unitCost(simpleCosts, 100), closeTo(11, 1e-9));
      final project = baseProject();
      expect(
        calculator.unitCost(project.costs, project.annualProductionTonnes),
        closeTo(27.5, 1e-9),
      );
    });

    test('calcula el costo por unidad de metal', () {
      final project = baseProject();
      expect(
        calculator.costPerMetalUnit(
          project.costs,
          project.annualProductionTonnes,
          31041049.6,
        ),
        closeTo(1.77185, 1e-4),
      );
    });

    test('la distribución suma 100 %', () {
      final items = calculator.distribution(simpleCosts, 100);
      final total = items.fold<double>(0, (sum, item) => sum + item.percent);
      expect(total, closeTo(100, 1e-9));
      expect(items.where((item) => item.isFixed), hasLength(2));
    });

    test('evita divisiones entre cero', () {
      expect(() => calculator.unitCost(simpleCosts, 0), throwsArgumentError);
      expect(
        () => calculator.costPerMetalUnit(simpleCosts, 100, 0),
        throwsArgumentError,
      );
      expect(
        () => calculator.totalAnnualCost(simpleCosts, 100, 0),
        throwsArgumentError,
      );
    });
  });
}
