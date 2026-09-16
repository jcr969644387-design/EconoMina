# EconoMina

**EconoMina: Simulador de Economía y Evaluación Minera**

Aplicación móvil educativa (Flutter, Android) para estudiantes de Ingeniería de Minas. Permite evaluar costos, producción, ley de corte, flujo económico, VAN, TIR y sensibilidad de proyectos mineros ficticios, sin conexión a internet.

> **Advertencia académica.** EconoMina es un simulador educativo. No reemplaza una evaluación económica profesional, un estudio de factibilidad, una valorización de reservas, un modelo financiero auditado ni la aprobación de un proyecto minero real. Ningún resultado constituye una recomendación de inversión.

## Objetivo educativo

Comprender cómo las reservas, leyes, recuperación metalúrgica, producción, precios, inversiones, costos y tasas de descuento influyen en la viabilidad económica de un proyecto minero.

## Módulos del MVP

| N.º | Módulo | Qué practica el estudiante |
|---|---|---|
| 1 | Inicio | Proyecto activo, advertencia académica, recorrido sugerido, módulos y progreso guardado |
| 2 | Datos del proyecto | Reservas, ley, recuperación, producción, precio, tasa, vida útil, regalías e impuestos |
| 3 | Costos mineros | CAPEX, OPEX, costos unitarios, costo por unidad de metal y distribución |
| 4 | Ley de corte | Modelo configurable (equilibrio y marginal) y su sensibilidad |
| 5 | Producción e ingresos | Metal contenido y recuperado, ingresos, regalías y margen |
| 6 | Flujo económico | Tabla anual, flujo descontado, acumulado y periodo de recuperación |
| 7 | VAN | Valor actual neto, precio y ley de equilibrio, margen de seguridad y perfil del VAN |
| 8 | TIR | Tasa interna de retorno, convergencia y comparación con la tasa |
| 9 | Sensibilidad | Escenarios pesimista/base/optimista y 8 variables críticas |
| 10 | Casos empresariales | 6 proyectos ficticios con decisión del estudiante y solución |
| 11 | Evaluación práctica | 17 preguntas conceptuales y ejercicios numéricos generados con solución paso a paso |
| 12 | Tutor económico | Tutor local basado en reglas, preparado para IA futura |

## Aprendizaje activo

- **Decidir antes de ver la solución:** en los casos empresariales el estudiante elige continuar, estudiar más o no continuar, y luego compara su decisión con el criterio del simulador.
- **Calcular y recibir retroalimentación:** la práctica numérica genera ejercicios nuevos en cada intento (costo unitario, metal contenido y recuperado, ingresos, ley de corte, valor presente, VAN y recuperación). La respuesta se verifica con tolerancia de redondeo y se explica paso a paso.
- **Pensar como profesional:** el módulo VAN calcula el precio y la ley de equilibrio (VAN = 0) y el margen de seguridad; el módulo de sensibilidad identifica la variable crítica.
- **Sentir la respuesta:** cada comprobación responde con vibración y un sonido corto del sistema (un toque suave al acertar, uno firme al fallar y una vibración más larga al terminar una práctica o resolver un caso). Se puede apagar desde la pantalla de inicio.
- **Medir el progreso:** los casos resueltos, los mejores puntajes y el proyecto activo se guardan en el dispositivo.

## Tecnología

- Flutter estable (CI anclado a 3.47.x), Dart ≥ 3.8, Material 3, modo claro por defecto.
- Android, identificador `com.josuecr1801.economina`; Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0 y Java 17 (plantilla oficial de Flutter).
- Única dependencia: `shared_preferences`, para guardar el progreso **solo en el dispositivo**.
- Vibración y sonido con `HapticFeedback` y `SystemSound` de `flutter/services`: sin paquetes externos, sin archivos de audio y sin el permiso `VIBRATE` de Android.
- Sin red, sin cuentas y sin imágenes externas; gráficos propios con `CustomPainter`.

## Estructura

```
lib/
  main.dart, app.dart
  models/        Datos inmutables (proyecto, costos, escenarios, resultados)
  calculators/   Lógica económica pura y probada
  services/      Estado, validación, casos, preguntas y tutor
  screens/       Pantallas de los 12 módulos
  widgets/       Componentes reutilizables (KPI, tablas, gráficos)
  theme/         Tema Material 3 y colores
  utils/         Formato de números, lectura de datos y textos
test/            Pruebas unitarias y de widgets
docs/            Documentación técnica y educativa
.github/         Integración continua y compilación del APK
```

## Uso local

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run
flutter build apk --release
```

El APK universal queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Integración continua

- `flutter_ci.yml`: en `push` a `main`/`develop` y `pull_request` a `main` verifica formato, análisis estático y pruebas.
- `build_apk.yml`: en `push` a `main`, con etiquetas `v*` o de forma manual (`workflow_dispatch`); ejecuta pruebas, compila el APK universal, lo verifica y lo publica como artefacto `econo-mina-apk`. Con una etiqueta `v*` el APK además se adjunta a una publicación de GitHub, para descargarlo sin iniciar sesión.

## Documentación

- [docs/README.md](docs/README.md): guía de uso educativo.
- [docs/formulas.md](docs/formulas.md): fórmulas y unidades.
- [docs/architecture.md](docs/architecture.md): arquitectura y decisiones técnicas.
- [docs/assumptions.md](docs/assumptions.md): supuestos, limitaciones y datos ficticios.

## Licencia y datos

Todos los proyectos, precios y costos incluidos son **ficticios** y tienen fines exclusivamente académicos.
