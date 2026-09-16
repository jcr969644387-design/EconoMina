# Registro de cambios

Todas las versiones siguen [Versionado Semántico](https://semver.org/lang/es/).

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
