import 'package:flutter/material.dart';

import '../calculators/profitability_classifier.dart';
import '../calculators/project_evaluator.dart';
import '../calculators/sensitivity_calculator.dart';
import '../models/profitability.dart';
import '../models/project_data.dart';
import '../models/scenario.dart';
import '../models/sensitivity_models.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import '../widgets/scrollable_table.dart';
import '../widgets/simple_charts.dart';
import 'module_catalog.dart';

/// Módulo 9: análisis de sensibilidad y escenarios.
class SensitivityScreen extends StatefulWidget {
  const SensitivityScreen({super.key});

  @override
  State<SensitivityScreen> createState() => _SensitivityScreenState();
}

class _SensitivityScreenState extends State<SensitivityScreen> {
  static const SensitivityCalculator _calculator = SensitivityCalculator();

  SensitivityVariable _variable = SensitivityVariable.precio;
  ProjectData? _cachedProject;
  List<SensitivityResult> _cachedResults = const [];

  List<SensitivityResult> _resultsFor(ProjectData project) {
    if (!identical(project, _cachedProject)) {
      _cachedProject = project;
      _cachedResults = _calculator.analyzeAll(project);
    }
    return _cachedResults;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final validation = controller.validation;
    if (!validation.isValid) {
      return ModuleScaffold(
        title: 'Sensibilidad',
        children: [
          InvalidProjectNotice(
            result: validation,
            onFix: () => openProjectData(context),
          ),
        ],
      );
    }
    final project = controller.project;
    final scenarios = [
      for (final scenario in ScenarioType.values)
        controller.evaluationFor(scenario),
    ].whereType<ProjectEvaluation>().toList();
    final results = _resultsFor(project);
    final selected = results.firstWhere((item) => item.variable == _variable);
    final ranked = [...results.where((item) => item.isAvailable)]
      ..sort((a, b) => b.npvSwing.compareTo(a.npvSwing));
    final maxSwing = ranked.isEmpty ? 0.0 : ranked.first.npvSwing;
    final currency = project.currency;

    return ModuleScaffold(
      title: 'Sensibilidad',
      children: [
        const SectionHeader(
          title: 'Escenarios',
          subtitle:
              'Comparación del proyecto en los tres escenarios predefinidos.',
        ),
        ScrollableTable(
          columns: const ['Escenario', 'VAN', 'TIR', 'Margen', 'Riesgo'],
          rows: [
            for (final item in scenarios)
              [
                item.scenario.label,
                Formatters.millions(item.npv, currency),
                item.irr.value == null
                    ? 'No calculable'
                    : Formatters.percent(item.irr.value! * 100),
                Formatters.percent(item.summary.marginPct, decimals: 1),
                _scenarioRisk(item).label.replaceFirst('Riesgo ', ''),
              ],
          ],
          rowColors: {
            for (var i = 0; i < scenarios.length; i++)
              if (scenarios[i].npv < 0) i: AppColors.negative,
          },
          caption: ScenarioType.values
              .map((item) => '${item.label}: ${item.description}')
              .join('\n'),
        ),
        ChartCard(
          title: 'VAN por escenario',
          subtitle: 'Millones de $currency',
          chart: SimpleBarChart(
            values: [for (final item in scenarios) item.npv],
            labels: [for (final item in scenarios) item.scenario.label],
            color: AppColors.finance,
            negativeColor: AppColors.negative,
          ),
        ),
        const SectionHeader(
          title: 'Sensibilidad por variable',
          subtitle:
              'Se cambia una sola variable (−20 %, −10 %, 0 %, +10 %, +20 %) '
              'y el resto permanece igual.',
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final variable in SensitivityVariable.values)
              ChoiceChip(
                label: Text(variable.label),
                selected: variable == _variable,
                onSelected: (_) => setState(() => _variable = variable),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (selected.message != null)
          InterpretationCard(
            title: selected.isAvailable ? 'Nota del modelo' : 'No disponible',
            text: selected.message!,
            color: selected.isAvailable
                ? AppColors.finance
                : AppColors.negative,
          ),
        if (selected.isAvailable) ...[
          ScrollableTable(
            columns: [
              'Variación',
              _valueHeader(project, _variable),
              'VAN ($currency M)',
              'TIR',
              'Margen',
              'Años',
              'Riesgo',
            ],
            rows: [
              for (final point in selected.points)
                [
                  '${point.changePct > 0 ? '+' : ''}${point.changePct.toStringAsFixed(0)} %',
                  _valueText(_variable, point.variableValue),
                  Formatters.number(point.npv / 1e6),
                  point.irr == null
                      ? 'No calculable'
                      : Formatters.percent(point.irr! * 100),
                  Formatters.percent(point.marginPct, decimals: 1),
                  '${point.operatingYears}',
                  point.risk.label.replaceFirst('Riesgo ', ''),
                ],
            ],
            rowColors: {
              for (var i = 0; i < selected.points.length; i++)
                i: AppColors.risk(selected.points[i].risk),
            },
            highlightedRows: {
              for (var i = 0; i < selected.points.length; i++)
                if (selected.points[i].changePct == 0) i,
            },
          ),
          ChartCard(
            title: 'VAN vs. variación de ${_variable.label.toLowerCase()}',
            subtitle: 'Eje horizontal: variación (%)',
            chart: SimpleLineChart(
              labels: [
                for (final point in selected.points)
                  point.changePct.toStringAsFixed(0),
              ],
              series: [
                ChartSeries(
                  name: 'VAN',
                  values: [for (final point in selected.points) point.npv],
                  color: AppColors.copper,
                ),
              ],
              referenceValue: 0,
            ),
          ),
        ],
        const SectionHeader(
          title: 'Variables más críticas',
          subtitle:
              'Ordenadas por la diferencia entre el VAN máximo y mínimo '
              '(±20 %).',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final item in ranked)
                  LabeledProgress(
                    label: item.variable.label,
                    value: maxSwing == 0 ? 0 : item.npvSwing / maxSwing,
                    trailing: Formatters.millions(item.npvSwing, currency),
                    color: item == ranked.first
                        ? AppColors.negative
                        : AppColors.finance,
                  ),
              ],
            ),
          ),
        ),
        const FormulaCard(
          title: 'Método de sensibilidad',
          formula:
              'Valor sensibilizado = valor base × (1 + variación)\n'
              'Rango del VAN = VAN máximo − VAN mínimo\n'
              'Ley de corte: T(c) = T0 × e^(−(c − c0) / gm),  ley media = c + gm',
          variables: [
            'c0: ley de corte base (equilibrio); c: ley de corte sensibilizada.',
            'gm: ley promedio − c0; T0: reservas base.',
            'OPEX sensibiliza costos variables y fijos; CAPEX sensibiliza '
                'la inversión inicial.',
          ],
          assumptions: [
            'Análisis ceteris paribus: una variable a la vez.',
            'La recuperación se limita a 100 %.',
          ],
          limitations: [
            'No captura correlaciones entre variables (por ejemplo, precio '
                'y costos).',
            'El modelo ley-tonelaje es ilustrativo, no un modelo de bloques.',
            'No reemplaza un análisis probabilístico (Monte Carlo).',
          ],
        ),
        if (ranked.isNotEmpty)
          InterpretationCard(
            text:
                'La variable más crítica es '
                '${ranked.first.variable.label.toLowerCase()}: una variación de '
                '±20 % mueve el VAN en '
                '${Formatters.millions(ranked.first.npvSwing, currency)}. '
                'Prioriza estudiar mejor esa variable antes de decidir. '
                '${scenarios.any((item) => item.npv < 0) ? 'Al menos un escenario tiene VAN negativo: el resultado depende de los supuestos.' : 'Los tres escenarios mantienen VAN positivo.'}',
          ),
      ],
    );
  }

  String _valueHeader(ProjectData project, SensitivityVariable variable) {
    final currency = project.currency;
    final mineral = project.mineralType;
    return switch (variable) {
      SensitivityVariable.precio =>
        'Precio (${mineral.priceUnitLabel(currency)})',
      SensitivityVariable.ley => 'Ley (${mineral.gradeUnitLabel})',
      SensitivityVariable.recuperacion => 'Recuperación (%)',
      SensitivityVariable.produccion => 'Producción (t/año)',
      SensitivityVariable.capex => 'Inversión ($currency M)',
      SensitivityVariable.opex => 'Costo variable ($currency/t)',
      SensitivityVariable.tasaDescuento => 'Tasa (%)',
      SensitivityVariable.leyCorte =>
        'Ley de corte (${mineral.gradeUnitLabel})',
    };
  }

  RiskLevel _scenarioRisk(ProjectEvaluation item) {
    return const ProfitabilityClassifier().pointRisk(
      npv: item.npv,
      initialInvestment: item.initialInvestment,
      discountRate: item.discountRate,
      irr: item.irr.value,
    );
  }

  String _valueText(SensitivityVariable variable, double value) {
    return switch (variable) {
      SensitivityVariable.precio => Formatters.number(value),
      SensitivityVariable.ley ||
      SensitivityVariable.leyCorte => Formatters.number(value, decimals: 3),
      SensitivityVariable.recuperacion || SensitivityVariable.tasaDescuento =>
        Formatters.number(value, decimals: 1),
      SensitivityVariable.produccion => Formatters.number(value, decimals: 0),
      SensitivityVariable.capex => Formatters.number(value / 1e6),
      SensitivityVariable.opex => Formatters.number(value),
    };
  }
}
