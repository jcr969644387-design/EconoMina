import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Serie de datos para los gráficos simples.
class ChartSeries {
  const ChartSeries({
    required this.name,
    required this.values,
    required this.color,
  });

  final String name;
  final List<double> values;
  final Color color;
}

/// Formateador de etiquetas del eje vertical.
typedef AxisFormatter = String Function(double value);

String _defaultFormatter(double value) {
  final abs = value.abs();
  if (abs >= 1e9) {
    return '${(value / 1e9).toStringAsFixed(1)}B';
  }
  if (abs >= 1e6) {
    return '${(value / 1e6).toStringAsFixed(1)}M';
  }
  if (abs >= 1e3) {
    return '${(value / 1e3).toStringAsFixed(1)}k';
  }
  return value.toStringAsFixed(abs < 10 ? 2 : 0);
}

/// Tarjeta contenedora de un gráfico con título y leyenda.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.series = const [],
    this.subtitle,
  });

  final String title;
  final Widget chart;
  final List<ChartSeries> series;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = subtitle;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (note != null) Text(note, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            SizedBox(height: 190, child: chart),
            if (series.length > 1) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final item in series)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 12, height: 12, color: item.color),
                        const SizedBox(width: 4),
                        Text(item.name, style: theme.textTheme.labelSmall),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gráfico de barras simple (admite valores negativos).
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.negativeColor,
    this.formatter,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color? negativeColor;
  final AxisFormatter? formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Gráfico de barras',
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(
          values: values,
          labels: labels,
          color: color,
          negativeColor: negativeColor ?? theme.colorScheme.error,
          axisColor: theme.colorScheme.outline,
          textColor: theme.colorScheme.onSurface,
          formatter: formatter ?? _defaultFormatter,
        ),
      ),
    );
  }
}

/// Gráfico de líneas simple con una o varias series.
class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({
    super.key,
    required this.series,
    required this.labels,
    this.formatter,
    this.referenceValue,
  });

  final List<ChartSeries> series;
  final List<String> labels;
  final AxisFormatter? formatter;

  /// Línea horizontal de referencia opcional (por ejemplo, VAN = 0).
  final double? referenceValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Gráfico de líneas',
      child: CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(
          series: series,
          labels: labels,
          axisColor: theme.colorScheme.outline,
          textColor: theme.colorScheme.onSurface,
          referenceColor: theme.colorScheme.error,
          formatter: formatter ?? _defaultFormatter,
          referenceValue: referenceValue,
        ),
      ),
    );
  }
}

/// Rango vertical común a ambos gráficos.
class _Range {
  _Range(Iterable<double> values, {double? include}) {
    var low = 0.0;
    var high = 0.0;
    for (final value in values) {
      if (!value.isFinite) {
        continue;
      }
      low = math.min(low, value);
      high = math.max(high, value);
    }
    if (include != null) {
      low = math.min(low, include);
      high = math.max(high, include);
    }
    if (high == low) {
      high = low + 1;
    }
    final padding = (high - low) * 0.05;
    min = low < 0 ? low - padding : low;
    max = high > 0 ? high + padding : high;
  }

  late final double min;
  late final double max;

  double get span => max - min;
}

const double _leftAxis = 48;
const double _bottomAxis = 22;

void _drawText(
  Canvas canvas,
  String text,
  Offset position,
  Color color, {
  double maxWidth = 60,
  TextAlign align = TextAlign.left,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 9),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);
  var dx = position.dx;
  if (align == TextAlign.right) {
    dx -= painter.width;
  } else if (align == TextAlign.center) {
    dx -= painter.width / 2;
  }
  painter
    ..paint(canvas, Offset(dx, position.dy - painter.height / 2))
    ..dispose();
}

void _drawAxes(
  Canvas canvas,
  Rect plot,
  _Range range,
  Color axisColor,
  Color textColor,
  AxisFormatter formatter,
) {
  final axisPaint = Paint()
    ..color = axisColor.withValues(alpha: 0.5)
    ..strokeWidth = 1;
  for (var i = 0; i <= 4; i++) {
    final value = range.min + range.span * i / 4;
    final y = plot.bottom - plot.height * i / 4;
    canvas.drawLine(
      Offset(plot.left, y),
      Offset(plot.right, y),
      axisPaint..color = axisColor.withValues(alpha: 0.15),
    );
    _drawText(
      canvas,
      formatter(value),
      Offset(plot.left - 4, y),
      textColor,
      maxWidth: _leftAxis - 6,
      align: TextAlign.right,
    );
  }
  final zeroY = plot.bottom - (0 - range.min) / range.span * plot.height;
  canvas.drawLine(
    Offset(plot.left, zeroY),
    Offset(plot.right, zeroY),
    Paint()
      ..color = axisColor
      ..strokeWidth = 1.2,
  );
  canvas.drawLine(
    Offset(plot.left, plot.top),
    Offset(plot.left, plot.bottom),
    Paint()
      ..color = axisColor
      ..strokeWidth = 1.2,
  );
}

