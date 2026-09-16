import 'package:economina/calculators/profitability_classifier.dart';
import 'package:economina/calculators/project_evaluator.dart';
import 'package:economina/models/profitability.dart';
import 'package:economina/models/scenario.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const classifier = ProfitabilityClassifier();

  group('Clasificación de rentabilidad', () {
    test('clasifica el VAN', () {
      expect(classifier.classifyNpv(1000), Profitability.atractivo);
      expect(classifier.classifyNpv(-1000), Profitability.noAtractivo);
      expect(
        classifier.classifyNpv(0.5, tolerance: 1),
        Profitability.indiferente,
      );
    });

    test('compara la TIR con la tasa de descuento', () {
      expect(classifier.classifyIrr(0.15, 0.10), Profitability.atractivo);
      expect(classifier.classifyIrr(0.10, 0.10), Profitability.indiferente);
      expect(classifier.classifyIrr(0.06, 0.10), Profitability.noAtractivo);
    });

    test('estima el riesgo del proyecto', () {
      expect(
        classifier.projectRisk(baseNpv: -1, pessimisticNpv: -5),
        RiskLevel.alto,
      );
      expect(
        classifier.projectRisk(baseNpv: 10, pessimisticNpv: -5),
        RiskLevel.medio,
      );
      expect(
        classifier.projectRisk(baseNpv: 10, pessimisticNpv: 5),
        RiskLevel.bajo,
      );
    });

    test('estima el riesgo de un punto', () {
      expect(
        classifier.pointRisk(
          npv: -1,
          initialInvestment: 100,
          discountRate: 0.1,
        ),
        RiskLevel.alto,
      );
      expect(
        classifier.pointRisk(npv: 5, initialInvestment: 100, discountRate: 0.1),
        RiskLevel.medio,
      );
      expect(
        classifier.pointRisk(
          npv: 50,
          initialInvestment: 100,
          discountRate: 0.1,
          irr: 0.25,
        ),
        RiskLevel.bajo,
      );
    });

    test('evalúa el proyecto base de forma integral', () {
      const evaluator = ProjectEvaluator();
      final evaluation = evaluator.evaluate(baseProject());
      expect(evaluation.npv, closeTo(50529702.22, 1));
      expect(evaluation.npvClass, Profitability.atractivo);
      expect(evaluation.irrClass, Profitability.atractivo);
      expect(evaluation.pessimisticNpv, closeTo(-137227066.64, 1));
      expect(evaluation.risk, RiskLevel.medio);

      final pessimistic = evaluator.evaluate(
        baseProject(),
        scenario: ScenarioType.pesimista,
      );
      expect(pessimistic.npvClass, Profitability.noAtractivo);
      expect(pessimistic.project.metalPrice, closeTo(3.6, 1e-12));
    });
  });
}
