import '../models/cutoff_models.dart';
import '../models/project_data.dart';
import '../models/validation_result.dart';
import '../utils/formatters.dart';

/// Validaciones de negocio del simulador.
class ValidationService {
  const ValidationService();

  static const int maxLifeYears = 60;

  ValidationResult validateProject(ProjectData project) {
    final errors = <String>[];
    final warnings = <String>[];

    if (project.name.trim().isEmpty) {
      errors.add('Dato incompleto: ingresa el nombre del proyecto.');
    }
    if (project.currency.trim().isEmpty) {
      errors.add('Dato incompleto: selecciona la moneda de análisis.');
    }

    final values = <double>[
      project.discountRatePct,
      project.metalPrice,
      project.reservesTonnes,
      project.averageGrade,
      project.recoveryPct,
      project.annualProductionTonnes,
      project.plantCapacityTpd,
      project.royaltyPct,
      project.taxRatePct,
      ...project.costs.namedValues.values,
    ];
    if (values.any((value) => value.isNaN || value.isInfinite)) {
      errors.add('Datos incompletos: hay valores numéricos no válidos.');
      return ValidationResult(errors: errors, warnings: warnings);
    }

    if (project.metalPrice <= 0) {
      errors.add('El precio del mineral debe ser mayor que cero.');
    }
    if (project.recoveryPct < 0 || project.recoveryPct > 100) {
      errors.add('La recuperación debe estar entre 0 % y 100 %.');
    } else if (project.recoveryPct == 0) {
      errors.add(
        'La recuperación no puede ser 0 %: no se recuperaría metal y habría '
        'divisiones entre cero.',
      );
    }
    if (project.averageGrade < 0) {
      errors.add('La ley no puede ser negativa.');
    } else if (project.averageGrade == 0) {
      errors.add('La ley debe ser mayor que cero.');
    } else if (project.averageGrade > project.mineralType.maxGrade) {
      errors.add(
        'La ley supera el máximo permitido '
        '(${Formatters.plain(project.mineralType.maxGrade)} '
        '${project.mineralType.gradeUnitLabel}).',
      );
    }
    if (project.reservesTonnes < 0) {
      errors.add('Las reservas no pueden ser negativas.');
    } else if (project.reservesTonnes == 0) {
      errors.add('Las reservas deben ser mayores que cero.');
    }
    if (project.annualProductionTonnes < 0) {
      errors.add('La producción no puede ser negativa.');
    } else if (project.annualProductionTonnes == 0) {
      errors.add(
        'La producción anual debe ser mayor que cero (evita divisiones entre '
        'cero en costos unitarios).',
      );
    }
    if (project.lifeYears <= 0) {
      errors.add('La vida útil debe ser mayor que cero.');
    } else if (project.lifeYears > maxLifeYears) {
      errors.add(
        'La vida útil no debe superar $maxLifeYears años en este simulador.',
      );
    }
    if (project.discountRatePct < 0 || project.discountRatePct > 100) {
      errors.add('Tasa de descuento inválida: debe estar entre 0 % y 100 %.');
    } else if (project.discountRatePct > 30) {
      warnings.add(
        'La tasa de descuento es muy alta (mayor que 30 %). Verifica el dato.',
      );
    } else if (project.discountRatePct == 0) {
      warnings.add(
        'Con tasa de descuento 0 % el VAN equivale a la suma simple de los '
        'flujos.',
      );
    }
    if (project.operatingDaysPerYear <= 0 ||
        project.operatingDaysPerYear > 366) {
      errors.add('Los días de operación deben estar entre 1 y 366.');
    }
    if (project.plantCapacityTpd <= 0) {
      errors.add('La capacidad de planta debe ser mayor que cero.');
    }
    if (project.royaltyPct < 0 || project.royaltyPct >= 100) {
      errors.add('La regalía debe estar entre 0 % y menos de 100 %.');
    }
    if (project.taxRatePct < 0 || project.taxRatePct >= 100) {
      errors.add('La tasa de impuesto debe estar entre 0 % y menos de 100 %.');
    }

    final costs = project.costs.namedValues;
    for (final entry in costs.entries) {
      if (entry.value < 0) {
        final label = entry.key;
        if (label == 'CAPEX') {
          errors.add('El CAPEX no puede ser negativo.');
        } else {
          errors.add('OPEX o costo negativo: "$label" no puede ser negativo.');
        }
      }
    }

    if (errors.isEmpty) {
      _checkCapacityAndReserves(project, errors, warnings);
    }
    return ValidationResult(errors: errors, warnings: warnings);
  }

  void _checkCapacityAndReserves(
    ProjectData project,
    List<String> errors,
    List<String> warnings,
  ) {
    final capacity = project.plantAnnualCapacity;
    if (project.annualProductionTonnes > capacity * 1.0001) {
      errors.add(
        'Incompatibilidad: la producción anual '
        '(${Formatters.number(project.annualProductionTonnes, decimals: 0)} t) '
        'supera la capacidad anual de planta '
        '(${Formatters.number(capacity, decimals: 0)} t = t/día × días).',
      );
    }
    final reserveYears = project.reserveLifeYears;
    if (reserveYears < 1) {
      warnings.add(
        'Las reservas no alcanzan para un año completo de producción.',
      );
    }
    final fullYears = (reserveYears - 1e-9).ceil();
    if (project.lifeYears > fullYears) {
      warnings.add(
        'Incompatibilidad entre reservas, producción y vida útil: las '
        'reservas duran ${Formatters.number(reserveYears, decimals: 1)} años, '
        'pero la vida útil es ${project.lifeYears} años. El flujo se limitará '
        'a $fullYears años.',
      );
    } else if (reserveYears > project.lifeYears + 1e-9) {
      final unused =
          project.reservesTonnes -
          project.annualProductionTonnes * project.lifeYears;
      warnings.add(
        'Incompatibilidad entre reservas, producción y vida útil: con la vida '
        'útil ingresada quedarían '
        '${Formatters.number(unused / 1e6, decimals: 2)} Mt de reservas sin '
        'explotar.',
      );
    }
  }

  ValidationResult validateCutoff(CutoffInput input) {
    final errors = <String>[];
    if (input.metalPrice <= 0) {
      errors.add('El precio del metal debe ser mayor que cero.');
    }
    if (input.recoveryPct <= 0 || input.recoveryPct > 100) {
      errors.add('La recuperación debe ser mayor que 0 % y hasta 100 %.');
    }
    if (input.payablePct <= 0 || input.payablePct > 100) {
      errors.add('El contenido pagable debe ser mayor que 0 % y hasta 100 %.');
    }
    if (input.royaltyPct < 0 || input.royaltyPct >= 100) {
      errors.add('La regalía debe estar entre 0 % y menos de 100 %.');
    }
    if (input.conversionFactor <= 0) {
      errors.add('El factor de conversión debe ser mayor que cero.');
    }
    final negative = [
      input.miningCost,
      input.processingCost,
      input.generalCost,
      input.sellingCost,
    ].any((value) => value < 0);
    if (negative) {
      errors.add('Los costos no pueden ser negativos.');
    }
    if (input.sellingCost >= input.metalPrice && input.metalPrice > 0) {
      errors.add(
        'El costo de venta no puede ser igual o mayor que el precio del metal.',
      );
    }
    return ValidationResult(errors: errors);
  }
}
