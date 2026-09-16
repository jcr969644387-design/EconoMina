import 'package:flutter/material.dart';

import '../models/profitability.dart';

/// Paleta inspirada en minería (cobre, roca), finanzas (azul) y
/// sostenibilidad (verde).
class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF1F6F5C);
  static const Color copper = Color(0xFFB0643A);
  static const Color finance = Color(0xFF1E4E8C);
  static const Color rock = Color(0xFF5D5A55);
  static const Color positive = Color(0xFF2E7D32);
  static const Color neutral = Color(0xFFB7791F);
  static const Color negative = Color(0xFFC62828);

  static Color profitability(Profitability value) {
    switch (value) {
      case Profitability.atractivo:
        return positive;
      case Profitability.indiferente:
        return neutral;
      case Profitability.noAtractivo:
        return negative;
    }
  }

  static Color risk(RiskLevel value) {
    switch (value) {
      case RiskLevel.bajo:
        return positive;
      case RiskLevel.medio:
        return const Color(0xFFE65100);
      case RiskLevel.alto:
        return negative;
    }
  }

  static Color signed(double value) => value >= 0 ? positive : negative;
}

/// Tema Material 3 de la aplicación (modo claro por defecto).
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      secondary: AppColors.copper,
      tertiary: AppColors.finance,
    );
    // La aplicacion emite su propio sonido y vibracion con FeedbackService,
    // que el estudiante puede apagar. Se desactiva la respuesta integrada de
    // Material para no reproducirla dos veces ni fuera de esa preferencia.
    const silent = ButtonStyle(enableFeedback: false);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      filledButtonTheme: const FilledButtonThemeData(style: silent),
      elevatedButtonTheme: const ElevatedButtonThemeData(style: silent),
      outlinedButtonTheme: const OutlinedButtonThemeData(style: silent),
      textButtonTheme: const TextButtonThemeData(style: silent),
      iconButtonTheme: const IconButtonThemeData(style: silent),
      segmentedButtonTheme: const SegmentedButtonThemeData(style: silent),
      listTileTheme: const ListTileThemeData(enableFeedback: false),
    );
  }
}
