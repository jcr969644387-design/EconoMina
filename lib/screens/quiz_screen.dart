import 'dart:async';

import 'package:flutter/material.dart';

import '../models/learning_models.dart';
import '../services/feedback_service.dart';
import '../services/project_scope.dart';
import '../services/quiz_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';
import 'module_catalog.dart';
import 'numeric_practice_view.dart';

/// Modos de la evaluación práctica.
enum PracticeMode { preguntas, ejercicios }

/// Módulo 11: evaluación práctica con retroalimentación inmediata.
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.questions,
    this.initialMode = PracticeMode.preguntas,
    this.numericSeed,
  });

  /// Preguntas a usar; por defecto, el banco completo.
  final List<QuizQuestion>? questions;

  /// Modo con el que se abre la pantalla.
  final PracticeMode initialMode;

  /// Semilla opcional de la práctica numérica (para repetirla).
  final int? numericSeed;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _questions;
  late PracticeMode _mode;
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;
  final List<String> _missedTopics = [];

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? const QuizRepository().all();
    _mode = widget.initialMode;
  }

  QuizQuestion get _current => _questions[_index];

  /// Vibración y sonido según lo que acaba de ocurrir.
  void _feedback(FeedbackEvent event) {
    unawaited(ProjectScope.read(context).playFeedback(event));
  }

  void _check() {
    final selected = _selected;
    if (selected == null) {
      return;
    }
    final correct = selected == _current.correctIndex;
    setState(() {
      _answered = true;
      if (correct) {
        _score++;
      } else {
        _missedTopics.add(_current.topic);
      }
    });
    _feedback(correct ? FeedbackEvent.acierto : FeedbackEvent.error);
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      setState(() => _finished = true);
      ProjectScope.read(context).registerQuizResult(_score, _questions.length);
      _feedback(FeedbackEvent.logro);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _finished = false;
      _missedTopics.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: 'Evaluación práctica',
      children: [
        const SectionHeader(
          title: 'Pon a prueba lo aprendido',
          subtitle:
              'Preguntas conceptuales y ejercicios numéricos sobre costos, ley '
              'de corte, flujo, VAN, TIR y sensibilidad.',
        ),
        SegmentedButton<PracticeMode>(
          segments: const [
            ButtonSegment(
              value: PracticeMode.preguntas,
              icon: Icon(Icons.quiz_outlined),
              label: Text('Preguntas'),
            ),
            ButtonSegment(
              value: PracticeMode.ejercicios,
              icon: Icon(Icons.calculate_outlined),
              label: Text('Ejercicios numéricos'),
            ),
          ],
          selected: {_mode},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              setState(() => _mode = selection.first),
        ),
        const SizedBox(height: 8),
        if (_mode == PracticeMode.ejercicios)
          NumericPracticeView(seed: widget.numericSeed)
        else if (_questions.isEmpty)
          const Text('No hay preguntas disponibles.')
        else if (_finished)
          _Summary(
            score: _score,
            total: _questions.length,
            missedTopics: _missedTopics.toSet().toList(),
            onRestart: _restart,
          )
        else
          ..._questionView(context),
      ],
    );
  }

  List<Widget> _questionView(BuildContext context) {
    final theme = Theme.of(context);
    final question = _current;
    return [
      LabeledProgress(
        label: 'Pregunta ${_index + 1} de ${_questions.length}',
        value: (_index + (_answered ? 1 : 0)) / _questions.length,
        trailing: 'Puntaje: $_score',
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        children: [
          Chip(label: Text(question.topic)),
          if (question.isExercise)
            const Chip(
              avatar: Icon(Icons.calculate_outlined, size: 18),
              label: Text('Ejercicio'),
            ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          question.prompt,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      for (var i = 0; i < question.options.length; i++)
        _OptionTile(
          key: Key('option-$i'),
          text: question.options[i],
          selected: _selected == i,
          state: !_answered
              ? _OptionState.neutral
              : i == question.correctIndex
              ? _OptionState.correct
              : _selected == i
              ? _OptionState.wrong
              : _OptionState.neutral,
          onTap: _answered
              ? null
              : () {
                  _feedback(FeedbackEvent.seleccion);
                  setState(() => _selected = i);
                },
        ),
      const SizedBox(height: 8),
      if (_answered) ...[
        InterpretationCard(
          title: _selected == question.correctIndex
              ? '¡Correcto!'
              : 'Respuesta incorrecta',
          text: question.explanation,
          color: _selected == question.correctIndex
              ? AppColors.positive
              : AppColors.negative,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('quiz-next'),
          onPressed: _next,
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            _index + 1 >= _questions.length
                ? 'Ver resultado'
                : 'Siguiente pregunta',
          ),
        ),
      ] else
        FilledButton.icon(
          key: const Key('quiz-check'),
          onPressed: _selected == null ? null : _check,
          icon: const Icon(Icons.check),
          label: const Text('Comprobar respuesta'),
        ),
    ];
  }
}

enum _OptionState { neutral, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.text,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (state) {
      _OptionState.correct => AppColors.positive,
      _OptionState.wrong => AppColors.negative,
      _OptionState.neutral => selected ? scheme.primary : scheme.outlineVariant,
    };
    final icon = switch (state) {
      _OptionState.correct => Icons.check_circle,
      _OptionState.wrong => Icons.cancel,
      _OptionState.neutral =>
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
    };
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: selected ? 2 : 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.score,
    required this.total,
    required this.missedTopics,
    required this.onRestart,
  });

  final int score;
  final int total;
  final List<String> missedTopics;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : score / total;
    final color = ratio >= 0.8
        ? AppColors.positive
        : ratio >= 0.6
        ? AppColors.neutral
        : AppColors.negative;
    final message = ratio >= 0.8
        ? 'Excelente dominio de los conceptos de economía minera.'
        : ratio >= 0.6
        ? 'Buen avance. Repasa los temas indicados y vuelve a intentarlo.'
        : 'Necesitas reforzar los conceptos. Revisa los módulos y consulta '
              'al tutor económico.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiCard(
          label: 'Resultado final',
          value: '$score / $total',
          icon: Icons.emoji_events_outlined,
          color: color,
          caption: '${(ratio * 100).toStringAsFixed(0)} % de aciertos',
        ),
        LabeledProgress(
          label: 'Aciertos',
          value: ratio,
          trailing: '${(ratio * 100).toStringAsFixed(0)} %',
          color: color,
        ),
        InterpretationCard(
          title: 'Retroalimentación',
          text: message,
          color: color,
        ),
        if (missedTopics.isNotEmpty) ...[
          const SectionHeader(title: 'Temas para repasar'),
          BulletList(items: missedTopics, icon: Icons.menu_book_outlined),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.replay),
          label: const Text('Intentar de nuevo'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => openModule(
            context,
            appModules.firstWhere((module) => module.id == 'tutor'),
          ),
          icon: const Icon(Icons.support_agent),
          label: const Text('Consultar al tutor económico'),
        ),
      ],
    );
  }
}
