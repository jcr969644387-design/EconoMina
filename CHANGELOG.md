# Registro de cambios

Todas las versiones siguen [Versionado Semántico](https://semver.org/lang/es/).

## [1.2.0] - 2026-09-16

### Añadido

- Retroalimentación táctil y sonora en toda la aplicación: vibración y un sonido corto del sistema al elegir una opción, al acertar, al fallar y al cerrar una práctica, aplicar datos o resolver un caso.
- Interruptores de vibración y sonido en la pantalla de inicio; la preferencia se guarda junto con el progreso y llega activada.
- `FeedbackService` sobre `HapticFeedback` y `SystemSound`, sin paquetes externos, archivos de audio ni el permiso `VIBRATE` de Android.
- Pruebas de la retroalimentación: preferencias, persistencia y llamadas reales al canal de la plataforma.

### Corregido

- El flujo `build_apk.yml` no se ejecutaba nunca porque solo se activaba de forma manual o con etiquetas `v*` que el repositorio no tenía. Ahora compila el APK en cada `push` a `main` y lo adjunta a una publicación de GitHub cuando se etiqueta una versión.

## [1.1.0] - 2026-09-16

### Añadido

- Progreso persistente en el dispositivo (casos resueltos, mejores puntajes, intentos, escenario y proyecto activo) con `shared_preferences` y opción para reiniciarlo.
- Práctica numérica en la evaluación: 8 tipos de ejercicios generados con semilla, verificación con tolerancia y solución paso a paso.
- Precio y ley de equilibrio (VAN = 0) con margen de seguridad en el módulo VAN.
- Recorrido de aprendizaje sugerido en la pantalla de inicio.
- Pruebas de persistencia, práctica numérica, puntos de equilibrio y nuevos flujos de widgets (caso empresarial, práctica numérica, VAN y reinicio de progreso).

### Cambiado

- Proyecto Android alineado con la plantilla oficial actual de Flutter estable: Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0 y Java 17.
- Integración continua anclada a Flutter 3.47.x (canal estable) para compilaciones reproducibles.
- Colecciones con elementos nulos opcionales según la regla `use_null_aware_elements` de `lints` 6.1.
- `TextPainter` se libera después de dibujar los ejes de los gráficos.

## [1.0.0] - 2026-09-16

### Añadido

- MVP con 12 módulos: inicio, datos del proyecto, costos mineros, ley de corte, producción e ingresos, flujo económico, VAN, TIR, sensibilidad, casos empresariales, evaluación práctica y tutor económico local.
- Motor económico por capas: costos, producción, ley de corte, flujo de caja, VAN, TIR (barrido + bisección con detección de raíces múltiples), escenarios y sensibilidad.
- Validación de datos con mensajes comprensibles (precio, recuperación, ley, reservas, producción, vida útil, tasa, costos y compatibilidad reservas/producción/vida útil).
- Seis casos empresariales ficticios verificados por pruebas automáticas.
- Banco de 17 preguntas y ejercicios con retroalimentación.
- Tutor local basado en reglas detrás de la interfaz `TutorEngine`, preparada para un motor de IA futuro.
- Gráficos de barras y líneas sin dependencias externas, tablas con desplazamiento horizontal e indicadores de rentabilidad y riesgo.
- Pruebas unitarias y de widgets.
- Flujos de GitHub Actions para CI y compilación del APK universal.
- Documentación: fórmulas, arquitectura y supuestos.
