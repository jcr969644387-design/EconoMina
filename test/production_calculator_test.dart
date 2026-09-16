import 'package:economina/calculators/production_calculator.dart';
import 'package:economina/models/mineral_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = ProductionCalculator();

  group('Producción e ingresos', () {
    test('calcula el metal contenido en cobre (lb)', () {
      final contained = calculator.containedMetal(
        tonnes: 2000000,
        grade: 0.8,
        conversionFactor: MineralType.cobre.conversionFactor,
      );
      expect(contained, closeTo(35273920, 1e-3));
    });

    test('calcula el metal contenido en oro (oz)', () {
      final contained = calculator.containedMetal(
        tonnes: 1000,
        grade: 2,
        conversionFactor: MineralType.oro.conversionFactor,
      );
      expect(contained, closeTo(64.3014, 1e-4));
    });

    test('calcula el metal recuperado', () {
      final recovered = calculator.recoveredMetal(
        containedMetal: 35273920,
        recoveryPct: 88,
      );
      expect(recovered, closeTo(31041049.6, 1e-3));
    });

    test('calcula ingresos, regalías y margen', () {
      final gross = calculator.grossRevenue(
        recoveredMetal: 31041049.6,
        price: 4,
      );
      expect(gross, closeTo(124164198.4, 1e-3));
      expect(
        calculator.royalty(grossRevenue: gross, royaltyPct: 3),
        closeTo(3724925.952, 1e-3),
      );
      final net = calculator.netRevenue(grossRevenue: gross, royaltyPct: 3);
      expect(net, closeTo(120439272.448, 1e-3));
      final margin = calculator.operatingMargin(
        netRevenue: net,
        operatingCost: 55e6,
      );
      expect(margin, closeTo(65439272.448, 1e-3));
      expect(
        calculator.marginPercent(netRevenue: net, margin: margin),
        closeTo(54.334, 1e-3),
      );
    });

    test('rechaza datos inválidos', () {
      expect(
        () => calculator.containedMetal(
          tonnes: -1,
          grade: 1,
          conversionFactor: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => calculator.recoveredMetal(containedMetal: 10, recoveryPct: 120),
        throwsArgumentError,
      );
    });
  });
}
