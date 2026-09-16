import 'dart:async';

import 'package:flutter/material.dart';

import '../models/numeric_exercise.dart';
import '../services/feedback_service.dart';
import '../services/numeric_exercise_generator.dart';
import '../services/project_scope.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/number_parser.dart';
import '../widgets/info_widgets.dart';
import '../widgets/result_widgets.dart';

/// Práctica numérica: el estudiante calcula y la app verifica el resultado.
class NumericPracticeView extends StatefulWidget {
  const NumericPracticeView({super.key, this.seed, this.count = 6});

  /// Semilla opcional para repetir exactamente la misma práctica.
  final int? seed;

  /// Cantidad de ejercicios por práctica.
  final int count;

  @override
  State<NumericPracticeView> createState() => _NumericPracticeViewState();
}

class _NumericPracticeViewState extends State<NumericPracticeView> {
  final TextEditingController _answer = TextEditingController();
  late List<NumericExercise> _exercises;
  late int _round;
  int _index = 0;
  int _score = 0;
  bool? _lastCorrect;
  bool _finished = false;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _round = widget.seed ?? DateTime.now().millisecondsSinceEpoch;
    _exercises = _build(_round);
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  List<NumericExercise> _build(int seed) =>
      NumericExerciseGenerator(seed: seed).generate(count: widget.count);

  NumericExercise get _current => _exercises[_index];

  /// Vibración y sonido según lo que acaba de ocurrir.
  void _feedback(FeedbackEvent event) {
    unawaited(ProjectScope.read(context).playFeedback(event));
  }

  void _check() {
    final value = NumberParser.parse(_answer.text);
    if (value == null) {
      setState(
        () => _inputError = 'Ingresa un número válido (ejemplo: 12.5 o 12,5).',
      );
      _feedback(FeedbackEvent.error);
      return;
    }
    final correct = _current.isCorrect(value);
    setState(() {
      _inputError = null;
      _lastCorrect = correct;
      if (correct) {
        _score++;
      }
    });
    _feedback(correct ? FeedbackEvent.acierto : FeedbackEvent.error);
  }

  void _next() {
    if (_index + 1 >= _exercises.length) {
      setState(() => _finished = true);
      ProjectScope.read(
        context,
      ).registerNumericResult(_score, _exercises.length);
      _feedback(FeedbackEvent.logro);
      return;
    }
    setState(() {
      _index++;
      _lastCorrect = null;
      _answer.clear();
    });
  }

  void _newPractice() {
    setState(() {
      _round++;
      _exercises = _build(_round);
      _index = 0;
      _score = 0;
      _lastCorrect = null;
      _finished = false;
      _inputError = null;
      _answer.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _summary(context);
    }
    final theme = Theme.of(context);
    final exercise = _current;
    final answered = _lastCorrect != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledProgress(
          label: 'Ejercicio ${_index + 1} de ${_exercises.length}',
          value: (_index + (answered ? 1 : 0)) / _exercises.length,
          trailing: 'Puntaje: $_score',
          color: AppColors.copper,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: const Icon(Icons.calculate_outlined, size: 18),
            label: Text(exercise.topic),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            exercise.prompt,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextField(
          key: const Key('numeric-answer'),
          controller: _answer,
          enabled: !answered,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: InputDecoration(
            labelText: 'Tu respuesta',
            suffixText: exercise.unit,
            errorText: _inputError,
            helperText:
                'Se acepta una diferencia de hasta '
                '${Formatters.number(exercise.tolerancePct, decimals: 1)} % '
                'por redondeo.',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: answered ? null : (_) => _check(),
        ),
        const SizedBox(height: 8),
        if (!answered)
          FilledButton.icon(
            key: const Key('numeric-check'),
            onPressed: _check,
            icon: const Icon(Icons.check),
            label: const Text('Comprobar resultado'),
          )
        else ...[
          InterpretationCard(
            title: _lastCorrect! ? '¡Resultado correcto!' : 'Revisa tu cálculo',
            text:
                'Respuesta esperada: '
                '${Formatters.number(exercise.answer, decimals: exercise.decimals)} '
                '${exercise.unit}.',
            color: _lastCorrect! ? AppColors.positive : AppColors.negative,
          ),
          const SectionHeader(title: 'Solución paso a paso'),
          BulletList(items: exercise.steps, icon: Icons.arrow_right),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('numeric-next'),
            onPressed: _next,
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              _index + 1 >= _exercises.length
                  ? 'Ver resultado'
                  : 'Siguiente ejercicio',
            ),
          ),
        ],
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final total = _exercises.length;
    final ratio = total == 0 ? 0.0 : _score / total;
    final color = ratio >= 0.8
        ? AppColors.positive
        : ratio >= 0.5
        ? AppColors.neutral
        : AppColors.negative;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiCard(
          label: 'Práctica numérica',
          value: '$_score / $total',
          icon: Icons.calculate_outlined,
          color: color,
          caption: '${(ratio * 100).toStringAsFixed(0)} % de aciertos',
        ),
        InterpretationCard(
          title: 'Retroalimentación',
          text: ratio >= 0.8
              ? 'Dominas los cálculos básicos de economía minera.'
              : 'Repasa las soluciones paso a paso y vuelve a practicar con '
                    'datos nuevos.',
          color: color,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('numeric-new'),
          onPressed: _newPractice,
          icon: const Icon(Icons.autorenew),
          label: const Text('Practicar con datos nuevos'),
        ),
      ],
    );
  }
}
