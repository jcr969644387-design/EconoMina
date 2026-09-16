import 'package:economina/models/project_data.dart';
import 'package:economina/models/scenario.dart';
import 'package:economina/services/case_repository.dart';
import 'package:economina/services/progress_store.dart';
import 'package:economina/services/project_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('Serialización del proyecto', () {
    test('ida y vuelta conserva todos los datos', () {
      final projects = [
        baseProject().copyWith(taxEnabled: true, currency: 'PEN'),
        for (final item in const CaseRepository().all()) item.project,
      ];
      for (final project in projects) {
        final copy = ProjectData.fromJson(project.toJson());
        expect(copy, isNotNull, reason: project.name);
        expect(copy!.toJson(), project.toJson(), reason: project.name);
      }
    });

    test('rechaza datos incompletos o dañados', () {
      final json = baseProject().toJson();
      expect(ProjectData.fromJson(null), isNull);
      expect(ProjectData.fromJson('texto'), isNull);
      expect(ProjectData.fromJson({...json, 'metalPrice': 'caro'}), isNull);
      expect(
        ProjectData.fromJson({...json, 'mineralType': 'kryptonita'}),
        isNull,
      );
      expect(
        ProjectData.fromJson({...json, 'costs': <String, Object>{}}),
        isNull,
      );
      final withoutName = Map<String, Object>.of(json)..remove('name');
      expect(ProjectData.fromJson(withoutName), isNull);
    });
  });

  group('Progreso guardado', () {
    test('guarda y recupera proyecto, escenario y progreso', () async {
      final store = MemoryProgressStore();
      final first = ProjectController(store: store);
      first
        ..updateProject(baseProject().copyWith(metalPrice: 4.5))
        ..setScenario(ScenarioType.optimista)
        ..registerQuizResult(12, 17)
        ..registerNumericResult(5, 6)
        ..markCaseSolved('caso-1-rentable');
      await flush();
      first.dispose();

      final second = ProjectController(store: store);
      addTearDown(second.dispose);
      expect(second.restored, isFalse);
      await second.restore();
      expect(second.restored, isTrue);
      expect(second.project.metalPrice, 4.5);
      expect(second.scenario, ScenarioType.optimista);
      expect(second.bestQuizScore, 12);
      expect(second.quizQuestionCount, 17);
      expect(second.bestNumericScore, 5);
      expect(second.numericExerciseCount, 6);
      expect(second.attempts, 2);
      expect(second.solvedCases, contains('caso-1-rentable'));
    });

    test('conserva el mejor puntaje y reinicia el progreso', () async {
      final controller = ProjectController();
      addTearDown(controller.dispose);
      controller
        ..registerQuizResult(10, 17)
        ..registerQuizResult(6, 17);
      expect(controller.bestQuizScore, 10);
      controller.resetProgress();
      expect(controller.bestQuizScore, 0);
      expect(controller.attempts, 0);
      expect(controller.solvedCases, isEmpty);
    });

    test('descarta un proyecto guardado inválido', () async {
      final invalid = baseProject().copyWith(metalPrice: -1).toJson();
      final store = MemoryProgressStore({
        'project': invalid,
        'scenario': 'desconocido',
        'bestQuizScore': -3,
        'solvedCases': ['caso-2-van-negativo', 7],
      });
      final controller = ProjectController(store: store);
      addTearDown(controller.dispose);
      await controller.restore();
      expect(controller.project.metalPrice, 4.0);
      expect(controller.scenario, ScenarioType.base);
      expect(controller.bestQuizScore, 0);
      expect(controller.solvedCases, {'caso-2-van-negativo'});
      expect(controller.evaluation, isNotNull);
    });

    test('usa shared_preferences en el dispositivo', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesProgressStore();
      expect(await store.load(), isNull);

      final controller = ProjectController(store: store);
      controller.registerQuizResult(9, 17);
      await flush();
      controller.dispose();

      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!['bestQuizScore'], 9);

      await store.clear();
      expect(await store.load(), isNull);
    });

    test('ignora datos guardados dañados', () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesProgressStore.defaultKey: '{no es json',
      });
      expect(await SharedPreferencesProgressStore().load(), isNull);
    });
  });
}
