import 'package:flutter/material.dart';

import '../models/profitability.dart';
import '../models/validation_result.dart';
import '../theme/app_theme.dart';
import '../utils/app_texts.dart';

/// Encabezado de sección con subtítulo opcional.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = subtitle;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text, style: theme.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

/// Advertencia académica visible.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.school_outlined,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.disclaimerTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTexts.disclaimer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador de que los resultados son simulados.
class SimulatedBadge extends StatelessWidget {
  const SimulatedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_outlined,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              AppTexts.simulatedBadge,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista simple con viñetas.
class BulletList extends StatelessWidget {
  const BulletList({super.key, required this.items, this.icon});

  final List<String> items;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8),
                  child: Icon(
                    icon ?? Icons.circle,
                    size: icon == null ? 8 : 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Tarjeta con fórmula, variables, unidades, supuestos y limitaciones.
class FormulaCard extends StatelessWidget {
  const FormulaCard({
    super.key,
    required this.title,
    required this.formula,
    this.variables = const [],
    this.assumptions = const [],
    this.limitations = const [],
  });

  final String title;
  final String formula;
  final List<String> variables;
  final List<String> assumptions;
  final List<String> limitations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.functions, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                formula,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (variables.isNotEmpty) ...[
              const _MiniTitle('Variables y unidades'),
              BulletList(items: variables),
            ],
            if (assumptions.isNotEmpty) ...[
              const _MiniTitle('Supuestos'),
              BulletList(items: assumptions),
            ],
            if (limitations.isNotEmpty) ...[
              const _MiniTitle('Limitaciones del modelo'),
              BulletList(items: limitations),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniTitle extends StatelessWidget {
  const _MiniTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Tarjeta de interpretación educativa.
class InterpretationCard extends StatelessWidget {
  const InterpretationCard({
    super.key,
    required this.text,
    this.color,
    this.title = 'Interpretación educativa',
  });

  final String text;
  final Color? color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accent, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(text, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              AppTexts.interpretationNote,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel de errores y advertencias de validación.
class ValidationPanel extends StatelessWidget {
  const ValidationPanel({super.key, required this.result});

  final ValidationResult result;

  @override
  Widget build(BuildContext context) {
    if (result.isValid && !result.hasWarnings) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final error in result.errors)
          _MessageTile(
            text: error,
            icon: Icons.error_outline,
            color: AppColors.negative,
          ),
        for (final warning in result.warnings)
          _MessageTile(
            text: warning,
            icon: Icons.warning_amber_outlined,
            color: AppColors.risk(RiskLevel.medio),
          ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Aviso cuando el proyecto activo tiene datos inválidos.
class InvalidProjectNotice extends StatelessWidget {
  const InvalidProjectNotice({
    super.key,
    required this.result,
    required this.onFix,
  });

  final ValidationResult result;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'No se puede calcular',
          subtitle: 'Corrige los datos del proyecto para ver resultados.',
        ),
        ValidationPanel(result: result),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onFix,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Corregir datos del proyecto'),
        ),
      ],
    );
  }
}
