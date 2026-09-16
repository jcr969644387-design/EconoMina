import 'package:economina/app.dart';
import 'package:economina/models/learning_models.dart';
import 'package:economina/screens/cases_screen.dart';
import 'package:economina/screens/module_catalog.dart';
import 'package:economina/screens/npv_screen.dart';
import 'package:economina/screens/quiz_screen.dart';
import 'package:economina/screens/tutor_screen.dart';
import 'package:economina/services/case_repository.dart';
import 'package:economina/services/numeric_exercise_generator.dart';
import 'package:economina/services/project_controller.dart';
import 'package:economina/services/project_scope.dart';
import 'package:economina/theme/app_theme.dart';
import 'package:economina/utils/app_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget wrap(Widget child, ProjectController controller) {
  return ProjectScope(
    controller: controller,
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'la pantalla principal carga con nombre, subtítulo y advertencia',
    (tester) async {
      await tester.pumpWidget(const EconoMinaApp());
      await tester.pumpAndSettle();

      expect(find.text(AppTexts.appName), findsWidgets);
      expect(
        find.text('EconoMina: Simulador de Economía y Evaluación Minera'),
        findsWidgets,
      );
      expect(find.text(AppTexts.disclaimerTitle), findsWidgets);
      expect(find.text(AppTexts.disclaimer), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('la pantalla principal muestra los botones de módulos', (
    tester,
  ) async {
    await tester.pumpWidget(const EconoMinaApp());
    await tester.pumpAndSettle();

    expect(appModules, hasLength(11));
    for (final module in appModules) {
      expect(find.byKey(Key('module-${module.id}')), findsOneWidget);
    }
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('un botón de módulo abre su pantalla', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(const EconoMinaApp());
    await tester.pumpAndSettle();

    final button = find.byKey(const Key('module-van'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('Valor actual neto (VAN)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('todos los módulos se construyen sin errores', (tester) async {
    useTallScreen(tester);
    for (final module in appModules) {
      final controller = ProjectController();
      await tester.pumpWidget(
        wrap(Builder(builder: module.builder), controller),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget, reason: module.title);
      expect(tester.takeException(), isNull, reason: module.title);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
  });

  testWidgets('la evaluación práctica califica una respuesta', (tester) async {
    useTallScreen(tester);
    final controller = ProjectController();
    addTearDown(controller.dispose);
    const question = QuizQuestion(
      topic: 'VAN',
      prompt: '¿Un VAN positivo indica que el proyecto crea valor?',
      options: ['Sí, bajo los supuestos ingresados', 'No'],
      correctIndex: 0,
      explanation: 'El VAN positivo supera la tasa exigida.',
    );
    await tester.pumpWidget(
      wrap(const QuizScreen(questions: [question]), controller),
    );

    await tester.tap(find.byKey(const Key('option-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('quiz-check')));
    await tester.pump();
    expect(find.text('¡Correcto!'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quiz-next')));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(controller.bestQuizScore, 1);
  });

  testWidgets('el tutor responde sin conexión', (tester) async {
    useTallScreen(tester);
    final controller = ProjectController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(const TutorScreen(), controller));

    await tester.enterText(
      find.byKey(const Key('tutor-input')),
      '¿Qué es el VAN?',
    );
    await tester.tap(find.byKey(const Key('tutor-ask')));
    await tester.pumpAndSettle();

    expect(find.text('También puedes preguntar:'), findsOneWidget);
    expect(find.textContaining('En tu proyecto:'), findsOneWidget);
  });

  testWidgets('la práctica numérica verifica un resultado calculado', (
    tester,
  ) async {
    useTallScreen(tester);
    final controller = ProjectController();
    addTearDown(controller.dispose);
    final expected = NumericExerciseGenerator(seed: 42).generate().first;
    await tester.pumpWidget(
      wrap(
        const QuizScreen(initialMode: PracticeMode.ejercicios, numericSeed: 42),
        controller,
      ),
    );

    expect(find.text(expected.prompt), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('numeric-answer')),
      expected.answer.toStringAsFixed(6),
    );
    await tester.tap(find.byKey(const Key('numeric-check')));
    await tester.pump();

    expect(find.text('¡Resultado correcto!'), findsOneWidget);
    expect(find.text('Solución paso a paso'), findsOneWidget);
  });

  testWidgets('la práctica numérica rechaza texto no numérico', (tester) async {
    useTallScreen(tester);
    final controller = ProjectController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrap(
        const QuizScreen(initialMode: PracticeMode.ejercicios, numericSeed: 5),
        controller,
      ),
    );
    await tester.enterText(find.byKey(const Key('numeric-answer')), 'abc');
    await tester.tap(find.byKey(const Key('numeric-check')));
    await tester.pump();
    expect(find.textContaining('Ingresa un número válido'), findsOneWidget);
  });

  testWidgets('un caso empresarial se resuelve y registra el progreso', (
    tester,
  ) async {
    useTallScreen(tester);
    final controller = ProjectController();
    addTearDown(controller.dispose);
    final item = const CaseRepository().all().first;
    await tester.pumpWidget(
      wrap(CaseDetailScreen(caseStudy: item), controller),
    );

    final reveal = find.byKey(const Key('reveal-case'));
    await tester.ensureVisible(reveal);
    expect(tester.widget<FilledButton>(reveal).onPressed, isNull);

    final choice = find.text(StudentDecision.continuar.label);
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pump();
    await tester.tap(reveal);
    await tester.pump();

    expect(controller.solvedCases, contains(item.id));
    await tester.scrollUntilVisible(
      find.text('Solución calculada'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Solución calculada'), findsOneWidget);
  });

  testWidgets('el módulo VAN muestra el precio de equilibrio', (tester) async {
    useTallScreen(tester);
    final controller = ProjectController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(wrap(const NpvScreen(), controller));
    await tester.pumpAndSettle();

    final card = find.byKey(const Key('breakeven-price'));
    await tester.ensureVisible(card);
    expect(card, findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.textContaining('3.727')),
      findsOneWidget,
    );
  });

  testWidgets('el progreso se puede reiniciar desde el inicio', (tester) async {
    useTallScreen(tester);
    final controller = ProjectController()..registerQuizResult(8, 17);
    addTearDown(controller.dispose);
    await tester.pumpWidget(EconoMinaApp(controller: controller));
    await tester.pumpAndSettle();

    final reset = find.byKey(const Key('reset-progress'));
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reiniciar'));
    await tester.pumpAndSettle();

    expect(controller.bestQuizScore, 0);
    expect(find.text('Progreso reiniciado.'), findsOneWidget);
  });
}
