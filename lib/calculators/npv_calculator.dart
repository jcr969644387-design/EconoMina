import 'dart:math' as math;

/// Cálculo educativo del valor actual neto (VAN).
///
/// VAN = Σ [FCt / (1 + r)^t] − I0, con t desde 1 hasta n.
class NpvCalculator {
  const NpvCalculator();

  /// Valor presente de un flujo en el periodo indicado.
  double presentValue(double flow, double rate, int period) {
    if (rate <= -1) {
      throw ArgumentError('La tasa de descuento debe ser mayor que -100 %.');
    }
    if (period < 0) {
      throw ArgumentError('El periodo no puede ser negativo.');
    }
    return flow / math.pow(1 + rate, period).toDouble();
  }

  /// VAN a partir de la inversión inicial y los flujos de los periodos 1..n.
  double npv({
    required double initialInvestment,
    required List<double> flows,
    required double rate,
  }) {
    var total = -initialInvestment;
    for (var i = 0; i < flows.length; i++) {
      total += presentValue(flows[i], rate, i + 1);
    }
    return total;
  }

  /// VAN de una serie completa donde el índice 0 corresponde al periodo 0.
  double npvFromSeries(List<double> series, double rate) {
    var total = 0.0;
    for (var t = 0; t < series.length; t++) {
      total += presentValue(series[t], rate, t);
    }
    return total;
  }

  /// Valores presentes de cada flujo de la serie.
  List<double> presentValues(List<double> series, double rate) => [
    for (var t = 0; t < series.length; t++) presentValue(series[t], rate, t),
  ];
}
