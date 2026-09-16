import 'package:economina/models/project_data.dart';
import 'package:economina/services/project_controller.dart';
import 'package:economina/services/validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  const validator = ValidationService();

  bool hasError(ProjectData project, String fragment) {
    final result = validator.validateProject(project);
    return !result.isValid &&
        result.errors.any((error) => error.contains(fragment));
  }

  group('Validación de datos', () {
    test('el proyecto base es válido y sin advertencias', () {
      final result = validator.validateProject(baseProject());
      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isFalse);
    });

    test('detecta datos inválidos', () {
      final base = baseProject();
      expect(hasError(base.copyWith(metalPrice: 0), 'precio'), isTrue);
      expect(hasError(base.copyWith(metalPrice: -1), 'precio'), isTrue);
      expect(hasError(base.copyWith(recoveryPct: 120), 'recuperación'), isTrue);
      expect(hasError(base.copyWith(recoveryPct: -5), 'recuperación'), isTrue);
      expect(hasError(base.copyWith(averageGrade: -1), 'ley'), isTrue);
      expect(hasError(base.copyWith(averageGrade: 0), 'ley'), isTrue);
      expect(hasError(base.copyWith(reservesTonnes: -1), 'reservas'), isTrue);
      expect(hasError(base.copyWith(reservesTonnes: 0), 'reservas'), isTrue);
      expect(
        hasError(base.copyWith(annualProductionTonnes: 0), 'producción'),
        isTrue,
      );
      expect(
        hasError(base.copyWith(annualProductionTonnes: -10), 'producción'),
        isTrue,
      );
      expect(hasError(base.copyWith(lifeYears: 0), 'vida útil'), isTrue);
      expect(hasError(base.copyWith(lifeYears: 80), 'vida útil'), isTrue);
      expect(hasError(base.copyWith(discountRatePct: -5), 'Tasa'), isTrue);
      expect(hasError(base.copyWith(discountRatePct: 150), 'Tasa'), isTrue);
      expect(
        hasError(base.copyWith(operatingDaysPerYear: 400), 'días'),
        isTrue,
      );
      expect(hasError(base.copyWith(plantCapacityTpd: 0), 'capacidad'), isTrue);
      expect(hasError(base.copyWith(royaltyPct: 100), 'regalía'), isTrue);
    });

    test('detecta costos negativos', () {
      final base = baseProject();
      expect(
        hasError(
          base.copyWith(costs: base.costs.scaled(capexFactor: -1)),
          'CAPEX',
        ),
        isTrue,
      );
      expect(
        hasError(
          base.copyWith(costs: base.costs.scaled(opexFactor: -1)),
          'OPEX o costo negativo',
        ),
        isTrue,
      );
    });

    test('detecta la incompatibilidad con la capacidad de planta', () {
      final project = baseProject().copyWith(annualProductionTonnes: 3000000);
      expect(hasError(project, 'Incompatibilidad'), isTrue);
    });

    test('advierte incompatibilidad entre reservas, producción y vida', () {
      final longLife = validator.validateProject(
        baseProject().copyWith(lifeYears: 15),
      );
      expect(longLife.isValid, isTrue);
      expect(
        longLife.warnings.any((w) => w.contains('Incompatibilidad')),
        isTrue,
      );

      final extraReserves = validator.validateProject(
        baseProject().copyWith(reservesTonnes: 30000000),
      );
      expect(extraReserves.isValid, isTrue);
      expect(extraReserves.hasWarnings, isTrue);
    });

    test('el controlador no aplica proyectos inválidos', () {
      final controller = ProjectController();
      addTearDown(controller.dispose);
      final original = controller.project;
      final result = controller.updateProject(original.copyWith(metalPrice: 0));
      expect(result.isValid, isFalse);
      expect(controller.project, same(original));
      expect(controller.evaluation, isNotNull);

      final valid = controller.updateProject(
        original.copyWith(metalPrice: 4.5),
      );
      expect(valid.isValid, isTrue);
      expect(controller.project.metalPrice, 4.5);
      expect(controller.evaluation!.npv, greaterThan(50529702.22));
    });
  });
}
