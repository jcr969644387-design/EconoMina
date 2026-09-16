import 'package:flutter/services.dart';

/// Momentos de la aplicación que reciben una respuesta táctil o sonora.
enum FeedbackEvent {
  /// Elegir una opción o cambiar de sección.
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
    if (sound) {
      await _guard(() => SystemSound.play(_soundFor(event)));
    }
  }

  Future<void> _vibrate(FeedbackEvent event) async {
    switch (event) {
      case FeedbackEvent.seleccion:
        await HapticFeedback.selectionClick();
      case FeedbackEvent.acierto:
        await HapticFeedback.lightImpact();
      case FeedbackEvent.error:
        await HapticFeedback.heavyImpact();
      case FeedbackEvent.logro:
        // Vibración más larga para distinguir el cierre de una actividad.
        await HapticFeedback.vibrate();
    }
  }

  SystemSoundType _soundFor(FeedbackEvent event) {
    return event == FeedbackEvent.error
        ? SystemSoundType.alert
        : SystemSoundType.click;
  }

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Exception {
      // Plataforma sin soporte: la retroalimentación es opcional.
    }
  }
}
