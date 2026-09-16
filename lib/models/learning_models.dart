import 'project_data.dart';

/// Pregunta de selección múltiple de la evaluación práctica.
class QuizQuestion {
  const QuizQuestion({
    required this.topic,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.isExercise = false,
  });

  final String topic;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  /// Verdadero si la pregunta es un ejercicio corto de cálculo.
  final bool isExercise;
}

/// Caso empresarial educativo.
class CaseStudy {
  const CaseStudy({
    required this.id,
    required this.title,
    required this.summary,
    required this.project,
    required this.assumptions,
    required this.questions,
    required this.expectedCalculations,
    required this.interpretation,
    required this.risks,
    required this.educationalDecision,
    required this.explanation,
    required this.expectedNpvPositive,
    required this.expectedIrrAboveRate,
    this.expectedPessimisticNpvPositive,
  });

  final String id;
  final String title;
  final String summary;
  final ProjectData project;
  final List<String> assumptions;
  final List<String> questions;
  final List<String> expectedCalculations;
  final String interpretation;
  final List<String> risks;
  final String educationalDecision;
  final String explanation;

  /// Resultados esperados que las pruebas verifican contra el simulador.
  final bool expectedNpvPositive;
  final bool expectedIrrAboveRate;
  final bool? expectedPessimisticNpvPositive;
}
