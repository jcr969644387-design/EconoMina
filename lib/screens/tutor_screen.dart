import 'package:flutter/material.dart';

import '../calculators/cutoff_grade_calculator.dart';
import '../services/feedback_actions.dart';
import '../services/feedback_service.dart';
import '../services/project_controller.dart';
import '../services/project_scope.dart';
import '../services/tutor/rule_based_tutor.dart';
import '../services/tutor/tutor_engine.dart';
import '../services/tutor/tutor_models.dart';
import '../theme/app_theme.dart';
import '../widgets/info_widgets.dart';
import 'module_catalog.dart';

/// Módulo 12: tutor económico local basado en reglas.
///
/// Usa la interfaz [TutorEngine]; en una versión futura puede inyectarse un
/// motor con inteligencia artificial sin cambiar esta pantalla.
class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key, this.engine = const RuleBasedTutor()});

  final TutorEngine engine;

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final TextEditingController _question = TextEditingController();
  final List<(String, TutorAnswer)> _history = [];
  bool _loading = false;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  TutorContext? _context(ProjectController controller) {
    final evaluation = controller.evaluation;
    if (evaluation == null) {
      return null;
    }
    final project = evaluation.project;
    double? cutoff;
    try {
      const calculator = CutoffGradeCalculator();
      cutoff = calculator
          .calculate(calculator.fromProject(project))
          .cutoffGrade;
    } on ArgumentError {
      cutoff = null;
    }
    return TutorContext(
      projectName: project.name,
      currency: project.currency,
      npv: evaluation.npv,
      irr: evaluation.irr.value,
      discountRate: project.discountRate,
      marginPct: evaluation.summary.marginPct,
      averageGrade: project.averageGrade,
      gradeUnit: project.mineralType.gradeUnitLabel,
      cutoffGrade: cutoff,
    );
  }

  Future<void> _ask(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _loading) {
      return;
    }
    final tutorContext = _context(ProjectScope.read(context));
    setState(() => _loading = true);
    final answer = await widget.engine.answer(
      TutorQuery(text: trimmed, context: tutorContext),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _history.insert(0, (trimmed, answer));
      _question.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: 'Tutor económico',
      children: [
        SectionHeader(
          title: 'Pregúntale al tutor',
          subtitle:
              '${widget.engine.name}. Funciona sin internet y no envía tus '
              'datos a ningún servicio externo.',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('tutor-input'),
                  controller: _question,
                  textInputAction: TextInputAction.send,
                  onTap: () => context.emitFeedback(FeedbackEvent.seleccion),
                  onSubmitted: context.onSelection(_ask),
                  decoration: const InputDecoration(
                    labelText: 'Escribe tu pregunta',
                    hintText: 'Ejemplo: ¿qué significa un VAN negativo?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const Key('tutor-ask'),
                  onPressed: context.onButton(
                    _loading ? null : () => _ask(_question.text),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Preguntar'),
                ),
              ],
            ),
          ),
        ),
        const SectionHeader(
          title: 'Temas frecuentes',
          subtitle: 'Toca un tema para obtener una explicación.',
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final topic in TutorTopic.values)
              ActionChip(
                label: Text(topic.title),
                onPressed: context.onButton(
                  _loading ? null : () => _ask(topic.title),
                ),
              ),
          ],
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        for (final entry in _history)
          _AnswerCard(question: entry.$1, answer: entry.$2, onSuggestion: _ask),
        if (_history.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton.icon(
              onPressed: context.onButton(() => openProjectData(context)),
              icon: const Icon(Icons.edit_note),
              label: const Text('Las respuestas se adaptan al proyecto activo'),
            ),
          ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.question,
    required this.answer,
    required this.onSuggestion,
  });

  final String question;
  final TutorAnswer answer;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formula = answer.formula;
    final note = answer.contextNote;
    final recognized = answer.topic != null;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    question,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Icon(
                  recognized ? Icons.support_agent : Icons.help_outline,
                  color: recognized ? AppColors.seed : AppColors.neutral,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    answer.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(answer.explanation),
            const SizedBox(height: 6),
            BulletList(items: answer.keyPoints),
            if (formula != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formula,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
            if (note != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.finance.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.finance.withValues(alpha: 0.4),
                  ),
                ),
                child: Text('En tu proyecto: $note'),
              ),
            ],
            if (answer.suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'También puedes preguntar:',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final suggestion in answer.suggestions)
                    ActionChip(
                      label: Text(suggestion),
                      onPressed: context.onButton(
                        () => onSuggestion(suggestion),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
