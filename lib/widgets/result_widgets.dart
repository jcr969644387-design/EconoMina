import 'package:flutter/material.dart';

import '../models/profitability.dart';
import '../models/scenario.dart';
import '../services/feedback_actions.dart';
import '../theme/app_theme.dart';

/// Tarjeta de indicador (KPI) para mostrar un resultado.
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.caption,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    final note = caption;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: accent),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(note, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// Distribuye tarjetas KPI en una cuadrícula adaptable al ancho.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 720
            ? 4
            : width >= 480
            ? 3
            : 2;
        const spacing = 4.0;
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Indicador de rentabilidad educativa.
class ProfitabilityIndicator extends StatelessWidget {
  const ProfitabilityIndicator({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final Profitability value;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profitability(value);
    final icon = switch (value) {
      Profitability.atractivo => Icons.trending_up,
      Profitability.indiferente => Icons.trending_flat,
      Profitability.noAtractivo => Icons.trending_down,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label: ${value.label}',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de riesgo bajo, medio o alto con tres segmentos.
class RiskIndicator extends StatelessWidget {
  const RiskIndicator({super.key, required this.level, this.explanation});

  final RiskLevel level;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = explanation;
    final active = RiskLevel.values.indexOf(level);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.risk(level)),
                const SizedBox(width: 8),
                Text(
                  level.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.risk(level),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final item in RiskLevel.values)
                  Expanded(
                    child: Container(
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: item.index <= active
                            ? AppColors.risk(item)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bajo', style: theme.textTheme.labelSmall),
                Text('Medio', style: theme.textTheme.labelSmall),
                Text('Alto', style: theme.textTheme.labelSmall),
              ],
            ),
            if (text != null) ...[
              const SizedBox(height: 8),
              Text(text, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// Barra de progreso con etiqueta y valor.
class LabeledProgress extends StatelessWidget {
  const LabeledProgress({
    super.key,
    required this.label,
    required this.value,
    required this.trailing,
    this.color,
  });

  final String label;

  /// Fracción entre 0 y 1.
  final double value;
  final String trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeValue = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
              Text(
                trailing,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: safeValue,
              minHeight: 8,
              color: color ?? theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de escenario pesimista, base u optimista.
class ScenarioSelector extends StatelessWidget {
  const ScenarioSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ScenarioType value;
  final ValueChanged<ScenarioType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ScenarioType>(
          segments: [
            for (final scenario in ScenarioType.values)
              ButtonSegment<ScenarioType>(
                value: scenario,
                label: Text(scenario.label),
              ),
          ],
          selected: {value},
          showSelectedIcon: false,
          onSelectionChanged: context.onSelection(
            (Set<ScenarioType> selection) => onChanged(selection.first),
          ),
        ),
        const SizedBox(height: 4),
        Text(value.description, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
