/// Resultado de validar datos de entrada.
class ValidationResult {
  const ValidationResult({this.errors = const [], this.warnings = const []});

  /// Errores que impiden calcular.
  final List<String> errors;

  /// Advertencias que permiten calcular, pero deben revisarse.
  final List<String> warnings;

  bool get isValid => errors.isEmpty;

  bool get hasWarnings => warnings.isNotEmpty;
}
