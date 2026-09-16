import 'dart:math' as math;

import '../models/cash_flow_row.dart';
import '../models/irr_result.dart';
import '../models/profitability.dart';
import '../models/project_data.dart';
import '../models/scenario.dart';
import 'cash_flow_calculator.dart';
import 'irr_calculator.dart';
import 'npv_calculator.dart';
import 'profitability_classifier.dart';
import 'scenario_builder.dart';

/// Resultado completo de evaluar un proyecto en un escenario.
class ProjectEvaluation {
  const ProjectEvaluation({
    required this.project,
    required this.scenario,
    required this.rows,
    required this.summary,
    required this.npv,
    required this.irr,
    required this.npvClass,
    required this.irrClass,
    required this.pessimisticNpv,
    required this.risk,
  });

  /// Proyecto con los factores del escenario ya aplicados.
  final ProjectData project;
  final ScenarioType scenario;
  final List<CashFlowRow> rows;
  final CashFlowSummary summary;
  final double npv;
  final IrrResult irr;
  final Profitability npvClass;

  /// Nula si la TIR no pudo calcularse.
  final Profitability? irrClass;

  /// VAN del escenario pesimista (usado para estimar el riesgo).
  final double pessimisticNpv;
  final RiskLevel risk;

  double get discountRate => project.discountRate;

  double get initialInvestment => project.costs.initialInvestment;

  List<double> get netFlows => [for (final row in rows) row.netFlow];
}

/// Orquesta los cálculos de flujo, VAN, TIR, rentabilidad y riesgo.
class ProjectEvaluator {
  const ProjectEvaluator({
    this.cashFlow = const CashFlowCalculator(),
    this.npvCalculator = const NpvCalculator(),
    this.irrCalculator = const IrrCalculator(),
    this.classifier = const ProfitabilityClassifier(),
    this.scenarios = const ScenarioBuilder(),
  });

  final CashFlowCalculator cashFlow;
  final NpvCalculator npvCalculator;
  final IrrCalculator irrCalculator;
  final ProfitabilityClassifier classifier;
  final ScenarioBuilder scenarios;

  /// Tolerancia para considerar un VAN "igual a cero".
  double npvTolerance(ProjectData project) =>
      math.max(1.0, project.costs.initialInvestment * 0.001);

  /// VAN rápido de un proyecto (sin clasificar).
  double quickNpv(ProjectData project) {
    final rows = cashFlow.build(project);
    return npvCalculator.npvFromSeries(
      cashFlow.netFlows(rows),
      project.discountRate,
    );
  }

  ProjectEvaluation evaluate(
    ProjectData baseProject, {
    ScenarioType scenario = ScenarioType.base,
  }) {
    final project = scenarios.apply(baseProject, scenario);
    final rows = cashFlow.build(project);
    final flows = cashFlow.netFlows(rows);
    final npv = npvCalculator.npvFromSeries(flows, project.discountRate);
    final irr = irrCalculator.calculate(
      flows,
      referenceRate: project.discountRate,
    );
    final pessimisticNpv = scenario == ScenarioType.pesimista
        ? npv
        : quickNpv(scenarios.apply(baseProject, ScenarioType.pesimista));
    final baseNpv = scenario == ScenarioType.base ? npv : quickNpv(baseProject);
    final irrValue = irr.value;
    return ProjectEvaluation(
      project: project,
      scenario: scenario,
      rows: rows,
      summary: cashFlow.summarize(rows),
      npv: npv,
      irr: irr,
      npvClass: classifier.classifyNpv(npv, tolerance: npvTolerance(project)),
      irrClass: irrValue == null
          ? null
          : classifier.classifyIrr(irrValue, project.discountRate),
      pessimisticNpv: pessimisticNpv,
      risk: classifier.projectRisk(
        baseNpv: baseNpv,
        pessimisticNpv: pessimisticNpv,
      ),
    );
  }
}
