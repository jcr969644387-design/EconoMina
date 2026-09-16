import 'package:flutter/material.dart';

import '../calculators/breakeven_calculator.dart';
import '../calculators/npv_calculator.dart';
import '../calculators/project_evaluator.dart';
import '../models/profitability.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import '../widgets/scrollable_table.dart';
import '../widgets/simple_charts.dart';
import 'module_catalog.dart';

/// Tasas usadas para dibujar el perfil del VAN (en %).
const List<double> npvProfileRates = [0, 2.5, 5, 7.5, 10, 12.5, 15, 20, 25, 30];

/// Módulo 7: valor actual neto.
class NpvScreen extends StatelessWidget {
  const NpvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final evaluation = controller.evaluation;
    return ModuleScaffold(
      title: 'VAN',
      children: [
        const SectionHeader(
          title: 'Valor actual neto (VAN)',
          subtitle:
              'Suma de los flujos traídos al año 0 con la tasa de descuento. '
              'Mide cuánto valor crea el proyecto por encima del rendimiento '
              'exigido.',
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
          _NpvResults(evaluation: evaluation),
      ],
    );
  }
}

class _NpvResults extends StatelessWidget {
  const _NpvResults({required this.evaluation});

  final ProjectEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    const npvCalculator = NpvCalculator();
    final project = evaluation.project;
    final currency = project.currency;
    final flows = evaluation.netFlows;
    final presentValues = npvCalculator.presentValues(
      flows,
      evaluation.discountRate,
    );
    final investment = evaluation.initialInvestment;
    final pvOperation = presentValues.skip(1).fold(0.0, (a, b) => a + b);
    final profile = [
      for (final rate in npvProfileRates)
        npvCalculator.npvFromSeries(flows, rate / 100),
    ];
    final npv = evaluation.npv;
    final color = AppColors.profitability(evaluation.npvClass);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiGrid(
          children: [
            KpiCard(
              label: 'VAN',
              value: Formatters.millions(npv, currency),
              icon: Icons.savings_outlined,
              color: color,
              caption:
                  'Tasa ${Formatters.percent(project.discountRatePct, decimals: 1)}',
            ),
            KpiCard(
              label: 'Inversión inicial (I0)',
              value: Formatters.millions(investment, currency),
              icon: Icons.foundation,
              color: AppColors.copper,
            ),
            KpiCard(
              label: 'Valor presente de los flujos 1..n',
              value: Formatters.millions(pvOperation, currency),
              icon: Icons.history_toggle_off,
              color: AppColors.finance,
            ),
            KpiCard(
              label: 'Índice VAN / inversión',
              value: investment == 0
                  ? '—'
                  : Formatters.percent(npv / investment * 100, decimals: 1),
              icon: Icons.percent,
              caption: 'Valor creado por cada unidad invertida',
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ProfitabilityIndicator(label: 'VAN', value: evaluation.npvClass),
            ],
          ),
        ),
        RiskIndicator(
          level: evaluation.risk,
          explanation:
              'VAN del escenario pesimista: '
              '${Formatters.millions(evaluation.pessimisticNpv, currency)}. '
              'Riesgo alto si el VAN base es negativo; medio si solo el '
              'pesimista es negativo; bajo si ambos son positivos.',
        ),
        _BreakevenSection(evaluation: evaluation),
        const SectionHeader(title: 'Valor presente por año'),
        ScrollableTable(
          columns: [
            'Año',
            'Flujo neto ($currency M)',
            'Factor 1/(1+r)^t',
            'Valor presente ($currency M)',
          ],
          rows: [
            for (var t = 0; t < flows.length; t++)
              [
                '$t',
                Formatters.number(flows[t] / 1e6),
                Formatters.number(
                  evaluation.rows[t].discountFactor,
                  decimals: 4,
                ),
                Formatters.number(presentValues[t] / 1e6),
              ],
            ['VAN', '', '', Formatters.number(npv / 1e6)],
          ],
          highlightedRows: {flows.length},
        ),
        ChartCard(
          title: 'Perfil del VAN según la tasa de descuento',
          subtitle:
              'Eje horizontal: tasa (%). Donde la curva cruza el cero está la '
              'TIR.',
          chart: SimpleLineChart(
            labels: [
              for (final rate in npvProfileRates) Formatters.plain(rate),
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
          title: 'Fórmula del VAN',
          formula: 'VAN = Σ [FCt / (1 + r)^t] − I0,  t = 1 … n',
          variables: [
            'FCt: flujo de caja neto del año t.',
            'r: tasa de descuento anual (fracción).',
            'I0: inversión inicial en el año 0.',
            'n: años de operación.',
          ],
          assumptions: [
            'La tasa de descuento es constante y refleja el costo de '
                'oportunidad y el riesgo del proyecto.',
            'Los flujos ocurren al final de cada año.',
          ],
          limitations: [
            'El VAN depende fuertemente de la tasa elegida.',
            'No incorpora la flexibilidad de gestión (opciones reales).',
          ],
        ),
        InterpretationCard(
          text: switch (evaluation.npvClass) {
            Profitability.atractivo =>
              'VAN positivo: bajo los supuestos ingresados, el proyecto '
                  'recupera la inversión, paga la tasa exigida de '
                  '${Formatters.percent(project.discountRatePct, decimals: 1)} '
                  'y además genera ${Formatters.millions(npv, currency)} de '
                  'valor adicional en moneda del año 0.',
            Profitability.indiferente =>
              'VAN cercano a cero: el proyecto apenas paga la tasa exigida. '
                  'Pequeños cambios en precio o costos pueden volverlo '
                  'negativo; se requiere más estudio.',
            Profitability.noAtractivo =>
              'VAN negativo: bajo los supuestos ingresados, los flujos '
                  'descontados no alcanzan para recuperar la inversión con la '
                  'tasa exigida. El proyecto destruiría '
                  '${Formatters.millions(-npv, currency)} de valor.',
          },
          color: color,
        ),
      ],
    );
  }
}

