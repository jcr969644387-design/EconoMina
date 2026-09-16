import '../models/mineral_type.dart';

/// Formateo numérico sin dependencias externas.
///
/// Convención: coma como separador de miles y punto como separador decimal.
class Formatters {
  const Formatters._();

  static String number(double value, {int decimals = 2}) {
    if (value.isNaN || value.isInfinite) {
      return '—';
    }
    final fixed = value.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final integerPart = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      final remaining = integerPart.length - i;
      buffer.write(integerPart[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    if (parts.length > 1) {
      buffer.write('.${parts[1]}');
    }
    final isZero = double.parse(fixed) == 0;
    final sign = value < 0 && !isZero ? '-' : '';
    return '$sign$buffer';
  }

  /// Número sin separadores de miles ni ceros finales (para campos editables).
  static String plain(double value) {
    if (value.isNaN || value.isInfinite) {
      return '';
    }
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toStringAsFixed(0);
    }
    return value
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static String percent(double value, {int decimals = 2}) =>
      '${number(value, decimals: decimals)} %';

  static String money(double value, String currency, {int decimals = 2}) =>
      '$currency ${number(value, decimals: decimals)}';

  static String millions(double value, String currency, {int decimals = 2}) =>
      '$currency ${number(value / 1e6, decimals: decimals)} M';

  static String compactMoney(double value, String currency) {
    if (value.isFinite && value.abs() >= 1e6) {
      return millions(value, currency);
    }
    return money(value, currency);
  }

  static String grade(double value, String unit) =>
      '${number(value, decimals: unit == '%' ? 3 : 2)} $unit';

  static String tonnes(double value) {
    if (value.abs() >= 1e6) {
      return '${number(value / 1e6, decimals: 2)} Mt';
    }
    return '${number(value, decimals: 0)} t';
  }
}

/// Presentación compacta de cantidades de metal.
class MetalDisplay {
  const MetalDisplay._(this.divisor, this.label);

  factory MetalDisplay.of(MineralType type) {
    return type.metalUnit == 'lb'
        ? const MetalDisplay._(1e6, 'M lb')
        : const MetalDisplay._(1e3, 'koz');
  }

  final double divisor;
  final String label;

  double scale(double metal) => metal / divisor;

  String format(double metal, {int decimals = 2}) =>
      '${Formatters.number(metal / divisor, decimals: decimals)} $label';
}
