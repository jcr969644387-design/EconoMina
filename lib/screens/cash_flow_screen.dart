import 'package:flutter/material.dart';

import '../calculators/project_evaluator.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import '../widgets/scrollable_table.dart';
import '../widgets/simple_charts.dart';
import 'module_catalog.dart';

/// Módulo 6: flujo económico anual.
class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final evaluation = controller.evaluation;
    return ModuleScaffold(
      title: 'Flujo económico',
      children: [
        const SectionHeader(
          title: 'Flujo de caja anual simplificado',
          subtitle:
              'Año 0: inversión. Años 1 a n: ingresos menos costos, '
              'impuestos (si se activan) y cierre en el último año.',
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
          _CashFlowResults(evaluation: evaluation),
      ],
    );
  }
}

class _CashFlowResults extends StatelessWidget {
  const _CashFlowResults({required this.evaluation});

  final ProjectEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final project = evaluation.project;
    final currency = project.currency;
    final summary = evaluation.summary;
    final rows = evaluation.rows;
    final metal = MetalDisplay.of(project.mineralType);
    final payback = summary.paybackPeriod;
    String m(double value) => Formatters.number(value / 1e6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiGrid(
          children: [
            KpiCard(
              label: 'Años de operación',
              value: '${summary.operatingYears}',
              icon: Icons.calendar_month_outlined,
              caption:
                  'Vida útil ${project.lifeYears} años · reservas para '
                  '${Formatters.number(project.reserveLifeYears, decimals: 1)} años',
            ),
            KpiCard(
              label: 'Flujo neto acumulado',
              value: Formatters.millions(summary.totalNetFlow, currency),
              icon: Icons.functions,
              color: AppColors.signed(summary.totalNetFlow),
              caption: 'Sin descontar',
            ),
            KpiCard(
              label: 'VAN (flujo descontado)',
              value: Formatters.millions(evaluation.npv, currency),
              icon: Icons.savings_outlined,
              color: AppColors.signed(evaluation.npv),
              caption:
                  'Tasa ${Formatters.percent(project.discountRatePct, decimals: 1)}',
            ),
            KpiCard(
              label: 'Periodo de recuperación',
              value: payback == null ? 'No se recupera' : 'Año $payback',
              icon: Icons.restore,
              color: payback == null ? AppColors.negative : AppColors.finance,
              caption: 'Flujo acumulado sin descontar ≥ 0',
            ),
            KpiCard(
              label: 'Metal recuperado total',
              value: metal.format(summary.totalRecoveredMetal),
              icon: Icons.science_outlined,
              color: AppColors.copper,
            ),
            KpiCard(
              label: 'Margen operativo total',
              value: Formatters.millions(summary.totalMargin, currency),
              icon: Icons.trending_up,
              color: AppColors.signed(summary.totalMargin),
              caption: Formatters.percent(summary.marginPct, decimals: 1),
            ),
            if (project.taxEnabled)
              KpiCard(
                label: 'Impuestos totales',
                value: Formatters.millions(summary.totalTaxes, currency),
                icon: Icons.account_balance_outlined,
                caption: Formatters.percent(project.taxRatePct, decimals: 1),
              ),
          ],
        ),
        SectionHeader(
          title: 'Tabla de flujo económico',
          subtitle:
              'Montos en millones de $currency. Desliza horizontalmente para '
              'ver todas las columnas.',
        ),
        ScrollableTable(
          columns: const [
            'Año',
            'Mineral',
            'Ley',
            'Metal recup.',
            'Ingreso bruto',
            'Regalías',
            'Ingreso neto',
            'Inversión',
            'OPEX',
            'Margen',
            'Impuestos',
            'Cierre',
            'Flujo neto',
            'Factor desc.',
            'Flujo desc.',
            'Acumulado',
            'Acum. desc.',
          ],
          rows: [
            for (final row in rows)
              [
                '${row.period}',
                row.period == 0 ? '—' : Formatters.tonnes(row.tonnes),
                row.period == 0
                    ? '—'
                    : Formatters.grade(
                        row.grade,
                        project.mineralType.gradeUnitLabel,
                      ),
                row.period == 0 ? '—' : metal.format(row.recoveredMetal),
                m(row.grossRevenue),
                m(row.royalty),
                m(row.netRevenue),
                m(-row.capex),
                m(-row.opex),
                m(row.operatingMargin),
                m(-row.taxes),
                m(-row.closure),
                m(row.netFlow),
                Formatters.number(row.discountFactor, decimals: 4),
                m(row.discountedFlow),
                m(row.cumulativeFlow),
                m(row.cumulativeDiscountedFlow),
              ],
          ],
          rowColors: {
            for (var i = 0; i < rows.length; i++)
              if (rows[i].netFlow < 0) i: AppColors.negative,
          },
          highlightedRows: {?payback},
          caption:
              'Egresos con signo negativo. La fila resaltada es el año en que '
              'se recupera la inversión.',
        ),
        ChartCard(
          title: 'Flujo neto por año',
          subtitle: 'Barras rojas: flujos negativos',
          chart: SimpleBarChart(
            values: [for (final row in rows) row.netFlow],
            labels: [for (final row in rows) '${row.period}'],
            color: AppColors.finance,
            negativeColor: AppColors.negative,
          ),
        ),
        ChartCard(
          title: 'Flujo acumulado',
          subtitle: 'La línea roja marca el cero',
          chart: SimpleLineChart(
            labels: [for (final row in rows) '${row.period}'],
            series: _cumulative(),
            referenceValue: 0,
          ),
          series: _cumulative(),
        ),
        FormulaCard(
          title: 'Construcción del flujo',
          formula:
              'Flujo neto (año 0) = −(CAPEX + desarrollo)\n'
              'Margen = ingreso neto − OPEX\n'
              'Impuestos = tasa × (margen − depreciación), si es positivo\n'
              'Flujo neto (año t) = margen − impuestos − cierre\n'
              'Factor de descuento = 1 / (1 + r)^t\n'
              'Flujo descontado = flujo neto × factor de descuento',
          variables: const [
            'r: tasa de descuento anual (fracción).',
            't: año del flujo (0 a n).',
            'Depreciación: inversión / años de operación (lineal).',
          ],
          assumptions: [
            'Evaluación anual en moneda constante (${project.currency}).',
            project.taxEnabled
                ? 'Impuestos simplificados activados al '
                      '${Formatters.percent(project.taxRatePct, decimals: 1)}.'
                : 'Impuestos desactivados: flujo antes de impuestos.',
            'El cierre se paga en el último año de operación.',
            'Sin capital de trabajo, financiamiento ni valor residual.',
          ],
          limitations: const [
            'No considera pérdidas tributarias arrastrables ni otros '
                'tributos específicos de la minería.',
            'No incluye inversiones de sostenimiento ni reemplazo de '
                'equipos.',
          ],
        ),
        InterpretationCard(
          text: payback == null
              ? 'Con estos supuestos el flujo acumulado nunca llega a cero: la '
                    'inversión inicial no se recupera durante la vida del '
                    'proyecto.'
              : 'La inversión se recupera en el año $payback (sin descontar). '
                    'Recuerda que el periodo de recuperación ignora el valor '
                    'del dinero en el tiempo y los flujos posteriores; úsalo '
                    'junto con el VAN y la TIR.',
          color: payback == null ? AppColors.negative : AppColors.positive,
        ),
      ],
    );
  }

  List<ChartSeries> _cumulative() {
    return [
      ChartSeries(
        name: 'Acumulado',
        values: [for (final row in evaluation.rows) row.cumulativeFlow],
        color: AppColors.finance,
      ),
      ChartSeries(
        name: 'Acumulado descontado',
        values: [
          for (final row in evaluation.rows) row.cumulativeDiscountedFlow,
        ],
        color: AppColors.copper,
      ),
    ];
  }
}
