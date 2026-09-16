import 'dart:async';

import 'package:flutter/material.dart';

import '../models/mineral_type.dart';
import '../models/project_data.dart';
import '../models/validation_result.dart';
import '../services/feedback_actions.dart';
import '../services/feedback_service.dart';
import '../services/project_scope.dart';
import '../services/validation_service.dart';
import '../utils/formatters.dart';
import '../utils/number_parser.dart';
import '../utils/validators.dart';
import '../widgets/info_widgets.dart';
import '../widgets/number_input_field.dart';
import '../widgets/result_widgets.dart';
import 'module_catalog.dart';

/// Módulo 2: datos generales del proyecto.
class ProjectDataScreen extends StatelessWidget {
  const ProjectDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final project = controller.project;
    return ModuleScaffold(
      title: 'Datos del proyecto',
      actions: [
        IconButton(
          tooltip: 'Restaurar proyecto de ejemplo',
          icon: const Icon(Icons.refresh),
          onPressed: context.onButton(() {
            ProjectScope.read(context).resetProject();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se restauró el proyecto de ejemplo.'),
              ),
            );
          }),
        ),
      ],
      children: [
        const SectionHeader(
          title: 'Datos generales',
          subtitle:
              'Ingresa los datos y pulsa "Validar y aplicar". Todos los '
              'módulos usarán el proyecto aplicado.',
        ),
        ValidationPanel(result: controller.validation),
        KeyedSubtree(
          key: ObjectKey(project),
          child: _ProjectForm(project: project),
        ),
        const SizedBox(height: 8),
        const FormulaCard(
          title: 'Relaciones usadas por el simulador',
          formula:
              'Capacidad anual = capacidad (t/día) × días de operación\n'
              'Años de reservas = reservas (t) / producción anual (t/año)\n'
              'Años de operación = mín(vida útil, años de reservas)',
          assumptions: [
            'Periodo de evaluación anual; el año 0 concentra la inversión.',
            'Precio, ley, recuperación y costos constantes (valores reales).',
            'Las reservas se agotan al ritmo de la producción anual.',
            'La regalía se aplica sobre el ingreso bruto.',
            'Los impuestos simplificados solo se aplican si se activan.',
          ],
          limitations: [
            'No modela inflación, capital de trabajo ni financiamiento.',
            'No modela dilución, pérdidas ni variación de la ley en el '
                'tiempo.',
            'Los datos de ejemplo son ficticios.',
          ],
        ),
      ],
    );
  }
}

class _ProjectForm extends StatefulWidget {
  const _ProjectForm({required this.project});

  final ProjectData project;

  @override
  State<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<_ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _life;
  late final TextEditingController _rate;
  late final TextEditingController _price;
  late final TextEditingController _reserves;
  late final TextEditingController _grade;
  late final TextEditingController _recovery;
  late final TextEditingController _production;
  late final TextEditingController _capacity;
  late final TextEditingController _days;
  late final TextEditingController _royalty;
  late final TextEditingController _taxRate;
  late String _currency;
  late MineralType _mineral;
  late bool _taxEnabled;
  ValidationResult? _lastAttempt;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _name = TextEditingController(text: p.name);
    _life = TextEditingController(text: '${p.lifeYears}');
    _rate = TextEditingController(text: Formatters.plain(p.discountRatePct));
    _price = TextEditingController(text: Formatters.plain(p.metalPrice));
    _reserves = TextEditingController(text: Formatters.plain(p.reservesTonnes));
    _grade = TextEditingController(text: Formatters.plain(p.averageGrade));
    _recovery = TextEditingController(text: Formatters.plain(p.recoveryPct));
    _production = TextEditingController(
      text: Formatters.plain(p.annualProductionTonnes),
    );
    _capacity = TextEditingController(
      text: Formatters.plain(p.plantCapacityTpd),
    );
    _days = TextEditingController(text: '${p.operatingDaysPerYear}');
    _royalty = TextEditingController(text: Formatters.plain(p.royaltyPct));
    _taxRate = TextEditingController(text: Formatters.plain(p.taxRatePct));
    _currency = p.currency;
    _mineral = p.mineralType;
    _taxEnabled = p.taxEnabled;
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _life,
      _rate,
      _price,
      _reserves,
      _grade,
      _recovery,
      _production,
      _capacity,
      _days,
      _royalty,
      _taxRate,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double _value(TextEditingController controller) =>
      NumberParser.parse(controller.text) ?? double.nan;

