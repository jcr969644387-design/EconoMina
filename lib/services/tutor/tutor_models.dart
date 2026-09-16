/// Temas que el tutor económico local sabe explicar.
enum TutorTopic {
  capexOpex('Diferencia entre CAPEX y OPEX'),
  precio('Efecto del precio del mineral'),
  recuperacion('Influencia de la recuperación'),
  leyMetal('Relación entre ley y metal contenido'),
  leyCorte('Interpretación de la ley de corte'),
  van('Interpretación del VAN'),
  tir('Interpretación de la TIR'),
  vanVsTir('Diferencia entre VAN y TIR'),
  tasaDescuento('Efecto de la tasa de descuento'),
  costosProduccion('Influencia de costos y producción'),
  sensibilidad('Importancia del análisis de sensibilidad');

  const TutorTopic(this.title);

  final String title;
}

/// Datos del proyecto activo para contextualizar las respuestas.
class TutorContext {
  const TutorContext({
    required this.projectName,
    required this.currency,
    required this.npv,
    required this.irr,
    required this.discountRate,
    required this.marginPct,
    required this.averageGrade,
    required this.gradeUnit,
    this.cutoffGrade,
  });

  final String projectName;
  final String currency;
  final double npv;

  /// TIR como fracción; nula si no se pudo calcular.
  final double? irr;
  final double discountRate;
  final double marginPct;
  final double averageGrade;
  final String gradeUnit;
  final double? cutoffGrade;
}

/// Pregunta del estudiante.
class TutorQuery {
  const TutorQuery({required this.text, this.context});

  final String text;
  final TutorContext? context;
}

/// Respuesta del tutor.
class TutorAnswer {
  const TutorAnswer({
    required this.title,
    required this.explanation,
    required this.keyPoints,
    this.topic,
    this.formula,
    this.contextNote,
    this.suggestions = const [],
  });

  /// Tema detectado; nulo si no se reconoció la pregunta.
  final TutorTopic? topic;
  final String title;
  final String explanation;
  final List<String> keyPoints;
  final String? formula;

  /// Comentario basado en el proyecto activo.
  final String? contextNote;
  final List<String> suggestions;
}
