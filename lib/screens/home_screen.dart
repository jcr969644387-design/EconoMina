import 'package:flutter/material.dart';

import '../services/case_repository.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/app_texts.dart';
import '../utils/formatters.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import 'module_catalog.dart';

/// Módulo 1: pantalla de inicio con acceso a todos los módulos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ProjectScope.of(context);
    final evaluation = controller.evaluation;
    final project = controller.project;
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.appName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _TextLogo(),
                  const SizedBox(height: 12),
                  Text(
                    AppTexts.fullName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppTexts.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  const Center(child: SimulatedBadge()),
                  const SectionHeader(title: 'Objetivo educativo'),
                  const Text(AppTexts.objective),
                  const SizedBox(height: 8),
                  const DisclaimerBanner(),
                  const SectionHeader(
                    title: 'Proyecto activo',
                    subtitle: 'Todos los módulos usan estos datos.',
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.landscape_outlined),
                      title: Text(project.name),
                      subtitle: Text(
                        evaluation == null
                            ? 'Datos con errores: revisa el módulo 2.'
                            : 'VAN ${Formatters.compactMoney(evaluation.npv, project.currency)}'
                                  ' · Escenario ${evaluation.scenario.label}',
                      ),
                      trailing: evaluation == null
                          ? const Icon(Icons.error_outline)
                          : Icon(
                              Icons.circle,
                              size: 14,
                              color: AppColors.profitability(
                                evaluation.npvClass,
                              ),
                            ),
                    ),
                  ),
                  if (evaluation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ProfitabilityIndicator(
                            label: 'VAN',
                            value: evaluation.npvClass,
                          ),
                          Chip(
                            avatar: Icon(
                              Icons.shield_outlined,
                              color: AppColors.risk(evaluation.risk),
                              size: 18,
                            ),
                            label: Text(evaluation.risk.label),
                          ),
                        ],
                      ),
                    ),
                  const SectionHeader(
                    title: 'Módulos',
                    subtitle: 'Recorre los módulos en orden o elige uno.',
                  ),
                  _ModuleGrid(modules: appModules),
                  const SizedBox(height: 12),
                  const SectionHeader(
                    title: 'Recorrido sugerido',
                    subtitle: 'Del yacimiento a la decisión económica.',
                  ),
                  const _LearningPath(),
                  const SizedBox(height: 12),
                  _ProgressSummary(
                    solvedCases: controller.solvedCases.length,
                    totalCases: const CaseRepository().all().length,
                    bestScore: controller.bestQuizScore,
                    questionCount: controller.quizQuestionCount,
                    bestNumericScore: controller.bestNumericScore,
                    numericCount: controller.numericExerciseCount,
                    attempts: controller.attempts,
                    onReset: () => _confirmReset(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmReset(BuildContext context) async {
  final controller = ProjectScope.read(context);
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reiniciar progreso'),
      content: const Text(
        'Se borrarán los casos resueltos y los mejores puntajes. El proyecto '
        'activo no cambia.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Reiniciar'),
        ),
      ],
    ),
  );
  if (confirmed ?? false) {
    controller.resetProgress();
    messenger.showSnackBar(
      const SnackBar(content: Text('Progreso reiniciado.')),
    );
  }
}

class _LearningPath extends StatelessWidget {
  const _LearningPath();

  static const List<(String, String)> _steps = [
    ('Datos y costos', 'Define el yacimiento, la planta y los costos.'),
    ('Ley de corte', 'Decide qué material paga su tratamiento.'),
    ('Producción', 'Convierte toneladas y ley en ingresos.'),
    ('Flujo, VAN y TIR', 'Evalúa el valor creado y la rentabilidad.'),
    ('Sensibilidad', 'Encuentra las variables críticas y el riesgo.'),
    ('Casos y evaluación', 'Decide, calcula y mide tu avance.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < _steps.length; i++)
              ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${i + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(_steps[i].$1),
                subtitle: Text(_steps[i].$2),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextLogo extends StatelessWidget {
  const _TextLogo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.seed, AppColors.finance],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.copper,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'EM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  AppTexts.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Economía · Evaluación · Minería',
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.modules});

  final List<AppModule> modules;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        const spacing = 8.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final module in modules)
              SizedBox(
                width: width,
                child: _ModuleButton(module: module),
              ),
          ],
        );
      },
    );
  }
}

class _ModuleButton extends StatelessWidget {
  const _ModuleButton({required this.module});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('module-${module.id}'),
        onTap: () => openModule(context, module),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(module.icon, color: theme.colorScheme.primary),
                  const Spacer(),
                  Text('${module.number}', style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                module.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                module.description,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.solvedCases,
    required this.totalCases,
    required this.bestScore,
    required this.questionCount,
    required this.bestNumericScore,
    required this.numericCount,
    required this.attempts,
    required this.onReset,
  });

  final int solvedCases;
  final int totalCases;
  final int bestScore;
  final int questionCount;
  final int bestNumericScore;
  final int numericCount;
  final int attempts;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tu progreso',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  key: const Key('reset-progress'),
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: const Text('Reiniciar'),
                ),
              ],
            ),
            Text(
              'Se guarda en este dispositivo. Intentos de evaluación: $attempts.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            LabeledProgress(
              label: 'Casos empresariales resueltos',
              value: totalCases == 0 ? 0 : solvedCases / totalCases,
              trailing: '$solvedCases de $totalCases',
            ),
            LabeledProgress(
              label: 'Mejor puntaje en preguntas',
              value: questionCount == 0 ? 0 : bestScore / questionCount,
              trailing: questionCount == 0
                  ? 'Sin intentos'
                  : '$bestScore de $questionCount',
              color: AppColors.finance,
            ),
            LabeledProgress(
              label: 'Mejor puntaje en ejercicios numéricos',
              value: numericCount == 0 ? 0 : bestNumericScore / numericCount,
              trailing: numericCount == 0
                  ? 'Sin intentos'
                  : '$bestNumericScore de $numericCount',
              color: AppColors.copper,
            ),
          ],
        ),
      ),
    );
  }
}
