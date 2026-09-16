import 'dart:math' as math;

import '../models/cutoff_models.dart';
import '../models/profitability.dart';
import '../models/project_data.dart';
import '../models/sensitivity_models.dart';
import 'cash_flow_calculator.dart';
import 'cutoff_grade_calculator.dart';
import 'irr_calculator.dart';
import 'npv_calculator.dart';
import 'profitability_classifier.dart';

/// Análisis de sensibilidad educativo.
///
/// Cada variable se modifica sola (ceteris paribus) en los porcentajes
/// indicados. Para la ley de corte se usa un modelo exponencial de
/// ley-tonelaje: al subir la ley de corte disminuye el tonelaje y aumenta la
/// ley media, y viceversa.
class SensitivityCalculator {
  const SensitivityCalculator({
    this.cashFlow = const CashFlowCalculator(),
    this.npvCalculator = const NpvCalculator(),
    this.irrCalculator = const IrrCalculator(),
    this.classifier = const ProfitabilityClassifier(),
    this.cutoffCalculator = const CutoffGradeCalculator(),
  });

  static const List<double> defaultChanges = [-20, -10, 0, 10, 20];

  final CashFlowCalculator cashFlow;
  final NpvCalculator npvCalculator;
  final IrrCalculator irrCalculator;
  final ProfitabilityClassifier classifier;
  final CutoffGradeCalculator cutoffCalculator;

  List<SensitivityResult> analyzeAll(
    ProjectData base, {
    List<double> changes = defaultChanges,
  }) {
    return [
      for (final variable in SensitivityVariable.values)
        analyze(base, variable, changes: changes),
    ];
  }

  SensitivityResult analyze(
    ProjectData base,
    SensitivityVariable variable, {
    List<double> changes = defaultChanges,
  }) {
    if (variable == SensitivityVariable.leyCorte) {
      final message = _cutoffModelMessage(base);
      if (message != null) {
        return SensitivityResult(
          variable: variable,
          points: const [],
          message: message,
        );
      }
    }
    final points = <SensitivityPoint>[];
    for (final change in changes) {
      final varied = vary(base, variable, change);
      points.add(_evaluate(varied, change, _valueOf(base, variable, change)));
    }
    return SensitivityResult(
      variable: variable,
      points: points,
      message: variable == SensitivityVariable.leyCorte
          ? 'Modelo ley-tonelaje exponencial simplificado: la ley de corte '
                'base es la de equilibrio calculada con los costos del '
                'proyecto.'
          : null,
    );
  }

  /// Devuelve el proyecto con la variable modificada en [changePct] %.
  ProjectData vary(
    ProjectData base,
    SensitivityVariable variable,
    double changePct,
  ) {
    final factor = 1 + changePct / 100;
    switch (variable) {
      case SensitivityVariable.precio:
        return base.copyWith(metalPrice: base.metalPrice * factor);
      case SensitivityVariable.ley:
        return base.copyWith(averageGrade: base.averageGrade * factor);
      case SensitivityVariable.recuperacion:
        return base.copyWith(
          recoveryPct: math.min(100.0, base.recoveryPct * factor),
        );
      case SensitivityVariable.produccion:
        return base.copyWith(
          annualProductionTonnes: base.annualProductionTonnes * factor,
        );
      case SensitivityVariable.capex:
        return base.copyWith(costs: base.costs.scaled(capexFactor: factor));
      case SensitivityVariable.opex:
        return base.copyWith(costs: base.costs.scaled(opexFactor: factor));
      case SensitivityVariable.tasaDescuento:
        return base.copyWith(discountRatePct: base.discountRatePct * factor);
      case SensitivityVariable.leyCorte:
        return _varyCutoff(base, factor);
    }
  }

  /// Ley de corte base (equilibrio) del proyecto.
  double baseCutoff(ProjectData base) {
    return cutoffCalculator
        .calculate(
          cutoffCalculator.fromProject(base, method: CutoffMethod.equilibrio),
        )
        .cutoffGrade;
  }

  String? _cutoffModelMessage(ProjectData base) {
    try {
      final cutoff = baseCutoff(base);
      if (base.averageGrade <= cutoff) {
        return 'No se puede analizar la ley de corte: la ley promedio es '
            'menor o igual que la ley de corte de equilibrio. Con estos '
            'costos, el yacimiento no cubre sus costos en promedio.';
      }
      return null;
    } on ArgumentError catch (error) {
      return 'No se puede analizar la ley de corte: ${error.message}';
    }
  }

  /// Modelo exponencial: T(c) = T0 × e^(−c / gm) y ley media = c + gm,
  /// con gm = ley promedio − ley de corte base.
  ProjectData _varyCutoff(ProjectData base, double factor) {
    final baseCut = baseCutoff(base);
    final meanExcess = base.averageGrade - baseCut;
    final newCut = baseCut * factor;
    final tonnes =
        base.reservesTonnes * math.exp((baseCut - newCut) / meanExcess);
    return base.copyWith(
      reservesTonnes: tonnes,
      averageGrade: newCut + meanExcess,
    );
  }

  double _valueOf(ProjectData base, SensitivityVariable variable, double c) {
    final factor = 1 + c / 100;
    switch (variable) {
      case SensitivityVariable.precio:
        return base.metalPrice * factor;
      case SensitivityVariable.ley:
        return base.averageGrade * factor;
      case SensitivityVariable.recuperacion:
        return math.min(100.0, base.recoveryPct * factor);
      case SensitivityVariable.produccion:
        return base.annualProductionTonnes * factor;
      case SensitivityVariable.capex:
        return base.costs.initialInvestment * factor;
      case SensitivityVariable.opex:
        return base.costs.variableUnitCost * factor;
      case SensitivityVariable.tasaDescuento:
        return base.discountRatePct * factor;
      case SensitivityVariable.leyCorte:
        return baseCutoff(base) * factor;
    }
  }

  SensitivityPoint _evaluate(ProjectData project, double change, double v) {
    final rows = cashFlow.build(project);
    final flows = cashFlow.netFlows(rows);
    final npv = npvCalculator.npvFromSeries(flows, project.discountRate);
    final irr = irrCalculator.calculate(
      flows,
      referenceRate: project.discountRate,
    );
    final summary = cashFlow.summarize(rows);
    return SensitivityPoint(
      changePct: change,
      variableValue: v,
      npv: npv,
      irr: irr.value,
      marginPct: summary.marginPct,
      operatingYears: summary.operatingYears,
      risk: _risk(project, npv, irr.value),
    );
  }

  RiskLevel _risk(ProjectData project, double npv, double? irr) {
    return classifier.pointRisk(
      npv: npv,
      initialInvestment: project.costs.initialInvestment,
      discountRate: project.discountRate,
      irr: irr,
    );
  }
}
