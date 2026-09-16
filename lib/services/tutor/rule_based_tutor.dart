import '../../utils/formatters.dart';
import 'tutor_engine.dart';
import 'tutor_knowledge_base.dart';
import 'tutor_models.dart';

/// Tutor económico local basado en reglas y palabras clave.
///
/// No usa internet, no envía datos a terceros y no requiere claves.
class RuleBasedTutor implements TutorEngine {
  const RuleBasedTutor({this.entries = tutorKnowledgeBase});

  final List<TutorEntry> entries;

  @override
  String get name => 'Tutor local basado en reglas';

  @override
  bool get requiresNetwork => false;

  @override
  Future<TutorAnswer> answer(TutorQuery query) async {
    return answerSync(query);
  }

  /// Versión síncrona, útil para pruebas.
  TutorAnswer answerSync(TutorQuery query) {
    final entry = detect(query.text);
    if (entry == null) {
      return TutorAnswer(
        title: 'No reconocí la pregunta',
        explanation:
            'Soy un tutor local con temas predefinidos. Prueba preguntando, '
            'por ejemplo, "¿qué es el VAN?" o "diferencia entre CAPEX y '
            'OPEX".',
        keyPoints: [for (final topic in TutorTopic.values) topic.title],
        suggestions: suggestions(),
      );
    }
    return TutorAnswer(
      topic: entry.topic,
      title: entry.topic.title,
      explanation: entry.explanation,
      keyPoints: entry.keyPoints,
      formula: entry.formula,
      contextNote: _contextNote(entry.topic, query.context),
      suggestions: suggestions(exclude: entry.topic),
    );
  }

  /// Respuesta directa para un tema elegido desde un botón.
  TutorAnswer answerTopic(TutorTopic topic, {TutorContext? context}) {
    final entry = entries.firstWhere((item) => item.topic == topic);
    return TutorAnswer(
      topic: topic,
      title: topic.title,
      explanation: entry.explanation,
      keyPoints: entry.keyPoints,
      formula: entry.formula,
      contextNote: _contextNote(topic, context),
      suggestions: suggestions(exclude: topic),
    );
  }

  /// Detecta el tema con mayor puntuación de coincidencia.
  TutorEntry? detect(String text) {
    final normalized = ' ${normalize(text)} ';
    if (normalized.trim().isEmpty) {
      return null;
    }
    TutorEntry? best;
    var bestScore = 0;
    for (final entry in entries) {
      var score = 0;
      for (final keyword in entry.keywords) {
        if (normalized.contains(' $keyword ')) {
          score += keyword.length;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = entry;
      }
    }
    return best;
  }

  List<String> suggestions({TutorTopic? exclude}) {
    return [
      for (final topic in TutorTopic.values)
        if (topic != exclude) topic.title,
    ].take(4).toList();
  }

  /// Minúsculas, sin tildes y sin signos de puntuación.
  static String normalize(String text) {
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    final buffer = StringBuffer();
    for (final char in text.toLowerCase().split('')) {
      buffer.write(replacements[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _contextNote(TutorTopic topic, TutorContext? context) {
    if (context == null) {
      return null;
    }
    final npv = Formatters.compactMoney(context.npv, context.currency);
    final rate = Formatters.percent(context.discountRate * 100);
    final irrValue = context.irr;
    final irr = irrValue == null
        ? 'no calculable'
        : Formatters.percent(irrValue * 100);
    final project = context.projectName;
    switch (topic) {
      case TutorTopic.van:
        final reading = context.npv >= 0
            ? 'genera valor por encima de la tasa exigida'
            : 'no alcanza a remunerar la tasa exigida';
        return 'En "$project", el VAN es $npv con r = $rate: el escenario '
            '$reading bajo los supuestos ingresados.';
      case TutorTopic.tir:
      case TutorTopic.vanVsTir:
        return 'En "$project", la TIR es $irr frente a una tasa de $rate y '
            'el VAN es $npv.';
      case TutorTopic.tasaDescuento:
        return 'En "$project" se usa una tasa de $rate. Prueba cambiarla en '
            'el módulo VAN para ver su efecto.';
      case TutorTopic.leyCorte:
      case TutorTopic.leyMetal:
        final cutoff = context.cutoffGrade;
        if (cutoff == null) {
          return null;
        }
        final average = Formatters.grade(
          context.averageGrade,
          context.gradeUnit,
        );
        final cut = Formatters.grade(cutoff, context.gradeUnit);
        return 'En "$project", la ley promedio es $average y la ley de corte '
            'de equilibrio es $cut.';
      case TutorTopic.costosProduccion:
      case TutorTopic.capexOpex:
      case TutorTopic.precio:
      case TutorTopic.recuperacion:
        final margin = Formatters.percent(context.marginPct, decimals: 1);
        return 'En "$project", el margen operativo es $margin del ingreso '
            'neto.';
      case TutorTopic.sensibilidad:
        return 'Revisa el módulo de sensibilidad para ver qué variable mueve '
            'más el VAN de "$project".';
    }
  }
}
