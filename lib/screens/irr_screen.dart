import 'package:flutter/material.dart';

import '../calculators/npv_calculator.dart';
import '../calculators/project_evaluator.dart';
import '../models/irr_result.dart';
import '../models/profitability.dart';
import '../models/scenario.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import '../widgets/scrollable_table.dart';
import '../widgets/simple_charts.dart';
import 'module_catalog.dart';
import 'npv_screen.dart';

/// Módulo 8: tasa interna de retorno.
class IrrScreen extends StatelessWidget {
  const IrrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final evaluation = controller.evaluation;
    return ModuleScaffold(
      title: 'TIR',
      children: [
        const SectionHeader(
          title: 'Tasa interna de retorno (TIR)',
          subtitle:
              'Es la tasa que hace que el VAN sea igual a cero. Se compara '
              'con la tasa de descuento exigida.',
        ),
        ScenarioSelector(
          value: controller.scenario,
          onChanged: controller.setScenario,
        ),
        const SizedBox(height: 8),
        if (evaluation == null)
          InvalidProjectNotice(
            result: controller.validation,
            onFix: () => openProjectData(context),
          )
        else ...[
          _IrrResults(evaluation: evaluation),
          const SectionHeader(title: 'TIR por escenario'),
          ScrollableTable(
            columns: const ['Escenario', 'VAN', 'TIR', 'Tasa', 'Comparación'],
            rows: [
              for (final scenario in ScenarioType.values)
                _scenarioRow(controller.evaluationFor(scenario)),
            ],
            highlightedRows: {controller.scenario.index},
          ),
        ],
      ],
    );
  }

  List<String> _scenarioRow(ProjectEvaluation? item) {
    if (item == null) {
      return const ['—', '—', '—', '—', '—'];
    }
    final irr = item.irr.value;
    final currency = item.project.currency;
    return [
      item.scenario.label,
      Formatters.millions(item.npv, currency),
      irr == null ? 'No calculable' : Formatters.percent(irr * 100),
      Formatters.percent(item.project.discountRatePct, decimals: 1),
      item.irrClass?.label ?? 'Sin TIR',
    ];
  }
}

class _IrrResults extends StatelessWidget {
  const _IrrResults({required this.evaluation});

