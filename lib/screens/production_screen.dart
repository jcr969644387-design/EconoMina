import 'package:flutter/material.dart';

import '../calculators/project_evaluator.dart';
import '../models/cash_flow_row.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import '../widgets/scrollable_table.dart';
import '../widgets/simple_charts.dart';
import 'module_catalog.dart';

/// Módulo 5: producción e ingresos.
class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final evaluation = controller.evaluation;
    return ModuleScaffold(
      title: 'Producción e ingresos',
      children: [
        const SectionHeader(
          title: 'Del mineral al ingreso',
          subtitle:
              'Toneladas × ley → metal contenido → metal recuperado → '
              'ingresos → margen operativo.',
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
        else
          _ProductionResults(evaluation: evaluation),
      ],
    );
  }
}

class _ProductionResults extends StatelessWidget {
  const _ProductionResults({required this.evaluation});

  final ProjectEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final project = evaluation.project;
    final currency = project.currency;
    final metal = MetalDisplay.of(project.mineralType);
    final unit = project.mineralType.metalUnit;
    final gradeUnit = project.mineralType.gradeUnitLabel;
    final operating = evaluation.rows.where((row) => row.period > 0).toList();
    if (operating.isEmpty) {
      return const InterpretationCard(
        title: 'Sin producción',
        text: 'El proyecto no tiene años de operación con estos datos.',
        color: AppColors.negative,
      );
    }
    final first = operating.first;
    final marginPct = first.netRevenue == 0
        ? 0.0
        : first.operatingMargin / first.netRevenue * 100;
    final positive = first.operatingMargin > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Primer año de operación',
          subtitle:
              'Escenario ${evaluation.scenario.label}: precio '
              '${Formatters.money(project.metalPrice, currency)}/$unit, ley '
              '${Formatters.grade(project.averageGrade, gradeUnit)}, '
              'recuperación ${Formatters.percent(project.recoveryPct, decimals: 1)}.',
        ),
        KpiGrid(
          children: [
            KpiCard(
              label: 'Mineral tratado',
              value: Formatters.tonnes(first.tonnes),
              icon: Icons.landscape_outlined,
              color: AppColors.rock,
            ),
            KpiCard(
              label: 'Metal contenido',
              value: metal.format(first.containedMetal),
              icon: Icons.grain,
              color: AppColors.copper,
            ),
            KpiCard(
              label: 'Metal recuperado',
              value: metal.format(first.recoveredMetal),
              icon: Icons.science_outlined,
              color: AppColors.copper,
              caption:
                  'Pérdida en planta: ${metal.format(first.containedMetal - first.recoveredMetal)}',
            ),
            KpiCard(
              label: 'Ingreso bruto',
              value: Formatters.millions(first.grossRevenue, currency),
              icon: Icons.attach_money,
              color: AppColors.finance,
            ),
            KpiCard(
              label: 'Regalías',
              value: Formatters.millions(first.royalty, currency),
              icon: Icons.account_balance_outlined,
              caption: Formatters.percent(project.royaltyPct, decimals: 1),
            ),
            KpiCard(
              label: 'Ingreso neto',
              value: Formatters.millions(first.netRevenue, currency),
              icon: Icons.payments_outlined,
              color: AppColors.finance,
            ),
            KpiCard(
              label: 'Costos operativos',
              value: Formatters.millions(first.opex, currency),
              icon: Icons.construction,
            ),
            KpiCard(
              label: 'Margen operativo',
              value: Formatters.millions(first.operatingMargin, currency),
              icon: Icons.trending_up,
              color: AppColors.signed(first.operatingMargin),
              caption: 'Margen: ${Formatters.percent(marginPct, decimals: 1)}',
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                LabeledProgress(
                  label: 'Recuperación metalúrgica',
                  value: project.recoveryPct / 100,
                  trailing: Formatters.percent(
                    project.recoveryPct,
                    decimals: 1,
                  ),
                  color: AppColors.copper,
                ),
                LabeledProgress(
                  label: 'Costos operativos / ingreso neto',
                  value: first.netRevenue <= 0
                      ? 1
                      : first.opex / first.netRevenue,
                  trailing: first.netRevenue <= 0
                      ? '—'
                      : Formatters.percent(
                          first.opex / first.netRevenue * 100,
                          decimals: 1,
                        ),
                  color: AppColors.negative,
                ),
                LabeledProgress(
                  label: 'Margen operativo',
                  value: marginPct / 100,
                  trailing: Formatters.percent(marginPct, decimals: 1),
                  color: AppColors.positive,
                ),
              ],
            ),
          ),
        ),
        ChartCard(
          title: 'Ingreso neto y costos por año',
          subtitle: 'Montos en $currency',
          chart: SimpleLineChart(
            labels: [for (final row in operating) '${row.period}'],
            series: _series(operating),
          ),
          series: _series(operating),
        ),
        ScrollableTable(
          columns: [
            'Año',
            'Mineral',
            'Metal recuperado',
            'Ingreso neto ($currency M)',
            'OPEX ($currency M)',
            'Margen ($currency M)',
          ],
          rows: [
            for (final row in operating)
              [
                '${row.period}',
                Formatters.tonnes(row.tonnes),
                metal.format(row.recoveredMetal),
                Formatters.number(row.netRevenue / 1e6),
                Formatters.number(row.opex / 1e6),
                Formatters.number(row.operatingMargin / 1e6),
              ],
          ],
          caption:
              'El último año puede tener menos toneladas si las reservas se '
              'agotan antes.',
        ),
        FormulaCard(
          title: 'Fórmulas de producción e ingresos',
          formula:
              'Metal contenido = t × ley × F\n'
              'Metal recuperado = metal contenido × recuperación\n'
              'Ingreso bruto = metal recuperado × precio\n'
              'Regalías = ingreso bruto × % regalía\n'
              'Ingreso neto = ingreso bruto − regalías\n'
              'Margen operativo = ingreso neto − costos operativos',
          variables: [
            't: toneladas tratadas en el año.',
            'Ley en ${project.mineralType.gradeUnitLabel}; '
                '${project.mineralType.conversionExplanation}.',
            'Recuperación como fracción (88 % = 0.88).',
          ],
          assumptions: const [
            'Todo el metal recuperado se vende en el mismo año.',
            'Precio, ley y recuperación constantes durante la vida útil.',
          ],
          limitations: const [
            'No incluye costos de fundición y refinación ni penalidades por '
                'impurezas del concentrado.',
            'No modela la variabilidad de leyes entre bloques.',
          ],
        ),
        InterpretationCard(
          text: positive
              ? 'Cada año el proyecto recupera ${metal.format(first.recoveredMetal)} '
                    'y obtiene un margen operativo de '
                    '${Formatters.millions(first.operatingMargin, currency)} '
                    '(${Formatters.percent(marginPct, decimals: 1)} del ingreso '
                    'neto). Este margen es el que debe pagar la inversión inicial '
                    'y el cierre.'
              : 'Con estos supuestos, los costos operativos superan al ingreso '
                    'neto: el proyecto pierde dinero en cada año de operación, '
                    'antes incluso de considerar la inversión.',
          color: positive ? AppColors.positive : AppColors.negative,
        ),
      ],
    );
  }

  List<ChartSeries> _series(List<CashFlowRow> operating) {
    return [
      ChartSeries(
        name: 'Ingreso neto',
        values: [for (final row in operating) row.netRevenue],
        color: AppColors.finance,
      ),
      ChartSeries(
        name: 'Costos operativos',
        values: [for (final row in operating) row.opex],
        color: AppColors.negative,
      ),
      ChartSeries(
        name: 'Margen operativo',
        values: [for (final row in operating) row.operatingMargin],
        color: AppColors.positive,
      ),
    ];
  }
}
