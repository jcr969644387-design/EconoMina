import 'package:flutter/widgets.dart';

import 'project_controller.dart';

/// Expone el [ProjectController] a todo el árbol de widgets.
class ProjectScope extends InheritedNotifier<ProjectController> {
  const ProjectScope({
    super.key,
    required ProjectController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Obtiene el controlador y reconstruye el widget cuando cambia.
  static ProjectController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProjectScope>();
    assert(scope != null, 'No se encontró ProjectScope en el árbol.');
    return scope!.notifier!;
  }

  /// Obtiene el controlador sin suscribirse a cambios (para callbacks).
  static ProjectController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ProjectScope>();
    assert(scope != null, 'No se encontró ProjectScope en el árbol.');
    return scope!.notifier!;
  }
}
