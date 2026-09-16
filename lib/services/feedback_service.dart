import 'package:flutter/services.dart';

/// Momentos de la aplicación que reciben una respuesta táctil o sonora.
enum FeedbackEvent {
  /// Pulsar un botón o una acción principal (Calcular, Aplicar, Volver...).
  boton,

  /// Tocar un campo de texto, elegir una opción o mover un selector.
  seleccion,

  /// Respuesta o cálculo correcto.
  acierto,

  /// Respuesta incorrecta o dato inválido.
  error,

  /// Cierre de una práctica, caso resuelto o datos aplicados.
  logro,
}

/// Emite vibraciones cortas y sonidos del sistema.
///
/// Solo usa las APIs de `flutter/services`, por lo que no hacen falta
/// paquetes externos, archivos de audio ni el permiso `VIBRATE` de Android:
/// la vibración se pide con `HapticFeedback`, que el sistema resuelve con la
/// respuesta táctil estándar del dispositivo, y el sonido con `SystemSound`,
/// que respeta el modo silencio del teléfono.
///
/// Todas las vibraciones son cortas y suaves, adecuadas para una aplicación
/// de estudio: nunca se usa una vibración larga.
class FeedbackService {
  const FeedbackService();

  /// Ejecuta la retroalimentación asociada a [event].
  ///
  /// [haptics] y [sound] permiten apagar cada canal por separado. Los fallos
  /// de plataforma se ignoran a propósito: en un equipo sin vibrador o en las
  /// pruebas la aplicación debe seguir funcionando igual.
  Future<void> emit(
    FeedbackEvent event, {
    bool haptics = true,
    bool sound = true,
  }) async {
    if (haptics) {
      await _guard(() => _vibrate(event));
    }
    final tone = _soundFor(event);
    if (sound && tone != null) {
      await _guard(() => SystemSound.play(tone));
    }
  }

  Future<void> _vibrate(FeedbackEvent event) async {
    switch (event) {
      case FeedbackEvent.boton:
      case FeedbackEvent.seleccion:
        // Confirmación mínima del sistema, como la de un selector.
        await HapticFeedback.selectionClick();
      case FeedbackEvent.acierto:
        await HapticFeedback.lightImpact();
      case FeedbackEvent.error:
      case FeedbackEvent.logro:
        await HapticFeedback.mediumImpact();
    }
  }

  /// Sonido de cada evento; `null` cuando el evento solo vibra.
  SystemSoundType? _soundFor(FeedbackEvent event) {
    switch (event) {
      case FeedbackEvent.seleccion:
        // Tocar un campo o un selector solo vibra, para no saturar de clics.
        return null;
      case FeedbackEvent.error:
        return SystemSoundType.alert;
      case FeedbackEvent.boton:
      case FeedbackEvent.acierto:
      case FeedbackEvent.logro:
        return SystemSoundType.click;
    }
  }

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Exception {
      // Plataforma sin soporte: la retroalimentación es opcional.
    }
  }
}
