import 'package:economina/services/feedback_service.dart';
import 'package:economina/services/progress_store.dart';
import 'package:economina/services/project_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registra lo que se pediría al sistema, sin tocar la plataforma.
class RecordingFeedbackService extends FeedbackService {
  final List<FeedbackEvent> events = [];
  final List<bool> withHaptics = [];
  final List<bool> withSound = [];

  @override
  Future<void> emit(
    FeedbackEvent event, {
    bool haptics = true,
    bool sound = true,
  }) async {
    events.add(event);
    withHaptics.add(haptics);
    withSound.add(sound);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Retroalimentación táctil y sonora', () {
    test('viene activada y respeta las preferencias', () async {
      final service = RecordingFeedbackService();
      final controller = ProjectController(feedback: service);
      addTearDown(controller.dispose);

      expect(controller.hapticsEnabled, isTrue);
      expect(controller.soundEnabled, isTrue);

      await controller.playFeedback(FeedbackEvent.acierto);
      expect(service.events, [FeedbackEvent.acierto]);
      expect(service.withHaptics, [true]);
      expect(service.withSound, [true]);

      controller.setSoundEnabled(false);
      await controller.playFeedback(FeedbackEvent.error);
      expect(service.events.last, FeedbackEvent.error);
      expect(service.withHaptics.last, isTrue);
      expect(service.withSound.last, isFalse);

      controller.setHapticsEnabled(false);
      await controller.playFeedback(FeedbackEvent.logro);
      expect(service.events, hasLength(2), reason: 'todo desactivado');
    });

    test('las preferencias se guardan y se recuperan', () async {
      final store = MemoryProgressStore();
      final first = ProjectController(store: store);
      first
        ..setHapticsEnabled(false)
        ..setSoundEnabled(false);
      await Future<void>.delayed(Duration.zero);
      first.dispose();

      final second = ProjectController(store: store);
      addTearDown(second.dispose);
      await second.restore();
      expect(second.hapticsEnabled, isFalse);
      expect(second.soundEnabled, isFalse);
    });

    test('un progreso antiguo mantiene la respuesta activada', () async {
      final store = MemoryProgressStore({'bestQuizScore': 4});
      final controller = ProjectController(store: store);
      addTearDown(controller.dispose);
      await controller.restore();
      expect(controller.bestQuizScore, 4);
      expect(controller.hapticsEnabled, isTrue);
      expect(controller.soundEnabled, isTrue);
    });

    test('reiniciar el progreso no apaga la respuesta', () {
      final controller = ProjectController();
      addTearDown(controller.dispose);
      controller.registerQuizResult(5, 10);
      controller.resetProgress();
      expect(controller.hapticsEnabled, isTrue);
      expect(controller.soundEnabled, isTrue);
    });

    test('el servicio real pide vibración y sonido al sistema', () async {
      final calls = <String>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        calls.add('${call.method}:${call.arguments}');
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );

      const service = FeedbackService();
      await service.emit(FeedbackEvent.seleccion);
      await service.emit(FeedbackEvent.error);
      await service.emit(FeedbackEvent.acierto, sound: false);

      expect(
        calls,
        containsAll(<String>[
          'HapticFeedback.vibrate:HapticFeedbackType.selectionClick',
          'HapticFeedback.vibrate:HapticFeedbackType.heavyImpact',
          'HapticFeedback.vibrate:HapticFeedbackType.lightImpact',
          'SystemSound.play:SystemSoundType.click',
          'SystemSound.play:SystemSoundType.alert',
        ]),
      );
      expect(
        calls.where((call) => call.startsWith('SystemSound')),
        hasLength(2),
        reason: 'el tercer evento va sin sonido',
      );
    });
  });
}
