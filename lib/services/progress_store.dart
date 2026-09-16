import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento local del progreso y del proyecto activo.
///
/// Los datos nunca salen del dispositivo. La interfaz permite usar un
/// almacenamiento en memoria en las pruebas.
abstract interface class ProgressStore {
  Future<Map<String, Object?>?> load();

  Future<void> save(Map<String, Object?> data);

  Future<void> clear();
}

/// Almacenamiento en memoria (se pierde al cerrar la aplicación).
class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore([Map<String, Object?>? initial])
    : _data = initial == null ? null : Map.of(initial);

  Map<String, Object?>? _data;

  /// Últimos datos guardados (útil para pruebas).
  Map<String, Object?>? get data => _data == null ? null : Map.of(_data!);

  @override
  Future<Map<String, Object?>?> load() async => data;

  @override
  Future<void> save(Map<String, Object?> data) async {
    _data = jsonDecode(jsonEncode(data)) as Map<String, Object?>;
  }

  @override
  Future<void> clear() async {
    _data = null;
  }
}

/// Almacenamiento persistente con `shared_preferences` (sin conexión).
class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferencesProgressStore({this.key = defaultKey});

  static const String defaultKey = 'economina.progress.v1';

  final String key;

  @override
  Future<Map<String, Object?>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) {
        return null;
      }
      final decoded = jsonDecode(raw);
      return decoded is Map<String, Object?> ? decoded : null;
    } on Exception {
      // Datos dañados o almacenamiento no disponible: se usa el ejemplo.
      return null;
    }
  }

  @override
  Future<void> save(Map<String, Object?> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } on Exception {
      // El simulador sigue funcionando aunque no se pueda guardar.
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } on Exception {
      // Sin acción: no hay datos que limpiar.
    }
  }
}