void _drawXLabels(
  Canvas canvas,
  Rect plot,
  List<String> labels,
  Color textColor,
  double Function(int index) xOf,
) {
  if (labels.isEmpty) {
    return;
  }
  final step = math.max(1, (labels.length / 8).ceil());
  for (var i = 0; i < labels.length; i += step) {
    _drawText(
      canvas,
      labels[i],
      Offset(xOf(i), plot.bottom + _bottomAxis / 2 + 2),
      textColor,
      maxWidth: 48,
      align: TextAlign.center,
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.color,
    required this.negativeColor,
    required this.axisColor,
    required this.textColor,
    required this.formatter,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final Color negativeColor;
  final Color axisColor;
  final Color textColor;
  final AxisFormatter formatter;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= _leftAxis) {
      return;
    }
    final plot = Rect.fromLTRB(
      _leftAxis,
      6,
      size.width - 6,
      size.height - _bottomAxis,
    );
    final range = _Range(values);
    _drawAxes(canvas, plot, range, axisColor, textColor, formatter);
    final slot = plot.width / values.length;
    final barWidth = math.max(2.0, slot * 0.65);
    final zeroY = plot.bottom - (0 - range.min) / range.span * plot.height;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (!value.isFinite) {
        continue;
      }
      final y = plot.bottom - (value - range.min) / range.span * plot.height;
      final left = plot.left + slot * i + (slot - barWidth) / 2;
      final rect = Rect.fromLTRB(
        left,
        math.min(y, zeroY),
        left + barWidth,
        math.max(y, zeroY),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = value >= 0 ? color : negativeColor,
      );
    }
    _drawXLabels(
      canvas,
      plot,
      labels,
      textColor,
      (index) => plot.left + slot * index + slot / 2,
    );
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.labels != labels ||
        oldDelegate.color != color;
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.labels,
    required this.axisColor,
    required this.textColor,
    required this.referenceColor,
    required this.formatter,
    this.referenceValue,
  });

  final List<ChartSeries> series;
  final List<String> labels;
  final Color axisColor;
  final Color textColor;
  final Color referenceColor;
  final AxisFormatter formatter;
  final double? referenceValue;

  @override
  void paint(Canvas canvas, Size size) {
    final count = series.fold<int>(
      0,
      (current, item) => math.max(current, item.values.length),
    );
    if (count == 0 || size.width <= _leftAxis) {
      return;
    }
    final plot = Rect.fromLTRB(
      _leftAxis,
      6,
      size.width - 10,
      size.height - _bottomAxis,
    );
    final range = _Range(
      series.expand((item) => item.values),
      include: referenceValue,
    );
    _drawAxes(canvas, plot, range, axisColor, textColor, formatter);

    double xOf(int index) => count == 1
        ? plot.center.dx
        : plot.left + plot.width * index / (count - 1);
    double yOf(double value) =>
        plot.bottom - (value - range.min) / range.span * plot.height;

    final reference = referenceValue;
    if (reference != null) {
      final y = yOf(reference);
      final paint = Paint()
        ..color = referenceColor
        ..strokeWidth = 1;
      for (var x = plot.left; x < plot.right; x += 8) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 4, plot.right), y),
          paint,
        );
      }
    }

    for (final item in series) {
      final path = Path();
      var started = false;
      for (var i = 0; i < item.values.length; i++) {
        final value = item.values[i];
        if (!value.isFinite) {
          started = false;
          continue;
        }
        final point = Offset(xOf(i), yOf(value));
        if (started) {
          path.lineTo(point.dx, point.dy);
        } else {
          path.moveTo(point.dx, point.dy);
          started = true;
        }
        canvas.drawCircle(point, 2.5, Paint()..color = item.color);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = item.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    _drawXLabels(canvas, plot, labels, textColor, xOf);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.labels != labels ||
        oldDelegate.referenceValue != referenceValue;
  }
}
