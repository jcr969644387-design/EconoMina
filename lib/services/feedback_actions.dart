import 'dart:async';

import 'package:flutter/widgets.dart';

import 'feedback_service.dart';
import 'project_scope.dart';

/// Envuelve los callbacks de la interfaz para que respondan con sonido o
/// vibración, sin cambiar el diseño de las pantallas.
///
/// Cada envoltura devuelve `null` cuando el callback original es `null`, de
/// modo que un control deshabilitado sigue viéndose y comportándose como tal.
extension FeedbackActions on BuildContext {
  /// Emite [event] respetando las preferencias del estudiante.
  void emitFeedback(FeedbackEvent event) {
    unawaited(ProjectScope.read(this).playFeedback(event));
  }

  /// Botón o acción principal: sonido corto y vibración muy ligera.
  VoidCallback? onButton(VoidCallback? action) {
    if (action == null) {
      return null;
    }
    return () {
      emitFeedback(FeedbackEvent.boton);
      action();
    };
  }

  /// Campo de texto, opción o elemento interactivo: solo vibración ligera.
  VoidCallback? onInteraction(VoidCallback? action) {
    if (action == null) {
      return null;
    }
    return () {
      emitFeedback(FeedbackEvent.seleccion);
      action();
    };
  }

  /// Igual que [onInteraction] para controles que entregan un valor
  /// (interruptores, desplegables, grupos de opciones).
  ValueChanged<T>? onSelection<T>(ValueChanged<T>? action) {
    if (action == null) {
      return null;
    }
    return (value) {
      emitFeedback(FeedbackEvent.seleccion);
      action(value);
    };
  }
}