  final ProjectEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    const npvCalculator = NpvCalculator();
    final project = evaluation.project;
    final irr = evaluation.irr;
    final irrValue = irr.value;
    final rate = evaluation.discountRate;
    final irrClass = evaluation.irrClass;
    final color = irrClass == null
        ? AppColors.negative
        : AppColors.profitability(irrClass);
    final profile = [
      for (final value in npvProfileRates)
        npvCalculator.npvFromSeries(evaluation.netFlows, value / 100),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiGrid(
          children: [
            KpiCard(
              label: 'TIR',
              value: irrValue == null
                  ? 'No calculable'
                  : Formatters.percent(irrValue * 100),
              icon: Icons.percent,
              color: color,
            ),
            KpiCard(
              label: 'Tasa de descuento',
              value: Formatters.percent(project.discountRatePct),
              icon: Icons.flag_outlined,
              color: AppColors.finance,
            ),
            KpiCard(
              label: 'Diferencia (TIR − tasa)',
              value: irrValue == null
                  ? '—'
                  : '${Formatters.number((irrValue - rate) * 100)} pp',
              icon: Icons.compare_arrows,
              color: irrValue == null
                  ? AppColors.rock
                  : AppColors.signed(irrValue - rate),
              caption: 'pp = puntos porcentuales',
            ),
            KpiCard(
              label: 'VAN a la tasa de descuento',
              value: Formatters.millions(evaluation.npv, project.currency),
              icon: Icons.savings_outlined,
              color: AppColors.signed(evaluation.npv),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (irrClass != null)
          Align(
            alignment: Alignment.centerLeft,
            child: ProfitabilityIndicator(label: 'TIR', value: irrClass),
          ),
        const SizedBox(height: 8),
        _StatusCard(result: irr),
        ChartCard(
          title: 'VAN según la tasa de descuento',
          subtitle:
              'La TIR es el punto donde la curva cruza la línea roja '
              '(VAN = 0).',
          chart: SimpleLineChart(
            labels: [
              for (final value in npvProfileRates) Formatters.plain(value),
            ],
            series: [
              ChartSeries(
                name: 'VAN',
                values: profile,
                color: AppColors.finance,
              ),
            ],
            referenceValue: 0,
          ),
        ),
        const FormulaCard(
          title: 'Definición de la TIR',
          formula: '0 = Σ [FCt / (1 + TIR)^t] − I0,  t = 1 … n',
          variables: [
            'FCt: flujo de caja neto del año t.',
            'I0: inversión inicial.',
            'TIR: tasa que anula el VAN.',
          ],
          assumptions: [
            'Cálculo numérico: barrido de tasas entre −90 % y 1000 % y '
                'bisección en cada cambio de signo del VAN.',
            'Si hay varias raíces se muestra la más cercana a la tasa de '
                'descuento.',
          ],
          limitations: [
            'La TIR supone que los flujos se reinvierten a la misma TIR.',
            'Con flujos que cambian de signo varias veces (por ejemplo, por '
                'un cierre costoso) puede haber varias TIR o ninguna.',
            'La TIR no mide el tamaño del valor creado: para elegir entre '
                'proyectos, prioriza el VAN.',
          ],
        ),
        InterpretationCard(
          text: _interpretation(irrValue, rate, irrClass),
          color: color,
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VAN y TIR: ¿en qué se diferencian?',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                BulletList(
                  items: [
                    'El VAN expresa valor en dinero; la TIR, una rentabilidad '
                        'en porcentaje.',
                    'El VAN necesita una tasa de descuento; la TIR se calcula '
                        'solo con los flujos.',
                    'Si la TIR supera la tasa, normalmente el VAN es positivo '
                        '(flujo convencional).',
                    'Para proyectos excluyentes o de distinto tamaño, el VAN '
                        'es el criterio más confiable.',
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _interpretation(double? irr, double rate, Profitability? value) {
    if (irr == null || value == null) {
      return 'No se puede interpretar la TIR porque no pudo calcularse. '
          'Usa el VAN para evaluar el proyecto.';
    }
    final irrText = Formatters.percent(irr * 100);
    final rateText = Formatters.percent(rate * 100);
    return switch (value) {
      Profitability.atractivo =>
        'La TIR ($irrText) es mayor que la tasa exigida ($rateText): bajo los '
            'supuestos ingresados, el proyecto rinde más que el costo de '
            'oportunidad del capital.',
      Profitability.indiferente =>
        'La TIR ($irrText) es prácticamente igual a la tasa exigida '
            '($rateText): el proyecto apenas cubre el rendimiento requerido.',
      Profitability.noAtractivo =>
        'La TIR ($irrText) es menor que la tasa exigida ($rateText): bajo los '
            'supuestos ingresados, el proyecto es menos atractivo que la '
            'alternativa de inversión.',
    };
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.result});

  final IrrResult result;

  @override
  Widget build(BuildContext context) {
    final ok = result.isValid && !result.hasMultipleRoots;
    final color = ok
        ? AppColors.positive
        : result.isValid
        ? AppColors.neutral
        : AppColors.negative;
    return Card(
      child: ListTile(
        leading: Icon(
          ok ? Icons.check_circle_outline : Icons.warning_amber_outlined,
          color: color,
        ),
        title: Text(
          ok
              ? 'Cálculo convergente'
              : result.isValid
              ? 'Varias TIR posibles'
              : 'TIR no calculable',
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          result.hasMultipleRoots
              ? '${result.message} Raíces: '
                    '${result.roots.map((root) => Formatters.percent(root * 100)).join('; ')}.'
              : result.message,
        ),
      ),
    );
  }
}
