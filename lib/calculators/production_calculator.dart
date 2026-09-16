/// Cálculos educativos de producción e ingresos.
class ProductionCalculator {
  const ProductionCalculator();

  /// Metal contenido = toneladas × ley × factor de conversión.
  double containedMetal({
    required double tonnes,
    required double grade,
    required double conversionFactor,
  }) {
    if (tonnes < 0) {
      throw ArgumentError('Las toneladas no pueden ser negativas.');
    }
    if (grade < 0) {
      throw ArgumentError('La ley no puede ser negativa.');
    }
    if (conversionFactor <= 0) {
      throw ArgumentError('El factor de conversión debe ser mayor que cero.');
    }
    return tonnes * grade * conversionFactor;
  }

  /// Metal recuperado = metal contenido × recuperación / 100.
  double recoveredMetal({
    required double containedMetal,
    required double recoveryPct,
  }) {
    if (recoveryPct < 0 || recoveryPct > 100) {
      throw ArgumentError('La recuperación debe estar entre 0 % y 100 %.');
    }
    return containedMetal * recoveryPct / 100;
  }

  /// Ingreso bruto = metal recuperado × precio.
  double grossRevenue({required double recoveredMetal, required double price}) {
    if (price <= 0) {
      throw ArgumentError('El precio debe ser mayor que cero.');
    }
    return recoveredMetal * price;
  }

  /// Regalías = ingreso bruto × tasa de regalía / 100.
  double royalty({required double grossRevenue, required double royaltyPct}) {
    if (royaltyPct < 0 || royaltyPct > 100) {
      throw ArgumentError('La regalía debe estar entre 0 % y 100 %.');
    }
    return grossRevenue * royaltyPct / 100;
  }

  /// Ingreso neto = ingreso bruto − regalías.
  double netRevenue({
    required double grossRevenue,
    required double royaltyPct,
  }) {
    return grossRevenue -
        royalty(grossRevenue: grossRevenue, royaltyPct: royaltyPct);
  }

  /// Margen operativo = ingreso neto − costos operativos.
  double operatingMargin({
    required double netRevenue,
    required double operatingCost,
  }) {
    return netRevenue - operatingCost;
  }

  /// Margen operativo como porcentaje del ingreso neto.
  double marginPercent({required double netRevenue, required double margin}) {
    if (netRevenue == 0) {
      return 0;
    }
    return margin / netRevenue * 100;
  }
}
