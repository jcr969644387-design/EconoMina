import 'package:economina/calculators/cash_flow_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const calculator = CashFlowCalculator();

  group('Flujo de caja', () {
    test('construye el año 0 con la inversión y n años de operación', () {
      final project = baseProject();
      final rows = calculator.build(project);
      expect(rows, hasLength(11));
      expect(rows.first.period, 0);
      expect(rows.first.netFlow, closeTo(-340e6, 1e-3));
      expect(rows.first.discountFactor, 1);
    });

    test('calcula el flujo anual y el cierre en el último año', () {
      final rows = calculator.build(baseProject());
      expect(rows[1].netRevenue, closeTo(120439272.448, 1e-2));
      expect(rows[1].opex, closeTo(55e6, 1e-3));
      expect(rows[1].netFlow, closeTo(65439272.448, 1e-2));
      expect(rows[1].closure, 0);
      expect(rows.last.closure, closeTo(30e6, 1e-6));
      expect(rows.last.netFlow, closeTo(35439272.448, 1e-2));
      expect(rows[1].discountFactor, closeTo(1 / 1.1, 1e-12));
    });

    test('resume totales y periodo de recuperación', () {
      final rows = calculator.build(baseProject());
      final summary = calculator.summarize(rows);
      expect(summary.operatingYears, 10);
      // −340 + 10 × 65.439 − 30 ≈ 284.39 M.
      expect(summary.totalNetFlow, closeTo(284392724.48, 1));
      // Acumulado: año 5 = −340 + 5 × 65.44 < 0; año 6 > 0.
      expect(summary.paybackPeriod, 6);
      expect(summary.marginPct, closeTo(54.334, 1e-3));
    });

    test('limita los años a las reservas disponibles', () {
      final project = baseProject().copyWith(reservesTonnes: 9000000);
      final rows = calculator.build(project);
      expect(calculator.operatingYears(project), 5);
      expect(rows, hasLength(6));
      expect(rows.last.tonnes, closeTo(1000000, 1e-6));
    });

    test('aplica impuestos simplificados cuando se activan', () {
      final project = baseProject().copyWith(taxEnabled: true);
      final rows = calculator.build(project);
      // (65.439 M − 34 M de depreciación) × 29.5 %.
      expect(rows[1].taxes, closeTo((65439272.448 - 34e6) * 0.295, 1e-2));
      expect(rows[1].netFlow, lessThan(65439272.448));
    });
  });
}
