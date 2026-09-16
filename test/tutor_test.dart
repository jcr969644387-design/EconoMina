import 'package:economina/services/tutor/rule_based_tutor.dart';
import 'package:economina/services/tutor/tutor_engine.dart';
import 'package:economina/services/tutor/tutor_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tutor = RuleBasedTutor();

  group('Tutor económico local', () {
    test('funciona sin conexión e implementa la interfaz común', () {
      const TutorEngine engine = tutor;
      expect(engine.requiresNetwork, isFalse);
      expect(engine.name, isNotEmpty);
    });

    test('normaliza tildes, mayúsculas y signos', () {
      expect(RuleBasedTutor.normalize('¿Qué es el VAN?'), 'que es el van');
    });

    test('detecta los temas principales', () {
      expect(tutor.detect('¿Qué es el VAN?')?.topic, TutorTopic.van);
      expect(
        tutor.detect('diferencia entre VAN y TIR')?.topic,
        TutorTopic.vanVsTir,
      );
      expect(
        tutor.detect('¿qué es la ley de corte?')?.topic,
        TutorTopic.leyCorte,
      );
      expect(
        tutor.detect('Diferencia entre CAPEX y OPEX')?.topic,
        TutorTopic.capexOpex,
      );
      expect(tutor.detect('xyz'), isNull);
    });

    test('cada tema se reconoce con su propio título', () {
      for (final topic in TutorTopic.values) {
        expect(tutor.detect(topic.title)?.topic, topic, reason: topic.title);
      }
    });

    test('contextualiza la respuesta con el proyecto activo', () async {
      const context = TutorContext(
        projectName: 'Proyecto de prueba',
        currency: 'USD',
        npv: -2000000,
        irr: 0.06,
        discountRate: 0.10,
        marginPct: 20,
        averageGrade: 0.8,
        gradeUnit: '%',
        cutoffGrade: 0.4,
      );
      final answer = await tutor.answer(
        const TutorQuery(text: 'explícame el VAN', context: context),
      );
      expect(answer.topic, TutorTopic.van);
      expect(answer.contextNote, contains('Proyecto de prueba'));
      expect(answer.contextNote, contains('no alcanza'));
      expect(answer.keyPoints, isNotEmpty);
    });

    test('responde con sugerencias si no reconoce la pregunta', () {
      final answer = tutor.answerSync(const TutorQuery(text: 'hola'));
      expect(answer.topic, isNull);
      expect(answer.suggestions, isNotEmpty);
    });
  });
}
