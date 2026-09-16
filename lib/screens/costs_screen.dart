import 'package:flutter/material.dart';

import '../calculators/cash_flow_calculator.dart';
import '../calculators/cost_calculator.dart';
import '../calculators/production_calculator.dart';
import '../models/mining_costs.dart';
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

/// Módulo 3: costos mineros.
class CostsScreen extends StatelessWidget {
  const CostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final project = controller.project;
    final validation = controller.validation;
    return ModuleScaffold(
      title: 'Costos mineros',
      children: [
        const SectionHeader(
          title: 'Estructura de costos',
          subtitle:
              'CAPEX: inversión antes de producir. OPEX: costos recurrentes de '
              'operación (variables por tonelada y fijos por año).',
        ),
        KeyedSubtree(
          key: ObjectKey(project),
          child: _CostsForm(project: project),
        ),
        if (!validation.isValid)
          InvalidProjectNotice(
            result: validation,
            onFix: () => openProjectData(context),
          )
        else
          _CostResults(project: project),
      ],
    );
  }
}

class _CostsForm extends StatefulWidget {
  const _CostsForm({required this.project});

  final ProjectData project;

  @override
  State<_CostsForm> createState() => _CostsFormState();
}

class _CostsFormState extends State<_CostsForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;

  static const List<(String, String, String, String)> _investmentFields = [
    (
      'capex',
      'Inversión inicial (CAPEX)',
      'total',
      'Equipos, planta e '
          'infraestructura.',
    ),
    (
      'development',
      'Costos de desarrollo',
      'total',
      'Preparación de la mina '
          'antes de producir; se suma a la inversión.',
    ),
    (
      'closure',
      'Costos de cierre',
      'total',
      'Se pagan en el último año de '
          'operación.',
    ),
  ];

  static const List<(String, String, String, String)> _variableFields = [
    ('drilling', 'Perforación', 'por t', 'Costo de perforación.'),
    ('blasting', 'Voladura', 'por t', 'Explosivos y accesorios.'),
    (
      'loadHaul',
      'Carguío y transporte',
      'por t',
      'Palas, cargadores y '
          'camiones.',
    ),
    (
      'extraction',
      'Extracción (otros costos mina)',
      'por t',
      'Servicios '
          'auxiliares, drenaje, sostenimiento.',
    ),
    (
      'processing',
      'Procesamiento',
      'por t',
      'Chancado, molienda y '
          'concentración.',
    ),
    (
      'maintenance',
      'Mantenimiento',
      'por t',
      'Mantenimiento de equipos e '
          'instalaciones.',
    ),
    (
      'otherVariable',
      'Otros costos variables',
      'por t',
      'Energía, agua u '
          'otros insumos variables.',
    ),
  ];

  static const List<(String, String, String, String)> _fixedFields = [
    (
      'administrative',
      'Costos administrativos',
      'por año',
      'Gerencia, '
          'oficinas y servicios generales.',
    ),
    (
      'otherFixed',
      'Otros costos fijos',
      'por año',
      'Seguros, vigilancia, '
          'relaciones comunitarias.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.project.costs;
    final values = <String, double>{
      'capex': c.capex,
      'development': c.developmentCost,
      'closure': c.closureCost,
      'drilling': c.drillingCost,
      'blasting': c.blastingCost,
      'loadHaul': c.loadHaulCost,
      'extraction': c.extractionCost,
      'processing': c.processingCost,
      'maintenance': c.maintenanceCost,
      'otherVariable': c.otherVariableCost,
      'administrative': c.administrativeCost,
      'otherFixed': c.otherFixedCost,
    };
    _fields = {
      for (final entry in values.entries)
        entry.key: TextEditingController(text: Formatters.plain(entry.value)),
    };
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

  void _apply() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revisa los costos: no se permiten valores negativos ni vacíos.',
          ),
        ),
      );
      return;
    }
    final costs = MiningCosts(
      capex: _read('capex'),
      developmentCost: _read('development'),
      drillingCost: _read('drilling'),
      blastingCost: _read('blasting'),
      loadHaulCost: _read('loadHaul'),
      extractionCost: _read('extraction'),
      processingCost: _read('processing'),
      maintenanceCost: _read('maintenance'),
      otherVariableCost: _read('otherVariable'),
      administrativeCost: _read('administrative'),
      otherFixedCost: _read('otherFixed'),
      closureCost: _read('closure'),
    );
    final result = ProjectScope.read(
      context,
    ).updateProject(widget.project.copyWith(costs: costs));
    final message = result.isValid
        ? 'Costos aplicados al proyecto.'
        : 'No se aplicaron los costos: ${result.errors.join(' ')}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Widget> _group(List<(String, String, String, String)> fields) {
    final currency = widget.project.currency;
    return [
      for (final field in fields)
        NumberInputField(
          controller: _fields[field.$1]!,
          label: field.$2,
          unit: field.$3 == 'total'
              ? currency
              : field.$3 == 'por t'
              ? '$currency/t'
              : '$currency/año',
          helpText: field.$4,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: false,
            title: const Text('Editar costos del proyecto'),
            subtitle: const Text('Toca para abrir el formulario.'),
            children: [
              const SectionHeader(title: 'Inversión y cierre'),
              ..._group(_investmentFields),
              const SectionHeader(
                title: 'Costos variables',
                subtitle: 'Dependen de las toneladas tratadas.',
              ),
              ..._group(_variableFields),
              const SectionHeader(
                title: 'Costos fijos',
                subtitle: 'No dependen del tonelaje tratado.',
              ),
              ..._group(_fixedFields),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: context.onButton(_apply),
                  icon: const Icon(Icons.check),
                  label: const Text('Aplicar costos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostResults extends StatelessWidget {
  const _CostResults({required this.project});

  final ProjectData project;

  @override
  Widget build(BuildContext context) {
    const costs = CostCalculator();
    const production = ProductionCalculator();
    const cashFlow = CashFlowCalculator();
    final c = project.costs;
    final currency = project.currency;
    final tonnes = project.annualProductionTonnes;
    final years = cashFlow.operatingYears(project);
    final metal = MetalDisplay.of(project.mineralType);
    final unit = project.mineralType.metalUnit;

    try {
      final contained = production.containedMetal(
        tonnes: tonnes,
        grade: project.averageGrade,
        conversionFactor: project.mineralType.conversionFactor,
      );
      final recovered = production.recoveredMetal(
        containedMetal: contained,
        recoveryPct: project.recoveryPct,
      );
      final opex = costs.annualOperatingCost(c, tonnes);
      final totalAnnual = costs.totalAnnualCost(c, tonnes, years);
      final unitCost = costs.unitCost(c, tonnes);
      final perMetal = costs.costPerMetalUnit(c, tonnes, recovered);
      final totalOpex = costs.totalOperatingCost(c, tonnes, years);
      final distribution = costs.distribution(c, tonnes);
      final variableShare = opex == 0
          ? 0.0
          : costs.annualVariableCost(c, tonnes) / opex;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Resultados',
            subtitle: 'Calculados con el proyecto aplicado (escenario base).',
          ),
          KpiGrid(
            children: [
              KpiCard(
                label: 'Costo total anual',
                value: Formatters.millions(totalAnnual, currency),
                icon: Icons.account_balance_wallet_outlined,
                caption: 'OPEX + (inversión + cierre) / $years años',
              ),
              KpiCard(
                label: 'Costo unitario',
                value: Formatters.money(unitCost, currency),
                icon: Icons.scale_outlined,
                caption: 'por tonelada tratada',
              ),
              KpiCard(
                label: 'Costo por unidad de metal',
                value: Formatters.money(perMetal, currency),
                icon: Icons.monetization_on_outlined,
                caption: 'por $unit recuperada(o)',
              ),
              KpiCard(
                label: 'OPEX anual',
                value: Formatters.millions(opex, currency),
                icon: Icons.autorenew,
                caption: '${Formatters.tonnes(tonnes)} por año',
              ),
              KpiCard(
                label: 'Costo operativo total',
                value: Formatters.millions(totalOpex, currency),
                icon: Icons.functions,
                caption: '$years años de operación',
              ),
              KpiCard(
                label: 'Inversión inicial',
                value: Formatters.millions(c.initialInvestment, currency),
                icon: Icons.foundation,
                color: AppColors.copper,
                caption: 'CAPEX + desarrollo',
              ),
            ],
          ),
          const SectionHeader(title: 'Distribución porcentual del OPEX'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (final item in distribution)
                    LabeledProgress(
                      label:
                          '${item.label} (${item.isFixed ? 'fijo' : 'variable'})',
                      value: item.percent / 100,
                      trailing: Formatters.percent(item.percent, decimals: 1),
                      color: item.isFixed
                          ? AppColors.finance
                          : AppColors.copper,
                    ),
                  const Divider(),
                  LabeledProgress(
                    label: 'Participación de costos variables',
                    value: variableShare,
                    trailing: Formatters.percent(
                      variableShare * 100,
                      decimals: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ChartCard(
            title: 'OPEX anual por partida',
            subtitle: 'Montos en $currency por año',
            chart: SimpleBarChart(
              values: [for (final item in distribution) item.annualAmount],
              labels: [
                for (final item in distribution) item.label.split(' ').first,
              ],
              color: AppColors.copper,
            ),
          ),
          ScrollableTable(
            columns: const ['Partida', 'Tipo', 'Monto anual', '% del OPEX'],
            rows: [
              for (final item in distribution)
                [
                  item.label,
                  item.isFixed ? 'Fijo' : 'Variable',
                  Formatters.money(item.annualAmount, currency, decimals: 0),
                  Formatters.percent(item.percent, decimals: 1),
                ],
              [
                'Total OPEX',
                '',
                Formatters.money(opex, currency, decimals: 0),
                '100.0 %',
              ],
            ],
            highlightedRows: {distribution.length},
          ),
          const SectionHeader(title: 'Datos ingresados'),
          ScrollableTable(
            columns: const ['Concepto', 'Valor', 'Unidad'],
            rows: [
              [
                'Inversión (CAPEX + desarrollo)',
                Formatters.number(c.initialInvestment, decimals: 0),
                currency,
              ],
              [
                'Cierre',
                Formatters.number(c.closureCost, decimals: 0),
                currency,
              ],
              [
                'Costo de mina',
                Formatters.number(c.miningUnitCost),
                '$currency/t',
              ],
              [
                'Costo variable total',
                Formatters.number(c.variableUnitCost),
                '$currency/t',
              ],
              [
                'Costos fijos',
                Formatters.number(c.annualFixedCost, decimals: 0),
                '$currency/año',
              ],
              ['Metal recuperado anual', metal.format(recovered), unit],
            ],
          ),
          const FormulaCard(
            title: 'Fórmulas de costos',
            formula:
                'OPEX anual = (costo variable unitario × t) + costos fijos\n'
                'Costo unitario = OPEX anual / t tratadas\n'
                'Costo por unidad de metal = OPEX anual / metal recuperado\n'
                'Costo total anual = OPEX anual + (I0 + cierre) / años\n'
                'Costo operativo total = OPEX anual × años de operación',
            variables: [
              't: toneladas tratadas por año (t/año).',
              'I0: inversión inicial = CAPEX + desarrollo (moneda).',
              'Costos variables en moneda/t; costos fijos en moneda/año.',
            ],
            assumptions: [
              'Costos constantes durante toda la vida del proyecto.',
              'El costo total anual reparte la inversión y el cierre en '
                  'partes iguales, sin descontar.',
            ],
            limitations: [
              'No distingue costos de mina por banco, distancia o '
                  'profundidad.',
              'No considera economías de escala ni inflación de costos.',
            ],
          ),
          InterpretationCard(
            text:
                'Cada tonelada tratada cuesta '
                '${Formatters.money(unitCost, currency)} y cada $unit '
                'recuperada cuesta ${Formatters.money(perMetal, currency)}. '
                'Compáralo con el precio de '
                '${Formatters.money(project.metalPrice, currency)}/$unit: '
                '${perMetal < project.metalPrice ? 'el precio cubre el costo operativo por unidad.' : 'el precio NO cubre el costo operativo por unidad.'}',
            color: perMetal < project.metalPrice
                ? AppColors.positive
                : AppColors.negative,
          ),
        ],
      );
    } on ArgumentError catch (error) {
      return InterpretationCard(
        title: 'No se puede calcular',
        text: '${error.message}',
        color: AppColors.negative,
      );
    }
  }
}
