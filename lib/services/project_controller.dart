import 'dart:async';

import 'package:flutter/foundation.dart';

import '../calculators/project_evaluator.dart';
import '../models/project_data.dart';
import '../models/scenario.dart';
import '../models/validation_result.dart';
import 'feedback_service.dart';
import 'progress_store.dart';
import 'validation_service.dart';

/// Estado compartido del simulador (proyecto activo, escenario y progreso).
///
/// El progreso y el proyecto aplicado se guardan en el [ProgressStore]
/// después de cada cambio, de modo que el estudiante no pierde su avance.
class ProjectController extends ChangeNotifier {
  ProjectController({
    ProjectData? initialProject,
    ProgressStore? store,
    this.evaluator = const ProjectEvaluator(),
    this.validator = const ValidationService(),
    this.feedback = const FeedbackService(),
  }) : _project = initialProject ?? ProjectData.defaultProject(),
       store = store ?? MemoryProgressStore();

  final ProjectEvaluator evaluator;
  final ValidationService validator;
  final ProgressStore store;
  final FeedbackService feedback;

  ProjectData _project;
  ScenarioType _scenario = ScenarioType.base;
  ProjectEvaluation? _cachedEvaluation;
  int _bestQuizScore = 0;
  int _quizQuestionCount = 0;
  int _bestNumericScore = 0;
  int _numericExerciseCount = 0;
  int _attempts = 0;
  final Set<String> _solvedCases = <String>{};
  bool _hapticsEnabled = true;
  bool _soundEnabled = true;
  bool _restored = false;
  bool _disposed = false;

  ProjectData get project => _project;

  ScenarioType get scenario => _scenario;

  int get bestQuizScore => _bestQuizScore;

  int get quizQuestionCount => _quizQuestionCount;

  int get bestNumericScore => _bestNumericScore;

  int get numericExerciseCount => _numericExerciseCount;

  /// Intentos de evaluación (preguntas y práctica numérica) registrados.
  int get attempts => _attempts;

  Set<String> get solvedCases => Set.unmodifiable(_solvedCases);

  /// Vibración activada por el estudiante.
  bool get hapticsEnabled => _hapticsEnabled;

  /// Sonidos del sistema activados por el estudiante.
  bool get soundEnabled => _soundEnabled;

  /// Verdadero cuando ya se intentó recuperar el progreso guardado.
  bool get restored => _restored;

  ValidationResult get validation => validator.validateProject(_project);

  /// Evaluación del proyecto activo en el escenario seleccionado.
  /// Es nula si los datos no son válidos.
  ProjectEvaluation? get evaluation {
    if (!validation.isValid) {
      return null;
    }
    return _cachedEvaluation ??= evaluator.evaluate(
      _project,
      scenario: _scenario,
    );
  }

  /// Evalúa el proyecto activo en cualquier escenario (sin cambiar estado).
  ProjectEvaluation? evaluationFor(ScenarioType scenario) {
    if (!validation.isValid) {
      return null;
    }
    return evaluator.evaluate(_project, scenario: scenario);
  }

  /// Aplica un nuevo proyecto solo si es válido.
  ValidationResult updateProject(ProjectData project) {
    final result = validator.validateProject(project);
    if (result.isValid) {
      _project = project;
      _cachedEvaluation = null;
      _changed();
    }
    return result;
  }

  void setScenario(ScenarioType scenario) {
    if (scenario == _scenario) {
      return;
    }
    _scenario = scenario;
    _cachedEvaluation = null;
    _changed();
  }

  void resetProject() {
    _project = ProjectData.defaultProject();
    _scenario = ScenarioType.base;
    _cachedEvaluation = null;
    _changed();
  }

  void registerQuizResult(int score, int total) {
    _quizQuestionCount = total;
    _attempts++;
    if (score > _bestQuizScore) {
      _bestQuizScore = score;
    }
    _changed();
  }