  int _intValue(TextEditingController controller) {
    final value = NumberParser.parse(controller.text);
    if (value == null) {
      return 0;
    }
    return value.round();
  }

  ProjectData _draft() {
    return widget.project.copyWith(
      name: _name.text.trim(),
      currency: _currency,
      lifeYears: _intValue(_life),
      discountRatePct: _value(_rate),
      metalPrice: _value(_price),
      mineralType: _mineral,
      reservesTonnes: _value(_reserves),
      averageGrade: _value(_grade),
      recoveryPct: _value(_recovery),
      annualProductionTonnes: _value(_production),
      plantCapacityTpd: _value(_capacity),
      operatingDaysPerYear: _intValue(_days),
      royaltyPct: _value(_royalty),
      taxEnabled: _taxEnabled,
      taxRatePct: _value(_taxRate),
    );
  }

  /// Vibración y sonido según lo que acaba de ocurrir.
  void _feedback(FeedbackEvent event) {
    unawaited(ProjectScope.read(context).playFeedback(event));
  }

  void _apply() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final draft = _draft();
    if (!formValid) {
      setState(() {
        _lastAttempt = const ValidationService().validateProject(draft);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos marcados en rojo.')),
      );
      _feedback(FeedbackEvent.error);
      return;
    }
    final result = ProjectScope.read(context).updateProject(draft);
    if (result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos aplicados. Los resultados se actualizaron.'),
        ),
      );
      _feedback(FeedbackEvent.logro);
    } else {
      setState(() => _lastAttempt = result);
      _feedback(FeedbackEvent.error);
    }
  }

  void _useReferenceValues() {
    setState(() {
      _price.text = Formatters.plain(_mineral.referencePrice);
      _grade.text = Formatters.plain(_mineral.referenceGrade);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attempt = _lastAttempt;
    final production = NumberParser.parse(_production.text) ?? 0;
    final reserves = NumberParser.parse(_reserves.text) ?? 0;
    final capacity = NumberParser.parse(_capacity.text) ?? 0;
    final days = NumberParser.parse(_days.text) ?? 0;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (attempt != null && !attempt.isValid) ...[
            const SectionHeader(title: 'No se aplicaron los datos'),
            ValidationPanel(result: attempt),
          ],
          const SectionHeader(title: 'Identificación'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: _name,
              onTap: () => context.emitFeedback(FeedbackEvent.seleccion),
              decoration: const InputDecoration(
                labelText: 'Nombre del proyecto',
                helperText: 'Nombre descriptivo del proyecto ficticio.',
                border: OutlineInputBorder(),
              ),
              validator: Validators.requiredText,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
          _DropdownField<String>(
            label: 'Moneda de análisis',
            helper: 'Todos los montos se expresan en esta moneda.',
            value: _currency,
            items: {
              for (final currency in ProjectData.supportedCurrencies)
                currency: currency == 'USD'
                    ? 'USD (dólar estadounidense)'
                    : 'PEN (sol peruano)',
            },
            onChanged: (value) => setState(() => _currency = value),
          ),
          const _InfoField(
            label: 'Periodo de evaluación',
            value: '${ProjectData.evaluationPeriod} (año 0 = inversión)',
          ),
          NumberInputField(
            controller: _life,
            label: 'Vida útil del proyecto',
            unit: 'años',
            helpText: 'Años máximos de operación (1 a 60).',
            min: 1,
            max: ValidationService.maxLifeYears.toDouble(),
            integer: true,
          ),
          NumberInputField(
            controller: _rate,
            label: 'Tasa de descuento',
            unit: '% anual',
            helpText: 'Rentabilidad mínima exigida al proyecto (0 a 100 %).',
            max: 100,
          ),
          const SectionHeader(title: 'Mineral y mercado'),
          _DropdownField<MineralType>(
            label: 'Tipo de mineral',
            helper: _mineral.conversionExplanation,
            value: _mineral,
            items: {for (final type in MineralType.values) type: type.label},
            onChanged: (value) => setState(() => _mineral = value),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: context.onButton(_useReferenceValues),
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Usar precio y ley de referencia'),
            ),
          ),
          NumberInputField(
            controller: _price,
            label: 'Precio del mineral',
            unit: _mineral.priceUnitLabel(_currency),
            helpText: 'Precio por unidad de metal pagable (mayor que cero).',
            allowZero: false,
          ),
          NumberInputField(
            controller: _royalty,
            label: 'Regalías',
            unit: '% del ingreso',
            helpText: 'Porcentaje del ingreso bruto (0 a menos de 100).',
            max: 99.99,
          ),
          const SectionHeader(title: 'Yacimiento y planta'),
          NumberInputField(
            controller: _reserves,
            label: 'Reservas',
            unit: 't',
            helpText: 'Toneladas de mineral económicamente explotables.',
            allowZero: false,
            onChanged: (_) => setState(() {}),
          ),
          NumberInputField(
            controller: _grade,
            label: 'Ley promedio',
            unit: _mineral.gradeUnitLabel,
            helpText: 'Concentración media del metal en el mineral.',
            allowZero: false,
            max: _mineral.maxGrade,
          ),
          NumberInputField(
            controller: _recovery,
            label: 'Recuperación metalúrgica',
            unit: '%',
            helpText: 'Fracción del metal contenido que recupera la planta.',
            allowZero: false,
            max: 100,
          ),
          NumberInputField(
            controller: _production,
            label: 'Producción anual',
            unit: 't/año',
            helpText: 'Mineral tratado por año.',
            allowZero: false,
            onChanged: (_) => setState(() {}),
          ),
          NumberInputField(
            controller: _capacity,
            label: 'Capacidad de planta',
            unit: 't/día',
            helpText: 'Capacidad nominal diaria de tratamiento.',
            allowZero: false,
            onChanged: (_) => setState(() {}),
          ),
          NumberInputField(
            controller: _days,
            label: 'Días de operación por año',
            unit: 'días',
            helpText: 'Entre 1 y 366 días.',
            min: 1,
            max: 366,
            integer: true,
            onChanged: (_) => setState(() {}),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verificación rápida',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capacidad anual de planta: '
                    '${Formatters.tonnes(capacity * days)}',
                  ),
                  Text(
                    'Duración de reservas: '
                    '${production > 0 ? Formatters.number(reserves / production, decimals: 1) : '—'} años',
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Impuestos simplificados'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aplicar impuesto a la renta simplificado'),
            subtitle: const Text(
              'Se aplica sobre el margen menos la depreciación lineal.',
            ),
            value: _taxEnabled,
            onChanged: context.onSelection(
              (bool value) => setState(() => _taxEnabled = value),
            ),
          ),
          NumberInputField(
            controller: _taxRate,
            label: 'Tasa de impuesto',
            unit: '%',
            helpText: 'Solo se usa si el impuesto está activado.',
            max: 99.99,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: context.onButton(_apply),
            icon: const Icon(Icons.check),
            label: const Text('Validar y aplicar'),
          ),
          const SizedBox(height: 8),
          KpiGrid(
            children: [
              KpiCard(
                label: 'Proyecto aplicado',
                value: widget.project.mineralType.label,
                icon: Icons.landscape_outlined,
                caption: widget.project.name,
              ),
              KpiCard(
                label: 'Reservas aplicadas',
                value: Formatters.tonnes(widget.project.reservesTonnes),
                icon: Icons.layers_outlined,
                caption:
                    'Ley ${Formatters.grade(widget.project.averageGrade, widget.project.mineralType.gradeUnitLabel)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          helperText: 'El MVP trabaja con periodos anuales.',
        ),
        child: Text(value),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.helper,
  });

  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: [
              for (final entry in items.entries)
                DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: context.onSelection((T? selected) {
              if (selected != null) {
                onChanged(selected);
              }
            }),
          ),
        ),
      ),
    );
  }
}
