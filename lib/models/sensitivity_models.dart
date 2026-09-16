import 'profitability.dart';

/// Variables que pueden sensibilizarse.
enum SensitivityVariable {
  precio('Precio del mineral'),
  ley('Ley'),
  recuperacion('Recuperación'),
  produccion('Producción'),
  capex('CAPEX'),
  opex('OPEX'),
  tasaDescuento('Tasa de descuento'),
  leyCorte('Ley de corte');

  const SensitivityVariable(this.label);

  final String label;
}

/// Resultado de un punto de sensibilidad.
class SensitivityPoint {
  const SensitivityPoint({
    required this.changePct,
    required this.variableValue,
    required this.npv,
    required this.irr,
    required this.marginPct,
    required this.operatingYears,
    required this.risk,
  });

  /// Variación aplicada a la variable (%).
  final double changePct;

  /// Valor resultante de la variable (en sus unidades).
  final double variableValue;

  final double npv;

  /// TIR como fracción; nula si no se pudo calcular.
  final double? irr;

  final double marginPct;
  final int operatingYears;
  final RiskLevel risk;
}

/// Resultado de sensibilidad para una variable.
class SensitivityResult {
  const SensitivityResult({
    required this.variable,
    required this.points,
    this.message,
  });

  final SensitivityVariable variable;
  final List<SensitivityPoint> points;

  /// Mensaje cuando la variable no pudo analizarse o requiere aclaración.
  final String? message;

  bool get isAvailable => points.isNotEmpty;

  /// Diferencia entre el VAN máximo y mínimo de los puntos analizados.
  double get npvSwing {
    if (points.isEmpty) {
      return 0;
    }
    var minValue = points.first.npv;
    var maxValue = points.first.npv;
    for (final point in points) {
      if (point.npv < minValue) {
        minValue = point.npv;
      }
      if (point.npv > maxValue) {
        maxValue = point.npv;
      }
    }
    return maxValue - minValue;
  }
}
