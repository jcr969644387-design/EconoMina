/// Convierte texto ingresado por el estudiante en número.
///
/// Acepta punto o coma decimal ("12.5" o "12,5"). Si hay varias comas o una
/// coma junto con un punto, las comas se consideran separadores de miles.
class NumberParser {
  const NumberParser._();

  static double? parse(String? text) {
    if (text == null) {
      return null;
    }
    var cleaned = text.trim().replaceAll(' ', '');
    if (cleaned.isEmpty) {
      return null;
    }
    final commaCount = ','.allMatches(cleaned).length;
    final hasDot = cleaned.contains('.');
    if (commaCount == 1 && !hasDot) {
      cleaned = cleaned.replaceAll(',', '.');
    } else {
      cleaned = cleaned.replaceAll(',', '');
    }
    final value = double.tryParse(cleaned);
    if (value == null || value.isNaN || value.isInfinite) {
      return null;
    }
    return value;
  }
}
