/// Fila de la tabla de flujo económico para un periodo anual.
class CashFlowRow {
  const CashFlowRow({
    required this.period,
    required this.tonnes,
    required this.grade,
    required this.containedMetal,
    required this.recoveredMetal,
    required this.grossRevenue,
    required this.royalty,
    required this.netRevenue,
    required this.capex,
    required this.opex,
    required this.operatingMargin,
    required this.taxes,
    required this.closure,
    required this.netFlow,
    required this.discountFactor,
    required this.discountedFlow,
    required this.cumulativeFlow,
    required this.cumulativeDiscountedFlow,
  });

  final int period;
  final double tonnes;
  final double grade;
  final double containedMetal;
  final double recoveredMetal;
  final double grossRevenue;
  final double royalty;
  final double netRevenue;
  final double capex;
  final double opex;
  final double operatingMargin;
  final double taxes;
  final double closure;
  final double netFlow;
  final double discountFactor;
  final double discountedFlow;
  final double cumulativeFlow;
  final double cumulativeDiscountedFlow;

  /// Flujo antes de impuestos = margen operativo − CAPEX − cierre.
  double get preTaxFlow => operatingMargin - capex - closure;
}

/// Totales del flujo económico.
class CashFlowSummary {
  const CashFlowSummary({
    required this.operatingYears,
    required this.totalTonnes,
    required this.totalRecoveredMetal,
    required this.totalGrossRevenue,
    required this.totalNetRevenue,
    required this.totalOpex,
    required this.totalMargin,
    required this.totalTaxes,
    required this.totalNetFlow,
    required this.paybackPeriod,
  });

  final int operatingYears;
  final double totalTonnes;
  final double totalRecoveredMetal;
  final double totalGrossRevenue;
  final double totalNetRevenue;
  final double totalOpex;
  final double totalMargin;
  final double totalTaxes;
  final double totalNetFlow;

  /// Primer año en que el flujo acumulado es mayor o igual a cero.
  /// Es nulo si la inversión no se recupera.
  final int? paybackPeriod;

  /// Margen operativo como porcentaje del ingreso neto.
  double get marginPct =>
      totalNetRevenue == 0 ? 0 : totalMargin / totalNetRevenue * 100;
}
