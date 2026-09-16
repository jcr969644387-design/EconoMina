import 'package:economina/calculators/project_evaluator.dart';
import 'package:economina/models/scenario.dart';
import 'package:economina/services/case_repository.dart';
import 'package:economina/services/quiz_repository.dart';
import 'package:economina/services/validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Casos empresariales', () {
    const repository = CaseRepository();
    const evaluator = ProjectEvaluator();
    const validator = ValidationService();

    test('hay al menos seis casos con identificador único', () {
      final cases = repository.all();
      expect(cases.length, greaterThanOrEqualTo(6));
      expect(cases.map((item) => item.id).toSet(), hasLength(cases.length));
      expect(repository.byId(cases.first.id), same(cases.first));
      expect(repository.byId('no-existe'), isNull);
    });

    test('cada caso tiene contenido educativo completo y datos válidos', () {
      for (final item in repository.all()) {
        expect(item.assumptions, isNotEmpty, reason: item.id);
        expect(item.questions, isNotEmpty, reason: item.id);
        expect(item.expectedCalculations, isNotEmpty, reason: item.id);
        expect(item.risks, isNotEmpty, reason: item.id);
        expect(item.interpretation, isNotEmpty, reason: item.id);
        expect(item.educationalDecision, isNotEmpty, reason: item.id);
        expect(item.explanation, isNotEmpty, reason: item.id);
        expect(
          validator.validateProject(item.project).isValid,
          isTrue,
          reason: item.id,
        );
      }
    });

    test('los resultados del simulador coinciden con lo esperado', () {
      for (final item in repository.all()) {
        final evaluation = evaluator.evaluate(item.project);
        expect(
          evaluation.npv > 0,
          item.expectedNpvPositive,
          reason: '${item.id}: VAN',
        );
        final irr = evaluation.irr.value;
        final irrAbove = irr != null && irr > evaluation.discountRate;
        expect(irrAbove, item.expectedIrrAboveRate, reason: '${item.id}: TIR');
        final expectedPessimistic = item.expectedPessimisticNpvPositive;
        if (expectedPessimistic != null) {
          final pessimistic = evaluator.evaluate(
            item.project,
            scenario: ScenarioType.pesimista,
          );
          expect(
            pessimistic.npv > 0,
            expectedPessimistic,
            reason: '${item.id}: VAN pesimista',
          );
        }
      }
    });

    test('valores de referencia de casos calibrados', () {
      final rentable = evaluator.evaluate(
        repository.byId('caso-1-rentable')!.project,
      );
      expect(rentable.npv / 1e6, closeTo(299.58, 0.05));
      expect(rentable.irr.value! * 100, closeTo(27.46, 0.05));

      final negativo = evaluator.evaluate(
        repository.byId('caso-2-van-negativo')!.project,
      );
      expect(negativo.npv / 1e6, closeTo(-31.79, 0.05));
      expect(negativo.irr.value! * 100, closeTo(6.46, 0.05));
    });
  });

  group('Evaluación práctica', () {
    test('las preguntas están bien formadas', () {
      final questions = const QuizRepository().all();
      expect(questions.length, greaterThanOrEqualTo(15));
      expect(questions.where((q) => q.isExercise), isNotEmpty);
      for (final question in questions) {
        expect(question.options.length, greaterThanOrEqualTo(2));
        expect(
          question.correctIndex,
          inInclusiveRange(0, question.options.length - 1),
        );
        expect(question.explanation, isNotEmpty);
        expect(
          question.options.toSet(),
          hasLength(question.options.length),
          reason: question.prompt,
        );
      }
    });
  });
}
