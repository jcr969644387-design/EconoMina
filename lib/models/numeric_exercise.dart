/// Ejercicio numérico con respuesta verificable.
class NumericExercise {
  const NumericExercise({
    required this.id,
    required this.topic,
    required this.prompt,
    required this.answer,
    required this.unit,
    required this.steps,
    this.tolerancePct = 1.0,
    this.decimals = 2,
  });

  final String id;
  final String topic;
  final String prompt;

  /// Respuesta correcta en la unidad indicada.
  final double answer;
  final String unit;

  /// Desarrollo paso a paso de la solución.
  final List<String> steps;

  /// Tolerancia relativa aceptada (%) por redondeos del estudiante.
  final double tolerancePct;

  /// Decimales sugeridos para mostrar la respuesta.
  final int decimals;

  /// Verdadero si [value] está dentro de la tolerancia.
  bool isCorrect(double value) {
    if (!value.isFinite) {
      return false;
    }
    final allowed = answer.abs() * tolerancePct / 100;
    final minimum = 0.5 / _pow10(decimals);
    final margin = allowed > minimum ? allowed : minimum;
    return (value - answer).abs() <= margin;
  }

  static double _pow10(int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
