import 'package:flutter/material.dart';

import '../calculators/cutoff_grade_calculator.dart';
import '../models/cutoff_models.dart';
import '../models/project_data.dart';
import '../services/feedback_actions.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/number_parser.dart';
import '../widgets/info_widgets.dart';
import '../widgets/number_input_field.dart';
import '../widgets/result_widgets.dart';
import '../widgets/scrollable_table.dart';
import '../widgets/simple_charts.dart';
import 'module_catalog.dart';

/// Módulo 4: ley de corte con un modelo educativo configurable.
class CutoffScreen extends StatelessWidget {
  const CutoffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = ProjectScope.of(context).project;
    return ModuleScaffold(
      title: 'Ley de corte',
      children: [
        const SectionHeader(
          title: '¿Qué es la ley de corte?',
          subtitle:
              'Es la ley mínima que debe tener el material para que su valor '
              'recuperable cubra los costos considerados. El material por '
              'debajo de ella se trata como desmonte.',
        ),
        KeyedSubtree(
          key: ObjectKey(project),
          child: _CutoffBody(project: project),
        ),
      ],
    );
  }
}

class _CutoffBody extends StatefulWidget {
  const _CutoffBody({required this.project});

  final ProjectData project;

  @override
  State<_CutoffBody> createState() => _CutoffBodyState();
}

