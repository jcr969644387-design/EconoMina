import 'dart:math' as math;

import '../models/cutoff_models.dart';
import '../models/project_data.dart';

/// Modelo educativo y configurable de ley de corte.
///
/// Ley de corte = C / (Pn × R × F), donde:
/// - C: costos considerados por tonelada (dependen del método).
/// - Pn: precio neto = (P − costo de venta) × pagable × (1 − regalía).
/// - R: recuperación metalúrgica (fracción).
/// - F: factor de conversión de unidades.
///
/// Es una simplificación: una ley de corte profesional considera además
/// restricciones de capacidad, costos incrementales, planificación, dilución,
/// pérdidas, impuestos y el valor del dinero en el tiempo.
class CutoffGradeCalculator {
  const CutoffGradeCalculator();

  static const List<double> defaultChanges = [-20, -10, 0, 10, 20];

  CutoffResult calculate(CutoffInput input) {
    if (input.metalPrice <= 0) {
      throw ArgumentError('El precio del metal debe ser mayor que cero.');
    }
    if (input.recoveryPct <= 0 || input.recoveryPct > 100) {
      throw ArgumentError(
        'La recuperación debe ser mayor que 0 % y no superar 100 %.',
      );
    }
    if (input.payablePct <= 0 || input.payablePct > 100) {
      throw ArgumentError(
        'El contenido pagable debe ser mayor que 0 % y no superar 100 %.',
      );
    }
    if (input.royaltyPct < 0 || input.royaltyPct >= 100) {
      throw ArgumentError('La regalía debe estar entre 0 % y menos de 100 %.');
    }
    if (input.conversionFactor <= 0) {
      throw ArgumentError('El factor de conversión debe ser mayor que cero.');
    }
    final costs = [
      input.miningCost,
      input.processingCost,
      input.generalCost,
      input.sellingCost,
    ];
    if (costs.any((value) => value < 0)) {
      throw ArgumentError('Los costos no pueden ser negativos.');
    }

    final costPerTonne = input.method == CutoffMethod.equilibrio
        ? input.miningCost + input.processingCost + input.generalCost
        : input.processingCost + input.generalCost;
    final netPrice =
        (input.metalPrice - input.sellingCost) *
        (input.payablePct / 100) *
        (1 - input.royaltyPct / 100);
    final valuePerGradeUnit =
        netPrice * (input.recoveryPct / 100) * input.conversionFactor;
    if (valuePerGradeUnit <= 0) {
      throw ArgumentError(
        'No se puede dividir entre cero: el precio neto debe ser mayor que '
        'los costos de venta.',
      );
    }
    return CutoffResult(
      cutoffGrade: costPerTonne / valuePerGradeUnit,
      costPerTonne: costPerTonne,
      netPricePerUnit: netPrice,
      valuePerGradeUnit: valuePerGradeUnit,
    );
  }

  /// Construye los datos de ley de corte a partir del proyecto.
  ///
  /// Costo de mina = perforación + voladura + carguío + extracción.
  /// Costo general = mantenimiento + otros variables + fijos / producción.
  CutoffInput fromProject(
    ProjectData project, {
    CutoffMethod method = CutoffMethod.equilibrio,
  }) {
    final costs = project.costs;
    final production = project.annualProductionTonnes;
    final fixedPerTonne = production > 0
        ? costs.annualFixedCost / production
        : 0.0;
    return CutoffInput(
      metalPrice: project.metalPrice,
      recoveryPct: project.recoveryPct,
      miningCost: costs.miningUnitCost,
      processingCost: costs.processingCost,
      generalCost:
          costs.maintenanceCost + costs.otherVariableCost + fixedPerTonne,
      royaltyPct: project.royaltyPct,
      sellingCost: 0,
      payablePct: 100,
      conversionFactor: project.mineralType.conversionFactor,
      gradeUnit: project.mineralType.gradeUnitLabel,
      metalUnit: project.mineralType.metalUnit,
      method: method,
    );
  }

  /// Sensibilidad de la ley de corte ante cambios de precio, recuperación y
  /// costos. Los valores no calculables se devuelven como NaN.
  List<CutoffSensitivityRow> sensitivity(
    CutoffInput input, {
    List<double> changes = defaultChanges,
  }) {
    return [
      for (final change in changes)
        CutoffSensitivityRow(
          changePct: change,
          byPrice: _safe(
            input.copyWith(metalPrice: input.metalPrice * (1 + change / 100)),
          ),
          byRecovery: _safe(
            input.copyWith(
              recoveryPct: math.min(
                100.0,
                input.recoveryPct * (1 + change / 100),
              ),
            ),
          ),
          byCost: _safe(
            input.copyWith(
              miningCost: input.miningCost * (1 + change / 100),
              processingCost: input.processingCost * (1 + change / 100),
              generalCost: input.generalCost * (1 + change / 100),
            ),
          ),
        ),
    ];
  }

  double _safe(CutoffInput input) {
    try {
      return calculate(input).cutoffGrade;
    } on ArgumentError {
      return double.nan;
    }
  }
}
