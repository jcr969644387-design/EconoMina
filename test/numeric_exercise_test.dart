import 'package:economina/models/numeric_exercise.dart';
import 'package:economina/services/numeric_exercise_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ejercicios numéricos', () {
    test('la misma semilla genera los mismos ejercicios', () {
      final first = NumericExerciseGenerator(seed: 7).generate();
      final second = NumericExerciseGenerator(seed: 7).generate();
      expect(first, hasLength(6));
      for (var i = 0; i < first.length; i++) {
        expect(first[i].id, second[i].id);
        expect(first[i].prompt, second[i].prompt);
        expect(first[i].answer, second[i].answer);
      }
    });

    test('limita la cantidad y no repite tipos de ejercicio', () {
      final all = NumericExerciseGenerator(seed: 3).generate(count: 50);
      expect(all, hasLength(NumericExerciseGenerator.exerciseTypes));
      expect(all.map((item) => item.id).toSet(), hasLength(all.length));
      expect(
        NumericExerciseGenerator(seed: 3).generate(count: 0),
        hasLength(1),
      );
    });

    test('cada ejercicio tiene respuesta finita y solución paso a paso', () {
      for (var seed = 0; seed < 30; seed++) {
        final exercises = NumericExerciseGenerator(
          seed: seed,
        ).generate(count: 8);
        for (final exercise in exercises) {
          expect(exercise.answer.isFinite, isTrue, reason: exercise.id);
          expect(exercise.steps, isNotEmpty, reason: exercise.id);
          expect(exercise.prompt, isNotEmpty, reason: exercise.id);
          expect(exercise.unit, isNotEmpty, reason: exercise.id);
          expect(exercise.isCorrect(exercise.answer), isTrue);
        }
      }
    });

    test('acepta redondeos dentro de la tolerancia', () {
      const exercise = NumericExercise(
        id: 'prueba',
        topic: 'Prueba',
        prompt: '¿Cuánto es?',
        answer: 27.5,
        unit: 'USD/t',
        steps: ['Paso'],
      );
      expect(exercise.isCorrect(27.5), isTrue);
      expect(exercise.isCorrect(27.7), isTrue);
      expect(exercise.isCorrect(28.5), isFalse);
      expect(exercise.isCorrect(-27.5), isFalse);
      expect(exercise.isCorrect(double.nan), isFalse);
    });

    test('usa una tolerancia mínima cuando la respuesta es cercana a cero', () {
      const exercise = NumericExercise(
        id: 'van',
        topic: 'VAN',
        prompt: '¿VAN?',
        answer: 0.02,
        unit: 'M USD',
        steps: ['Paso'],
        decimals: 1,
      );
      expect(exercise.isCorrect(0), isTrue);
      expect(exercise.isCorrect(0.06), isTrue);
      expect(exercise.isCorrect(0.2), isFalse);
    });

    test('los ejercicios de cobre usan el factor 22.0462', () {
      final exercise = NumericExerciseGenerator(
        seed: 11,
      ).generate(count: 8).firstWhere((item) => item.id == 'metal-contenido');
      final numbers = RegExp(
        r'[0-9]+(?:\.[0-9]+)?',
      ).allMatches(exercise.prompt).map((m) => double.parse(m[0]!)).toList();
      // Mt × % × 22.0462 = M lb.
      expect(exercise.answer, closeTo(numbers[0] * numbers[1] * 22.0462, 1e-9));
    });
  });
}
