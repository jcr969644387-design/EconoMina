import '../models/project_data.dart';
import 'project_evaluator.dart';

/// Resultado de un punto de equilibrio económico (VAN = 0).
class BreakevenResult {
  const BreakevenResult({
    required this.value,
    required this.baseValue,
    required this.message,
  });

  /// Valor de la variable que hace VAN = 0; nulo si no existe en el rango.
  final double? value;

  /// Valor actual de la variable en el proyecto.
  final double baseValue;

  final String message;

  bool get isAvailable => value != null;

  /// Margen de seguridad = (valor actual − equilibrio) / valor actual × 100.
  ///
  /// Indica cuánto puede caer la variable antes de que el VAN sea negativo.
  double? get safetyMarginPct {
    final breakeven = value;
    if (breakeven == null || baseValue == 0) {
      return null;
    }
    return (baseValue - breakeven) / baseValue * 100;
  }
}

/// Calcula el precio y la ley de equilibrio (VAN = 0) por bisección.
///
/// El VAN crece con el precio y con la ley; por eso existe como máximo un
/// valor de equilibrio para cada variable.
class BreakevenCalculator {
  const BreakevenCalculator({this.evaluator = const ProjectEvaluator()});

  final ProjectEvaluator evaluator;

  static const int _maxIterations = 200;

  BreakevenResult price(ProjectData project) {
    return _solve(
      baseValue: project.metalPrice,
      npvAt: (value) => evaluator.quickNpv(project.copyWith(metalPrice: value)),
      upperLimit: project.metalPrice * 1000,
      label: 'precio',
    );
  }

  BreakevenResult grade(ProjectData project) {
    return _solve(
      baseValue: project.averageGrade,
      npvAt: (value) =>
          evaluator.quickNpv(project.copyWith(averageGrade: value)),
      upperLimit: project.mineralType.maxGrade,
      label: 'ley',
    );
  }

  BreakevenResult _solve({
    required double baseValue,
    required double Function(double value) npvAt,
    required double upperLimit,
    required String label,
  }) {
    // Límite inferior positivo: un precio igual a cero no es un dato válido.
    var low = baseValue > 0 ? baseValue * 1e-9 : 1e-9;
    var high = baseValue > 0 ? baseValue : 1.0;
    final lowNpv = npvAt(low);
    if (lowNpv >= 0) {
      return BreakevenResult(
        value: null,
        baseValue: baseValue,
        message:
            'El VAN es positivo incluso con $label casi nula: no hay punto de '
            'equilibrio para esta variable.',
      );
    }
    var highNpv = npvAt(high);
    while (highNpv < 0 && high < upperLimit) {
      high = (high * 2).clamp(0.0, upperLimit).toDouble();
      highNpv = npvAt(high);
    }
    if (highNpv < 0) {
      return BreakevenResult(
        value: null,
        baseValue: baseValue,
        message:
            'Ni con el máximo $label razonable el VAN llega a cero: el '
            'proyecto no es viable modificando solo esta variable.',
      );
    }
    for (var i = 0; i < _maxIterations; i++) {
      final mid = (low + high) / 2;
      if (npvAt(mid) < 0) {
        low = mid;
      } else {
        high = mid;
      }
      if ((high - low) <= 1e-9 * (1 + high.abs())) {
        break;
      }
    }
    return BreakevenResult(
      value: (low + high) / 2,
      baseValue: baseValue,
      message: 'Valor de $label que hace el VAN igual a cero.',
    );
  }
}
