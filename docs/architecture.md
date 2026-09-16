# Arquitectura de EconoMina

## Principios

- **Capas separadas:** la lógica económica no depende de Flutter y se prueba de forma aislada.
- **Datos inmutables:** `ProjectData` y `MiningCosts` se modifican con `copyWith`.
- **Sin conexión:** no hay llamadas de red, cuentas ni dependencias de terceros en tiempo de ejecución.
- **Extensible:** nuevos minerales, casos, preguntas o motores de tutoría se agregan sin tocar las pantallas.

## Capas

```
┌──────────────────────────────────────────────────────────┐
│ screens/  (12 módulos)          widgets/ (KPI, tablas,   │
│                                 gráficos, formularios)   │
├──────────────────────────────────────────────────────────┤
│ services/  ProjectController (ChangeNotifier)            │
│            ProjectScope (InheritedNotifier)              │
│            ProgressStore (memoria / shared_preferences)  │
│            NumericExerciseGenerator                      │
│            ValidationService · CaseRepository ·          │
│            QuizRepository · tutor/ (TutorEngine)         │
├──────────────────────────────────────────────────────────┤
│ calculators/  Cost · Production · CutoffGrade ·          │
│               CashFlow · Npv · Irr · Scenario ·          │
│               Sensitivity · Breakeven ·                  │
│               ProfitabilityClassifier ·                  │
│               ProjectEvaluator (orquestador)             │
├──────────────────────────────────────────────────────────┤
│ models/  ProjectData · MiningCosts · MineralType ·       │
│          ScenarioType · CashFlowRow · IrrResult · ...    │
└──────────────────────────────────────────────────────────┘
        utils/ (formato, lectura de números, textos)
        theme/ (Material 3, colores semánticos)
```

Las dependencias van solo hacia abajo: las pantallas usan servicios y calculadoras; las calculadoras usan modelos; los modelos no dependen de nada.

## Flujo de datos

1. `EconoMinaApp` crea un `ProjectController` y lo expone con `ProjectScope`.
2. Las pantallas leen `ProjectScope.of(context)` y se reconstruyen al cambiar el proyecto o el escenario.
3. Los formularios validan cada campo (`Validators`) y luego el proyecto completo (`ValidationService`). Un proyecto inválido **no se aplica**.
4. `ProjectController.evaluation` devuelve un `ProjectEvaluation` (flujo, VAN, TIR, clasificación y riesgo), calculado una vez por proyecto y escenario.
5. Si los datos no son válidos, los módulos muestran `InvalidProjectNotice` con los errores y un acceso para corregirlos.
6. Cada cambio de proyecto, escenario o progreso se guarda con `ProgressStore`. Al iniciar, `ProjectController.restore()` recupera los datos; un proyecto guardado que no pase la validación se descarta y se usa el proyecto de ejemplo.

## Persistencia local

```dart
abstract interface class ProgressStore {
  Future<Map<String, Object?>?> load();
  Future<void> save(Map<String, Object?> data);
  Future<void> clear();
}
```

- `SharedPreferencesProgressStore`: usada por la aplicación; guarda un JSON versionado (`economina.progress.v1`) solo en el dispositivo y tolera datos dañados.
- `MemoryProgressStore`: usada en pruebas y como valor por defecto del controlador.

## Navegación

- `AppShell` con `NavigationBar` de 4 destinos: Inicio, Proyecto, Casos y Tutor.
- La pantalla de inicio abre cualquiera de los 11 módulos restantes con `Navigator.push`.
- `ModuleScaffold` unifica la estructura: barra superior, insignia de "resultados simulados", ancho máximo de 900 px y desplazamiento vertical.

## Tutor preparado para IA

```dart
abstract interface class TutorEngine {
  String get name;
  bool get requiresNetwork;
  Future<TutorAnswer> answer(TutorQuery query);
}
```

- **MVP:** `RuleBasedTutor` detecta el tema con palabras clave normalizadas (sin tildes) y añade una nota con los datos del proyecto activo (`TutorContext`).
- **Futuro:** un `AiTutorEngine` puede implementar la misma interfaz y recibir el mismo `TutorContext`. `TutorScreen` acepta el motor por constructor, por lo que no requiere cambios. Se recomienda mantener el tutor local como respaldo sin conexión y validar las respuestas de IA contra las fórmulas del simulador.

## Gráficos

`SimpleBarChart` y `SimpleLineChart` usan `CustomPainter`, admiten valores negativos, omiten valores no finitos y dibujan una línea de referencia opcional (por ejemplo, VAN = 0). Esto evita dependencias externas y funciona sin conexión.

## Plataforma Android

Alineada con la plantilla oficial de Flutter estable: Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, Java 17, `minSdk`/`targetSdk`/`compileSdk` definidos por Flutter (24/36/36). El CI fija Flutter 3.47.x para que la compilación sea reproducible; al actualizar Flutter, regenera la configuración Android con la nueva plantilla.

## Calidad

| Control | Herramienta |
|---|---|
| Formato | `dart format --set-exit-if-changed` |
| Análisis estático | `flutter analyze` con `flutter_lints` |
| Pruebas unitarias | costos, producción, ley de corte, flujo, VAN, TIR, puntos de equilibrio, sensibilidad, clasificación, validación, casos, preguntas, práctica numérica, persistencia y tutor |
| Pruebas de widgets | pantalla principal, 11 módulos, caso empresarial, evaluación, práctica numérica, VAN, reinicio de progreso y tutor |
| CI | `.github/workflows/flutter_ci.yml` |
| APK | `.github/workflows/build_apk.yml` (APK universal, sin división por ABI) |

## Escalabilidad

- **Minerales:** agregar un valor a `MineralType` con su unidad y factor de conversión.
- **Casos y preguntas:** agregar entradas a `CaseRepository` y `QuizRepository`; las pruebas verifican automáticamente los resultados esperados.
- **Persistencia:** `ProgressStore` permite cambiar a SQLite o a sincronización en la nube sin modificar pantallas ni calculadoras.
- **Nuevos ejercicios:** se agregan como métodos del `NumericExerciseGenerator`.
- **Periodos:** el modelo usa periodos anuales; `ProjectData.evaluationPeriod` deja explícita esta decisión.
