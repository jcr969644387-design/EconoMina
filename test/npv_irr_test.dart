import 'package:economina/calculators/cash_flow_calculator.dart';
import 'package:economina/calculators/irr_calculator.dart';
import 'package:economina/calculators/npv_calculator.dart';
import 'package:economina/models/irr_result.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const npvCalculator = NpvCalculator();
  const irrCalculator = IrrCalculator();

  group('VAN', () {
    test('calcula el VAN con la fórmula Σ FCt/(1+r)^t − I0', () {
      final value = npvCalculator.npv(
        initialInvestment: 1000,
        flows: [500, 500, 500],
        rate: 0.10,
      );
      expect(value, closeTo(243.4260, 1e-4));
      expect(
        npvCalculator.npvFromSeries([-1000, 500, 500, 500], 0.10),
        closeTo(value, 1e-9),
      );
    });

    test('con tasa 0 equivale a la suma de flujos', () {
      expect(npvCalculator.npvFromSeries([-100, 60, 60], 0), closeTo(20, 1e-9));
    });

    test('calcula el VAN del proyecto base', () {
      const cashFlow = CashFlowCalculator();
      final flows = cashFlow.netFlows(cashFlow.build(baseProject()));
      expect(npvCalculator.npvFromSeries(flows, 0.10), closeTo(50529702.22, 1));
    });

    test('rechaza tasas menores o iguales a −100 %', () {
      expect(() => npvCalculator.presentValue(100, -1, 1), throwsArgumentError);
    });
  });

  group('TIR', () {
    test('converge en un flujo convencional', () {
      final result = irrCalculator.calculate([-1000, 500, 500, 500]);
      expect(result.status, IrrStatus.converged);
      expect(result.value, closeTo(0.233752, 1e-5));
      expect(
        npvCalculator.npvFromSeries([-1000, 500, 500, 500], result.value!),
        closeTo(0, 1e-6),
      );
    });

    test('calcula la TIR del proyecto base', () {
      const cashFlow = CashFlowCalculator();
      final flows = cashFlow.netFlows(cashFlow.build(baseProject()));
      final result = irrCalculator.calculate(flows, referenceRate: 0.10);
      expect(result.isValid, isTrue);
      expect(result.value, closeTo(0.134731, 1e-5));
    });

    test('detecta la falta de cambio de signo', () {
      final result = irrCalculator.calculate([100, 50, 50]);
      expect(result.status, IrrStatus.noSignChange);
      expect(result.isValid, isFalse);
      expect(result.value, isNull);
    });

    test('informa cuando la TIR no converge', () {
      // VAN = 100 − 300x + 250x² > 0 para todo x: no existe TIR.
      final result = irrCalculator.calculate([100, -300, 250]);
      expect(result.status, IrrStatus.notFound);
      expect(result.isValid, isFalse);
      expect(result.message, contains('no convergió'));
    });

    test('detecta varias TIR y elige la más cercana a la tasa', () {
      // Raíces en 10 % y 20 %.
      final result = irrCalculator.calculate([
        -100,
        230,
        -132,
      ], referenceRate: 0.19);
      expect(result.hasMultipleRoots, isTrue);
      expect(result.roots, hasLength(2));
      expect(result.value, closeTo(0.20, 1e-6));
    });

    test('necesita al menos dos periodos', () {
      final result = irrCalculator.calculate([-100]);
      expect(result.status, IrrStatus.notFound);
    });
  });
}