  void registerNumericResult(int score, int total) {
    _numericExerciseCount = total;
    _attempts++;
    if (score > _bestNumericScore) {
      _bestNumericScore = score;
    }
    _changed();
  }

  void markCaseSolved(String caseId) {
    if (_solvedCases.add(caseId)) {
      _changed();
    }
  }

  /// Activa o desactiva la vibración en toda la aplicación.
  void setHapticsEnabled(bool enabled) {
    if (enabled == _hapticsEnabled) {
      return;
    }
    _hapticsEnabled = enabled;
    _changed();
  }

  /// Activa o desactiva los sonidos del sistema en toda la aplicación.
  void setSoundEnabled(bool enabled) {
    if (enabled == _soundEnabled) {
      return;
    }
    _soundEnabled = enabled;
    _changed();
  }

  /// Emite la retroalimentación de [event] respetando las preferencias.
  Future<void> playFeedback(FeedbackEvent event) {
    if (!_hapticsEnabled && !_soundEnabled) {
      return Future<void>.value();
    }
    return feedback.emit(event, haptics: _hapticsEnabled, sound: _soundEnabled);
  }

  /// Borra el progreso del estudiante (no modifica el proyecto activo).
  void resetProgress() {
    _bestQuizScore = 0;
    _quizQuestionCount = 0;
    _bestNumericScore = 0;
    _numericExerciseCount = 0;
    _attempts = 0;
    _solvedCases.clear();
    _changed();
  }

  /// Recupera el progreso y el proyecto guardados.
  ///
  /// Un proyecto guardado que no pase la validación se descarta y se
  /// mantiene el proyecto de ejemplo.
  Future<void> restore() async {
    final data = await store.load();
    if (_disposed) {
      return;
    }
    _restored = true;
    if (data != null) {
      _applySnapshot(data);
    }
    notifyListeners();
  }

  /// Datos que se guardan localmente.
  Map<String, Object?> toSnapshot() => {
    'version': 1,
    'project': _project.toJson(),
    'scenario': _scenario.name,
    'bestQuizScore': _bestQuizScore,
    'quizQuestionCount': _quizQuestionCount,
    'bestNumericScore': _bestNumericScore,
    'numericExerciseCount': _numericExerciseCount,
    'attempts': _attempts,
    'solvedCases': _solvedCases.toList()..sort(),
    'hapticsEnabled': _hapticsEnabled,
    'soundEnabled': _soundEnabled,
  };

  void _applySnapshot(Map<String, Object?> data) {
    final saved = ProjectData.fromJson(data['project']);
    if (saved != null && validator.validateProject(saved).isValid) {
      _project = saved;
    }
    final scenarioName = data['scenario'];
    if (scenarioName is String) {
      _scenario =
          ScenarioType.values.asNameMap()[scenarioName] ?? ScenarioType.base;
    }
    _bestQuizScore = _readInt(data['bestQuizScore']);
    _quizQuestionCount = _readInt(data['quizQuestionCount']);
    _bestNumericScore = _readInt(data['bestNumericScore']);
    _numericExerciseCount = _readInt(data['numericExerciseCount']);
    _attempts = _readInt(data['attempts']);
    final cases = data['solvedCases'];
    if (cases is List) {
      _solvedCases
        ..clear()
        ..addAll(cases.whereType<String>());
    }
    _hapticsEnabled = _readBool(data['hapticsEnabled']);
    _soundEnabled = _readBool(data['soundEnabled']);
    _cachedEvaluation = null;
  }

  static int _readInt(Object? value) {
    if (value is num && value.isFinite && value >= 0) {
      return value.toInt();
    }
    return 0;
  }

  /// Las preferencias de sonido y vibración vienen activadas por defecto.
  static bool _readBool(Object? value) => value is bool ? value : true;

  void _changed() {
    notifyListeners();
    unawaited(store.save(toSnapshot()));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