class _CutoffBodyState extends State<_CutoffBody> {
  static const CutoffGradeCalculator _calculator = CutoffGradeCalculator();

  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  late CutoffInput _input;
  CutoffMethod _method = CutoffMethod.equilibrio;
  CutoffResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _input = _calculator.fromProject(widget.project);
    _fields = {
      'price': _controller(_input.metalPrice),
      'recovery': _controller(_input.recoveryPct),
      'mining': _controller(_input.miningCost),
      'processing': _controller(_input.processingCost),
      'general': _controller(_input.generalCost),
      'royalty': _controller(_input.royaltyPct),
      'selling': _controller(_input.sellingCost),
      'payable': _controller(_input.payablePct),
    };
    _compute(_input);
  }

  TextEditingController _controller(double value) {
    final rounded = double.parse(value.toStringAsFixed(4));
    return TextEditingController(text: Formatters.plain(rounded));
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _read(String key) =>
      NumberParser.parse(_fields[key]!.text) ?? double.nan;

  void _calculate({bool showMessage = true}) {
    final valid = _formKey.currentState?.validate() ?? true;
    if (!valid) {
      setState(() {
        _result = null;
        _error = 'Revisa los datos marcados en el formulario.';
      });
      return;
    }
    final input = CutoffInput(
      metalPrice: _read('price'),
      recoveryPct: _read('recovery'),
      miningCost: _read('mining'),
      processingCost: _read('processing'),
      generalCost: _read('general'),
      royaltyPct: _read('royalty'),
      sellingCost: _read('selling'),
      payablePct: _read('payable'),
      conversionFactor: widget.project.mineralType.conversionFactor,
      gradeUnit: widget.project.mineralType.gradeUnitLabel,
      metalUnit: widget.project.mineralType.metalUnit,
      method: _method,
    );
    setState(() => _compute(input));
    if (showMessage && _error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    }
  }

  /// Calcula sin reconstruir (se usa dentro de initState y setState).
  void _compute(CutoffInput input) {
    _input = input;
    try {
      _result = _calculator.calculate(input);
      _error = null;
    } on ArgumentError catch (error) {
      _result = null;
      _error = '${error.message}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final currency = project.currency;
    final mineral = project.mineralType;
    final result = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mineral: ${mineral.label} · ley en '
                    '${mineral.gradeUnitLabel} · precio en '
                    '${mineral.priceUnitLabel(currency)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<CutoffMethod>(
                    segments: const [
                      ButtonSegment(
                        value: CutoffMethod.equilibrio,
                        label: Text('Equilibrio'),
                      ),
                      ButtonSegment(
                        value: CutoffMethod.marginal,
                        label: Text('Marginal'),
                      ),
                    ],
                    selected: {_method},
                    showSelectedIcon: false,
                    onSelectionChanged: context.onSelection((
                      Set<CutoffMethod> selection,
                    ) {
                      _method = selection.first;
                      _calculate(showMessage: false);
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _method.explanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  NumberInputField(
                    controller: _fields['price']!,
                    label: 'Precio del metal',
                    unit: mineral.priceUnitLabel(currency),
                    allowZero: false,
                  ),
                  NumberInputField(
                    controller: _fields['recovery']!,
                    label: 'Recuperación metalúrgica',
                    unit: '%',
                    max: 100,
                    allowZero: false,
                  ),
                  NumberInputField(
                    controller: _fields['mining']!,
                    label: 'Costo de mina',
                    unit: '$currency/t',
                    helpText: 'Perforación, voladura, carguío y extracción.',
                  ),
                  NumberInputField(
                    controller: _fields['processing']!,
                    label: 'Costo de procesamiento',
                    unit: '$currency/t',
                  ),
                  NumberInputField(
                    controller: _fields['general']!,
                    label: 'Costos generales y administrativos',
                    unit: '$currency/t',
                    helpText:
                        'Incluye mantenimiento, otros variables y fijos '
                        'repartidos por tonelada.',
                  ),
                  NumberInputField(
                    controller: _fields['royalty']!,
                    label: 'Regalías',
                    unit: '%',
                    max: 99,
                  ),
                  NumberInputField(
                    controller: _fields['selling']!,
                    label: 'Costo de venta o refinación',
                    unit: mineral.priceUnitLabel(currency),
                  ),
                  NumberInputField(
                    controller: _fields['payable']!,
                    label: 'Contenido pagable',
                    unit: '%',
                    max: 100,
                    allowZero: false,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: context.onButton(_calculate),
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Calcular ley de corte'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_error != null)
          InterpretationCard(
            title: 'No se puede calcular',
            text: _error!,
            color: AppColors.negative,
          ),
        if (result != null) ..._results(result),
        const FormulaCard(
          title: 'Modelo simplificado de ley de corte',
          formula:
              'Ley de corte = C / (Pn × R × F)\n'
              'Pn = (P − costo de venta) × pagable × (1 − regalía)',
          variables: [
            'C: costos considerados por tonelada (equilibrio: mina + '
                'procesamiento + generales; marginal: sin costo de mina).',
            'P: precio del metal; Pn: precio neto por unidad pagable.',
            'R: recuperación metalúrgica (fracción).',
            'F: factor de conversión (22.0462 lb por t y % para metales '
                'base; 1/31.1035 oz por t y g/t para metales preciosos).',
          ],
          assumptions: [
            'Precio, recuperación y costos constantes.',
            'Costos fijos repartidos entre la producción anual.',
          ],
          limitations: [
            'Una ley de corte profesional considera además restricciones de '
                'capacidad, costos incrementales, planificación minera, '
                'dilución, pérdidas, impuestos y el valor del dinero en el '
                'tiempo.',
            'No optimiza la secuencia de extracción (por ejemplo, el método '
                'de Lane).',
          ],
        ),
      ],
    );
  }

  List<Widget> _results(CutoffResult result) {
    final project = widget.project;
    final currency = project.currency;
    final unit = project.mineralType.gradeUnitLabel;
    final metalUnit = project.mineralType.metalUnit;
    final aboveCutoff = project.averageGrade > result.cutoffGrade;
    final sensitivity = _calculator.sensitivity(_input);
    String cell(double value) =>
        value.isNaN ? 'No calculable' : Formatters.grade(value, unit);

    return [
      const SectionHeader(title: 'Resultado'),
      KpiGrid(
        children: [
          KpiCard(
            label:
                'Ley de corte (${_method == CutoffMethod.equilibrio ? 'equilibrio' : 'marginal'})',
            value: Formatters.grade(result.cutoffGrade, unit),
            icon: Icons.filter_alt_outlined,
            color: AppColors.copper,
          ),
          KpiCard(
            label: 'Ley promedio del proyecto',
            value: Formatters.grade(project.averageGrade, unit),
            icon: Icons.landscape_outlined,
            color: aboveCutoff ? AppColors.positive : AppColors.negative,
          ),
          KpiCard(
            label: 'Costos considerados',
            value: Formatters.money(result.costPerTonne, currency),
            icon: Icons.payments_outlined,
            caption: 'por tonelada',
          ),
          KpiCard(
            label: 'Precio neto',
            value: Formatters.money(result.netPricePerUnit, currency),
            icon: Icons.sell_outlined,
            caption: 'por $metalUnit pagable',
          ),
          KpiCard(
            label: 'Valor por unidad de ley',
            value: Formatters.money(result.valuePerGradeUnit, currency),
            icon: Icons.stacked_line_chart,
            caption: 'por t y por 1 $unit',
          ),
        ],
      ),
      InterpretationCard(
        text: aboveCutoff
            ? 'La ley promedio (${Formatters.grade(project.averageGrade, unit)}) '
                  'supera la ley de corte '
                  '(${Formatters.grade(result.cutoffGrade, unit)}): en promedio, '
                  'el material cubre los costos considerados. Los bloques con '
                  'ley menor a la de corte no pagarían su tratamiento.'
            : 'La ley promedio (${Formatters.grade(project.averageGrade, unit)}) '
                  'no supera la ley de corte '
                  '(${Formatters.grade(result.cutoffGrade, unit)}): en promedio, '
                  'el material no cubre los costos considerados con estos '
                  'supuestos.',
        color: aboveCutoff ? AppColors.positive : AppColors.negative,
      ),
      const SectionHeader(
        title: 'Sensibilidad de la ley de corte',
        subtitle:
            'Cada columna cambia una sola variable. Precio y recuperación '
            'más altos bajan la ley de corte; costos más altos la suben.',
      ),
      ScrollableTable(
        columns: const [
          'Variación',
          'Por precio',
          'Por recuperación',
          'Por costos',
        ],
        rows: [
          for (final row in sensitivity)
            [
              '${row.changePct > 0 ? '+' : ''}${row.changePct.toStringAsFixed(0)} %',
              cell(row.byPrice),
              cell(row.byRecovery),
              cell(row.byCost),
            ],
        ],
        highlightedRows: {
          for (var i = 0; i < sensitivity.length; i++)
            if (sensitivity[i].changePct == 0) i,
        },
        caption:
            'La recuperación se limita a 100 %. "No calculable" indica que '
            'el precio neto no supera los costos de venta.',
      ),
      ChartCard(
        title: 'Ley de corte según la variación',
        subtitle: 'Eje horizontal: variación aplicada (%)',
        chart: SimpleLineChart(
          labels: [
            for (final row in sensitivity) row.changePct.toStringAsFixed(0),
          ],
          series: _chartSeries(sensitivity),
        ),
        series: _chartSeries(sensitivity),
      ),
    ];
  }

  List<ChartSeries> _chartSeries(List<CutoffSensitivityRow> rows) {
    // Los valores no calculables (NaN) se omiten al dibujar.
    List<double> clean(Iterable<double> values) => values.toList();
    return [
      ChartSeries(
        name: 'Precio',
        values: clean(rows.map((row) => row.byPrice)),
        color: AppColors.copper,
      ),
      ChartSeries(
        name: 'Recuperación',
        values: clean(rows.map((row) => row.byRecovery)),
        color: AppColors.seed,
      ),
      ChartSeries(
        name: 'Costos',
        values: clean(rows.map((row) => row.byCost)),
        color: AppColors.finance,
      ),
    ];
  }
}
