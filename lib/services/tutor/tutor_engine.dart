import 'tutor_models.dart';

/// Contrato común para cualquier tutor económico.
///
/// El MVP usa un tutor local basado en reglas. Una versión futura puede
/// implementar esta interfaz con un servicio de inteligencia artificial sin
/// cambiar las pantallas: basta con inyectar otra implementación.
abstract interface class TutorEngine {
  /// Nombre visible del motor (por ejemplo, "Tutor local basado en reglas").
  String get name;

  /// Indica si el motor requiere conexión a internet.
  bool get requiresNetwork;

  Future<TutorAnswer> answer(TutorQuery query);
}