/// Precio y ley que hacen VAN = 0, con su margen de seguridad.
class _BreakevenSection extends StatelessWidget {
  const _BreakevenSection({required this.evaluation});

  final ProjectEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    const calculator = BreakevenCalculator();
    final project = evaluation.project;
    final mineral = project.mineralType;
    final currency = project.currency;
    final price = calculator.price(project);
    final grade = calculator.grade(project);
    final priceValue = price.value;
    final gradeValue = grade.value;
    final margin = price.safetyMarginPct;

    String marginText(double? value) => value == null
        ? 'No disponible'
        : 'Margen de seguridad: ${Formatters.percent(value, decimals: 1)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Puntos de equilibrio (VAN = 0)',
          subtitle:
              'Valor mínimo de cada variable para que el proyecto pague la '
              'tasa exigida, manteniendo el resto de datos.',
        ),
        KpiGrid(
          children: [
            KpiCard(
              key: const Key('breakeven-price'),
              label: 'Precio de equilibrio',
              value: priceValue == null
                  ? 'No existe'
                  : '${Formatters.number(priceValue, decimals: 3)} '
                        '${mineral.priceUnitLabel(currency)}',
              icon: Icons.price_check,
              color: AppColors.finance,
              caption: priceValue == null
                  ? price.message
                  : 'Actual: ${Formatters.number(project.metalPrice)} · '
                        '${marginText(price.safetyMarginPct)}',
            ),
            KpiCard(
              key: const Key('breakeven-grade'),
              label: 'Ley de equilibrio',
              value: gradeValue == null
                  ? 'No existe'
                  : Formatters.grade(gradeValue, mineral.gradeUnitLabel),
              icon: Icons.landscape_outlined,
              color: AppColors.copper,
              caption: gradeValue == null
                  ? grade.message
                  : 'Actual: ${Formatters.grade(project.averageGrade, mineral.gradeUnitLabel)} · '
                        '${marginText(grade.safetyMarginPct)}',
            ),
          ],
        ),
        if (margin != null)
          InterpretationCard(
            title: 'Lectura del margen de seguridad',
            text: margin >= 0
                ? 'El precio puede caer hasta '
                      '${Formatters.percent(margin, decimals: 1)} antes de que '
                      'el VAN sea negativo. '
                      '${margin < 15 ? 'Es un margen estrecho: el proyecto es sensible al precio.' : 'Es un margen holgado frente a variaciones de precio.'}'
                : 'El precio actual está por debajo del equilibrio: se '
                      'necesita un aumento de '
                      '${Formatters.percent(-margin, decimals: 1)} para '
                      'alcanzar VAN = 0.',
            color: margin >= 15
                ? AppColors.positive
                : margin >= 0
                ? AppColors.neutral
                : AppColors.negative,
          ),
      ],
    );
  }
}
