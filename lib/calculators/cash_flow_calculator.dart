import 'dart:math' as math;

import '../models/cash_flow_row.dart';
import '../models/project_data.dart';
import 'production_calculator.dart';

/// Construye el flujo económico anual simplificado.
///
/// Supuestos:
/// - Periodo 0: inversión inicial (CAPEX + desarrollo).
/// - Periodos 1..n: producción = mínimo entre producción anual y reservas
///   restantes; n = mínimo entre vida útil y años de reservas.
/// - Ley, recuperación, precio y costos constantes (precios reales).
/// - Impuestos simplificados (si se activan) sobre margen − depreciación
///   lineal, sin pérdidas arrastrables.
/// - Cierre de mina en el último periodo de operación.
class CashFlowCalculator {
  const CashFlowCalculator({this.production = const ProductionCalculator()});

  final ProductionCalculator production;

  /// Años efectivos de operación.
  int operatingYears(ProjectData project) {
    if (project.annualProductionTonnes <= 0 || project.lifeYears <= 0) {
      return 0;
    }
    if (project.reservesTonnes <= 0) {
      return 0;
    }
    final ratio = project.reservesTonnes / project.annualProductionTonnes;
    final reserveYears = (ratio - 1e-9).ceil();
    return math.min(project.lifeYears, reserveYears);
  }

  List<CashFlowRow> build(ProjectData project) {
    final years = operatingYears(project);
    final rate = project.discountRate;
    if (rate <= -1) {
      throw ArgumentError('La tasa de descuento debe ser mayor que -100 %.');
    }
    final costs = project.costs;
    final investment = costs.initialInvestment;
    final depreciation = years > 0 ? investment / years : 0.0;

    final rows = <CashFlowRow>[
      CashFlowRow(
        period: 0,
        tonnes: 0,
        grade: 0,
        containedMetal: 0,
        recoveredMetal: 0,
        grossRevenue: 0,
        royalty: 0,
        netRevenue: 0,
        capex: investment,
        opex: 0,
        operatingMargin: 0,
        taxes: 0,
        closure: 0,
        netFlow: -investment,
        discountFactor: 1,
        discountedFlow: -investment,
        cumulativeFlow: -investment,
        cumulativeDiscountedFlow: -investment,
      ),
    ];

    var remaining = project.reservesTonnes;
    var cumulative = -investment;
    var cumulativeDiscounted = -investment;
    for (var t = 1; t <= years; t++) {
      final tonnes = math.min(project.annualProductionTonnes, remaining);
      remaining -= tonnes;
      final contained = production.containedMetal(
        tonnes: tonnes,
        grade: project.averageGrade,
        conversionFactor: project.mineralType.conversionFactor,
      );
      final recovered = production.recoveredMetal(
        containedMetal: contained,
        recoveryPct: project.recoveryPct,
      );
      final gross = production.grossRevenue(
        recoveredMetal: recovered,
        price: project.metalPrice,
      );
      final royalty = production.royalty(
        grossRevenue: gross,
        royaltyPct: project.royaltyPct,
      );
      final net = gross - royalty;
      final opex = costs.variableUnitCost * tonnes + costs.annualFixedCost;
      final margin = production.operatingMargin(
        netRevenue: net,
        operatingCost: opex,
      );
      final taxable = margin - depreciation;
      final taxes = project.taxEnabled && taxable > 0
          ? taxable * project.taxRatePct / 100
          : 0.0;
      final closure = t == years ? costs.closureCost : 0.0;
      final netFlow = margin - taxes - closure;
      final factor = 1 / math.pow(1 + rate, t).toDouble();
      final discounted = netFlow * factor;
      cumulative += netFlow;
      cumulativeDiscounted += discounted;
      rows.add(
        CashFlowRow(
          period: t,
          tonnes: tonnes,
          grade: project.averageGrade,
          containedMetal: contained,
          recoveredMetal: recovered,
          grossRevenue: gross,
          royalty: royalty,
          netRevenue: net,
          capex: 0,
          opex: opex,
          operatingMargin: margin,
          taxes: taxes,
          closure: closure,
          netFlow: netFlow,
          discountFactor: factor,
          discountedFlow: discounted,
          cumulativeFlow: cumulative,
          cumulativeDiscountedFlow: cumulativeDiscounted,
        ),
      );
    }
    return rows;
  }

  /// Serie de flujos netos (índice = periodo).
  List<double> netFlows(List<CashFlowRow> rows) => [
    for (final row in rows) row.netFlow,
  ];

  CashFlowSummary summarize(List<CashFlowRow> rows) {
    var tonnes = 0.0;
    var metal = 0.0;
    var gross = 0.0;
    var net = 0.0;
    var opex = 0.0;
    var margin = 0.0;
    var taxes = 0.0;
    var flow = 0.0;
    int? payback;
    for (final row in rows) {
      tonnes += row.tonnes;
      metal += row.recoveredMetal;
      gross += row.grossRevenue;
      net += row.netRevenue;
      opex += row.opex;
      margin += row.operatingMargin;
      taxes += row.taxes;
      flow += row.netFlow;
      if (payback == null && row.period > 0 && row.cumulativeFlow >= 0) {
        payback = row.period;
      }
    }
    return CashFlowSummary(
      operatingYears: rows.isEmpty ? 0 : rows.length - 1,
      totalTonnes: tonnes,
      totalRecoveredMetal: metal,
      totalGrossRevenue: gross,
      totalNetRevenue: net,
      totalOpex: opex,
      totalMargin: margin,
      totalTaxes: taxes,
      totalNetFlow: flow,
      paybackPeriod: payback,
    );
  }
}
