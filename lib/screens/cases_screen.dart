import 'dart:async';

import 'package:flutter/material.dart';

import '../calculators/cost_calculator.dart';
import '../calculators/project_evaluator.dart';
import '../models/learning_models.dart';
import '../models/scenario.dart';
import '../services/case_repository.dart';
import '../services/feedback_service.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import '../widgets/scrollable_table.dart';
import 'module_catalog.dart';

/// Decisión que el estudiante toma antes de ver la solución.
enum StudentDecision {
  continuar('Continuar el estudio'),
  masEstudio('Requiere más estudio'),
  noContinuar('No continuar');

  const StudentDecision(this.label);

  final String label;
}

/// Módulo 10: casos empresariales.
class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProjectScope.of(context);
    final cases = const CaseRepository().all();
    final solved = controller.solvedCases;
    return ModuleScaffold(
      title: 'Casos empresariales',
      children: [
        const SectionHeader(
          title: 'Aprende decidiendo',
          subtitle:
              'Analiza cada proyecto ficticio, toma una decisión y luego '
              'compárala con la solución calculada por el simulador.',
        ),
        LabeledProgress(
          label: 'Casos resueltos',
          value: cases.isEmpty ? 0 : solved.length / cases.length,
          trailing: '${solved.length} de ${cases.length}',
        ),
        const SizedBox(height: 8),
        for (final item in cases)
          Card(
            child: ListTile(
              key: Key('case-${item.id}'),
              leading: CircleAvatar(
                backgroundColor: solved.contains(item.id)
                    ? AppColors.positive
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  solved.contains(item.id)
                      ? Icons.check
                      : Icons.business_center_outlined,
                  color: solved.contains(item.id) ? Colors.white : null,
                ),
              ),
              title: Text(item.title),
              subtitle: Text(
                '${item.summary}\n${item.project.mineralType.label} · '
                '${item.project.name}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CaseDetailScreen(caseStudy: item),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Detalle de un caso empresarial.
class CaseDetailScreen extends StatefulWidget {
  const CaseDetailScreen({super.key, required this.caseStudy});

  final CaseStudy caseStudy;

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  static const ProjectEvaluator _evaluator = ProjectEvaluator();

  StudentDecision? _decision;
  bool _revealed = false;
  late final ProjectEvaluation _base;
  late final ProjectEvaluation _pessimistic;
  late final ProjectEvaluation _optimistic;

  @override
  void initState() {
    super.initState();
    final project = widget.caseStudy.project;
    _base = _evaluator.evaluate(project);
    _pessimistic = _evaluator.evaluate(
      project,
      scenario: ScenarioType.pesimista,
    );
    _optimistic = _evaluator.evaluate(
      project,
      scenario: ScenarioType.optimista,
    );
  }

  void _reveal() {
    setState(() => _revealed = true);
    final controller = ProjectScope.read(context);
    controller.markCaseSolved(widget.caseStudy.id);
    unawaited(controller.playFeedback(FeedbackEvent.logro));
  }

  void _loadIntoSimulator() {
    final controller = ProjectScope.read(context);
    final result = controller.updateProject(widget.caseStudy.project);
    if (result.isValid) {
      controller.setScenario(ScenarioType.base);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isValid
              ? 'Caso cargado. Todos los módulos usan ahora '
                    '"${widget.caseStudy.project.name}".'
              : 'No se pudo cargar el caso: ${result.errors.join(' ')}',
        ),
      ),
    );
  }

  StudentDecision get _recommended {
    if (_base.npv < 0) {
      return StudentDecision.noContinuar;
    }
    if (_pessimistic.npv < 0) {
      return StudentDecision.masEstudio;
    }
    return StudentDecision.continuar;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.caseStudy;
    final project = item.project;
    final currency = project.currency;
    final mineral = project.mineralType;
    final costs = project.costs;
    final unitCost = const CostCalculator().unitCost(
      costs,
      project.annualProductionTonnes,
    );

    return ModuleScaffold(
      title: 'Caso empresarial',
      actions: [
        IconButton(
          tooltip: 'Cargar en el simulador',
          onPressed: _loadIntoSimulator,
          icon: const Icon(Icons.upload_outlined),
        ),
      ],
      children: [
        SectionHeader(title: item.title, subtitle: item.summary),
        ScrollableTable(
          columns: const ['Dato', 'Valor'],
          rows: [
            ['Proyecto', project.name],
            ['Mineral', mineral.label],
            ['Reservas', Formatters.tonnes(project.reservesTonnes)],
            [
              'Ley promedio',
              Formatters.grade(project.averageGrade, mineral.gradeUnitLabel),
            ],
            [
              'Recuperación',
              Formatters.percent(project.recoveryPct, decimals: 1),
            ],
            [
              'Producción anual',
              Formatters.tonnes(project.annualProductionTonnes),
            ],
            [
              'Precio',
              '${Formatters.number(project.metalPrice)} '
                  '${mineral.priceUnitLabel(currency)}',
            ],
            ['Vida útil', '${project.lifeYears} años'],
            [
              'Tasa de descuento',
              Formatters.percent(project.discountRatePct, decimals: 1),
            ],
            [
              'Inversión (CAPEX + desarrollo)',
              Formatters.millions(costs.initialInvestment, currency),
            ],
            [
              'Costo variable',
              '${Formatters.number(costs.variableUnitCost)} $currency/t',
            ],
            [
              'Costos fijos anuales',
              Formatters.millions(costs.annualFixedCost, currency),
            ],
            [
              'Costo operativo unitario',
              '${Formatters.number(unitCost)} $currency/t',
            ],
            ['Cierre', Formatters.millions(costs.closureCost, currency)],
            [
              'Regalías / impuestos',
              '${Formatters.percent(project.royaltyPct, decimals: 1)} / '
                  '${project.taxEnabled ? Formatters.percent(project.taxRatePct, decimals: 1) : 'desactivados'}',
            ],
          ],
        ),
        const SectionHeader(title: 'Supuestos'),
        BulletList(items: item.assumptions),
        const SectionHeader(title: 'Preguntas para el estudiante'),
        BulletList(items: item.questions, icon: Icons.help_outline),
        const SectionHeader(
          title: 'Tu decisión',
          subtitle: 'Decide antes de ver la solución.',
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final option in StudentDecision.values)
              ChoiceChip(
                label: Text(option.label),
                selected: option == _decision,
                onSelected: _revealed
                    ? null
                    : (_) => setState(() => _decision = option),
              ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('reveal-case'),
          onPressed: _decision == null || _revealed ? null : _reveal,
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Ver solución'),
        ),
        if (_revealed) ..._solution(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _loadIntoSimulator,
          icon: const Icon(Icons.upload_outlined),
          label: const Text('Cargar este caso en el simulador'),
        ),
      ],
    );
  }

  List<Widget> _solution() {
    final item = widget.caseStudy;
    final currency = item.project.currency;
    final decision = _decision;
    final recommended = _recommended;
    final matches = decision == recommended;
    String irrText(ProjectEvaluation value) {
      final irr = value.irr.value;
      return irr == null ? 'No calculable' : Formatters.percent(irr * 100);
    }

    return [
      const SectionHeader(title: 'Solución calculada'),
      KpiGrid(
        children: [
          KpiCard(
            label: 'VAN base',
            value: Formatters.millions(_base.npv, currency),
            icon: Icons.savings_outlined,
            color: AppColors.signed(_base.npv),
          ),
          KpiCard(
            label: 'TIR base',
            value: irrText(_base),
            icon: Icons.percent,
            color: _base.irrClass == null
                ? AppColors.negative
                : AppColors.profitability(_base.irrClass!),
          ),
          KpiCard(
            label: 'VAN pesimista',
            value: Formatters.millions(_pessimistic.npv, currency),
            icon: Icons.trending_down,
            color: AppColors.signed(_pessimistic.npv),
          ),
          KpiCard(
            label: 'VAN optimista',
            value: Formatters.millions(_optimistic.npv, currency),
            icon: Icons.trending_up,
            color: AppColors.signed(_optimistic.npv),
          ),
          KpiCard(
            label: 'Periodo de recuperación',
            value: _base.summary.paybackPeriod == null
                ? 'No se recupera'
                : 'Año ${_base.summary.paybackPeriod}',
            icon: Icons.restore,
          ),
          KpiCard(
            label: 'Años de operación',
            value: '${_base.summary.operatingYears}',
            icon: Icons.calendar_month_outlined,
          ),
        ],
      ),
      const SizedBox(height: 8),
      RiskIndicator(level: _base.risk),
      const SectionHeader(title: 'Cálculos esperados'),
      BulletList(items: item.expectedCalculations, icon: Icons.calculate),
      InterpretationCard(
        text: item.interpretation,
        color: AppColors.profitability(_base.npvClass),
      ),
      const SectionHeader(title: 'Riesgos principales'),
      BulletList(items: item.risks, icon: Icons.warning_amber_outlined),
      Card(
        child: ListTile(
          leading: Icon(
            matches ? Icons.emoji_events_outlined : Icons.school_outlined,
            color: matches ? AppColors.positive : AppColors.neutral,
          ),
          title: Text(
            matches
                ? 'Tu decisión coincide con el criterio del simulador'
                : 'Tu decisión difiere del criterio del simulador',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            'Elegiste: ${decision?.label ?? '—'}. Criterio del simulador: '
            '${recommended.label} (VAN base y pesimista).\n'
            'Decisión educativa: ${item.educationalDecision}',
          ),
        ),
      ),
      const SectionHeader(title: 'Explicación'),
      Text(item.explanation),
      const SizedBox(height: 8),
      const DisclaimerBanner(),
    ];
  }
}
