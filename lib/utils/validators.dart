import 'formatters.dart';
import 'number_parser.dart';

/// Validadores de campos de formulario con mensajes comprensibles.
class Validators {
  const Validators._();

  static const String requiredMessage =
      'Dato incompleto: este campo es obligatorio.';

  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredMessage;
    }
    return null;
  }

  static String? number(
    String? text, {
    double? min,
    double? max,
    bool allowZero = true,
    bool integer = false,
  }) {
    if (text == null || text.trim().isEmpty) {
      return requiredMessage;
    }
    final value = NumberParser.parse(text);
    if (value == null) {
      return 'Ingresa un número válido (ejemplo: 12.5 o 12,5).';
    }
    if (integer && value != value.roundToDouble()) {
      return 'Ingresa un número entero.';
    }
    if (min != null && value < min) {
      return min == 0
          ? 'No se permiten valores negativos.'
          : 'El valor mínimo permitido es ${Formatters.plain(min)}.';
    }
    if (!allowZero && value == 0) {
      return 'El valor debe ser mayor que cero.';
    }
    if (max != null && value > max) {
      return 'El valor máximo permitido es ${Formatters.plain(max)}.';
    }
    return null;
  }
}
