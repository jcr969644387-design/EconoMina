import '../models/irr_result.dart';
import 'npv_calculator.dart';

/// Cálculo educativo de la tasa interna de retorno (TIR).
///
/// Método: barrido de tasas entre −90 % y 1000 % para detectar cambios de
/// signo del VAN y bisección dentro de cada intervalo encontrado.
class IrrCalculator {
  const IrrCalculator({
    this.npvCalculator = const NpvCalculator(),
    this.tolerance = 1e-10,
    this.maxIterations = 200,
  });

  final NpvCalculator npvCalculator;
  final double tolerance;
  final int maxIterations;

  static final List<double> _grid = _buildGrid();

  /// Calcula la TIR de una serie donde el índice 0 es el periodo 0.
  ///
  /// Si hay varias raíces, se devuelve la más cercana a [referenceRate].
  IrrResult calculate(List<double> series, {double referenceRate = 0}) {
    if (series.length < 2) {
      return IrrResult.notFound(
        'Se necesitan al menos dos periodos (inversión y un flujo) para '
        'calcular la TIR.',
      );
    }
    final hasPositive = series.any((flow) => flow > 0);
    final hasNegative = series.any((flow) => flow < 0);
    if (!hasPositive || !hasNegative) {
      return IrrResult.noSignChange();
    }

    final roots = <double>[];
    var previousRate = _grid.first;
    var previousValue = npvCalculator.npvFromSeries(series, previousRate);
    for (var i = 1; i < _grid.length; i++) {
      final rate = _grid[i];
      final value = npvCalculator.npvFromSeries(series, rate);
      if (previousValue == 0) {
        roots.add(previousRate);
      } else if (previousValue.sign != value.sign && value != 0) {
        final root = _bisect(series, previousRate, rate, previousValue);
        if (root != null) {
          roots.add(root);
        }
      }
      previousRate = rate;
      previousValue = value;
    }
    if (previousValue == 0) {
      roots.add(previousRate);
    }

    if (roots.isEmpty) {
      return IrrResult.notFound(
        'El cálculo no convergió: no se encontró una tasa entre −90 % y '
        '1000 % que haga el VAN igual a cero. Revisa los flujos de caja.',
      );
    }
    final sorted = [...roots]
      ..sort(
        (a, b) =>
            (a - referenceRate).abs().compareTo((b - referenceRate).abs()),
      );
    return IrrResult.converged(sorted.first, roots: roots);
  }

  double? _bisect(List<double> series, double low, double high, double lowV) {
    var a = low;
    var b = high;
    var valueA = lowV;
    for (var i = 0; i < maxIterations; i++) {
      final mid = (a + b) / 2;
      final valueMid = npvCalculator.npvFromSeries(series, mid);
      if (valueMid == 0 || (b - a) / 2 < tolerance) {
        return mid;
      }
      if (valueA.sign == valueMid.sign) {
        a = mid;
        valueA = valueMid;
      } else {
        b = mid;
      }
    }
    return null;
  }

  static List<double> _buildGrid() {
    final values = <double>[];
    for (var i = 0; i < 8; i++) {
      values.add(-0.90 + 0.05 * i);
    }
    for (var i = 0; i < 150; i++) {
      values.add(-0.50 + 0.01 * i);
    }
    for (var i = 0; i <= 90; i++) {
      values.add(1.0 + 0.1 * i);
    }
    return values;
  }
}
