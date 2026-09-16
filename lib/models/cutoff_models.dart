/// Variante del modelo simplificado de ley de corte.
enum CutoffMethod {
  equilibrio(
    'De equilibrio (break-even)',
    'Incluye costos de mina, procesamiento y generales. Útil para decidir si '
        'un bloque paga su extracción y tratamiento.',
  ),
  marginal(
    'Marginal (material ya extraído)',
    'Excluye el costo de mina porque el material ya fue extraído. Útil para '
        'decidir si un material se envía a planta o a desmonte.',
  );

  const CutoffMethod(this.label, this.explanation);

  final String label;
  final String explanation;
}

/// Datos de entrada del modelo educativo de ley de corte.
class CutoffInput {
  const CutoffInput({
    required this.metalPrice,
    required this.recoveryPct,
    required this.miningCost,
    required this.processingCost,
    required this.generalCost,
    required this.royaltyPct,
    required this.sellingCost,
    required this.payablePct,
    required this.conversionFactor,
    required this.gradeUnit,
    required this.metalUnit,
    this.method = CutoffMethod.equilibrio,
  });

  /// Precio del metal (moneda por unidad de metal).
  final double metalPrice;

  /// Recuperación metalúrgica (%).
  final double recoveryPct;

  /// Costo de mina (moneda/t).
  final double miningCost;

  /// Costo de procesamiento (moneda/t).
  final double processingCost;

  /// Costos generales y administrativos (moneda/t).
  final double generalCost;

  /// Regalías como porcentaje del ingreso (%).
  final double royaltyPct;

  /// Costos adicionales de venta o refinación (moneda por unidad de metal).
  final double sellingCost;

  /// Contenido metálico pagable (%).
  final double payablePct;

  /// Factor de conversión de unidades (unidades de metal por t y por unidad
  /// de ley).
  final double conversionFactor;

  final String gradeUnit;
  final String metalUnit;
  final CutoffMethod method;

  CutoffInput copyWith({
    double? metalPrice,
    double? recoveryPct,
    double? miningCost,
    double? processingCost,
    double? generalCost,
    CutoffMethod? method,
  }) {
    return CutoffInput(
      metalPrice: metalPrice ?? this.metalPrice,
      recoveryPct: recoveryPct ?? this.recoveryPct,
      miningCost: miningCost ?? this.miningCost,
      processingCost: processingCost ?? this.processingCost,
      generalCost: generalCost ?? this.generalCost,
      royaltyPct: royaltyPct,
      sellingCost: sellingCost,
      payablePct: payablePct,
      conversionFactor: conversionFactor,
      gradeUnit: gradeUnit,
      metalUnit: metalUnit,
      method: method ?? this.method,
    );
  }
}

/// Resultado del modelo de ley de corte.
class CutoffResult {
  const CutoffResult({
    required this.cutoffGrade,
    required this.costPerTonne,
    required this.netPricePerUnit,
    required this.valuePerGradeUnit,
  });

  /// Ley de corte en las unidades de ley del mineral.
  final double cutoffGrade;

  /// Costos considerados por tonelada.
  final double costPerTonne;

  /// Precio neto por unidad de metal pagable.
  final double netPricePerUnit;

  /// Valor recuperable de una tonelada por cada unidad de ley.
  final double valuePerGradeUnit;
}

/// Fila de sensibilidad de la ley de corte.
class CutoffSensitivityRow {
  const CutoffSensitivityRow({
    required this.changePct,
    required this.byPrice,
    required this.byRecovery,
    required this.byCost,
  });

  final double changePct;

  /// Ley de corte si solo cambia el precio (NaN si no es calculable).
  final double byPrice;

  /// Ley de corte si solo cambia la recuperación.
  final double byRecovery;

  /// Ley de corte si solo cambian los costos por tonelada.
  final double byCost;
}
