import '../models/profitability.dart';

/// Clasificación educativa de rentabilidad y riesgo.
///
/// Las clasificaciones son orientativas y se interpretan siempre "bajo los
/// supuestos ingresados"; no constituyen una decisión de inversión.
class ProfitabilityClassifier {
  const ProfitabilityClassifier();

  /// VAN positivo: atractivo; VAN cercano a cero: indiferente; VAN negativo:
  /// no atractivo.
  Profitability classifyNpv(double npv, {double tolerance = 1.0}) {
    if (npv.abs() <= tolerance) {
      return Profitability.indiferente;
    }
    return npv > 0 ? Profitability.atractivo : Profitability.noAtractivo;
  }

  /// TIR mayor que la tasa: atractivo; TIR igual a la tasa: indiferente; TIR
  /// menor que la tasa: menos
  /// atractivo. Ambas tasas se expresan como fracción.
  Profitability classifyIrr(
    double irr,
    double discountRate, {
    double tolerance = 0.0005,
  }) {
    final difference = irr - discountRate;
    if (difference.abs() <= tolerance) {
      return Profitability.indiferente;
    }
    return difference > 0 ? Profitability.atractivo : Profitability.noAtractivo;
  }

  /// Riesgo de un resultado puntual (por ejemplo, un punto de sensibilidad).
  ///
  /// - Alto: VAN negativo.
  /// - Medio: VAN menor que 15 % de la inversión o TIR menos de 3 puntos
  ///   sobre la tasa de descuento.
  /// - Bajo: en otro caso.
  RiskLevel pointRisk({
    required double npv,
    required double initialInvestment,
    required double discountRate,
    double? irr,
  }) {
    if (npv < 0) {
      return RiskLevel.alto;
    }
    final smallNpv = npv < 0.15 * initialInvestment;
    final thinSpread = irr != null && irr - discountRate < 0.03;
    if (smallNpv || thinSpread) {
      return RiskLevel.medio;
    }
    return RiskLevel.bajo;
  }

  /// Riesgo del proyecto a partir del escenario base y del pesimista.
  ///
  /// - Alto: el VAN base es negativo.
  /// - Medio: el VAN base es positivo, pero el pesimista es negativo.
  /// - Bajo: ambos son positivos o nulos.
  RiskLevel projectRisk({
    required double baseNpv,
    required double pessimisticNpv,
  }) {
    if (baseNpv < 0) {
      return RiskLevel.alto;
    }
    if (pessimisticNpv < 0) {
      return RiskLevel.medio;
    }
    return RiskLevel.bajo;
  }
}
