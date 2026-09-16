/// Estado del cálculo de la TIR.
enum IrrStatus { converged, noSignChange, notFound }

/// Resultado del cálculo de la tasa interna de retorno.
class IrrResult {
  const IrrResult._({
    required this.status,
    required this.message,
    this.value,
    this.roots = const [],
  });

  factory IrrResult.converged(double value, {List<double> roots = const []}) {
    final multiple = roots.length > 1;
    return IrrResult._(
      status: IrrStatus.converged,
      value: value,
      roots: roots,
      message: multiple
          ? 'Se encontraron ${roots.length} tasas que hacen VAN = 0 '
                '(flujo con varios cambios de signo). Se muestra la más '
                'cercana a la tasa de descuento; interprétala con cuidado.'
          : 'La TIR convergió correctamente.',
    );
  }

  factory IrrResult.noSignChange() {
    return const IrrResult._(
      status: IrrStatus.noSignChange,
      message:
          'No se puede calcular la TIR: el flujo de caja no tiene cambio de '
          'signo (todos los flujos son positivos o todos son negativos).',
    );
  }

  factory IrrResult.notFound(String message) {
    return IrrResult._(status: IrrStatus.notFound, message: message);
  }

  final IrrStatus status;

  /// TIR como fracción decimal (0.12 = 12 %). Nula si no es válida.
  final double? value;

  /// Todas las raíces encontradas en el rango analizado.
  final List<double> roots;

  final String message;

  bool get isValid => status == IrrStatus.converged && value != null;

  bool get hasMultipleRoots => roots.length > 1;
}
