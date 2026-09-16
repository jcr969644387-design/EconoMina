import '../models/mining_costs.dart';

/// Elemento de la distribución porcentual de costos operativos.
class CostBreakdownItem {
  const CostBreakdownItem({
    required this.label,
    required this.annualAmount,
    required this.percent,
    required this.isFixed,
  });

  final String label;
  final double annualAmount;
  final double percent;
  final bool isFixed;
}

/// Cálculos educativos de costos mineros.
class CostCalculator {
  const CostCalculator();

  /// Costo variable anual = costo variable unitario × toneladas.
  double annualVariableCost(MiningCosts costs, double tonnes) {
    _checkNonNegative(tonnes, 'Las toneladas');
    return costs.variableUnitCost * tonnes;
  }

  /// OPEX anual = costo variable anual + costos fijos anuales.
  double annualOperatingCost(MiningCosts costs, double tonnes) {
    return annualVariableCost(costs, tonnes) + costs.annualFixedCost;
  }

  /// Costo total anual equivalente (sin descontar) =
  /// OPEX anual + (inversión inicial + cierre) / años.
  double totalAnnualCost(MiningCosts costs, double tonnes, int years) {
    if (years <= 0) {
      throw ArgumentError('La vida útil debe ser mayor que cero.');
    }
    final capital = costs.initialInvestment + costs.closureCost;
    return annualOperatingCost(costs, tonnes) + capital / years;
  }

  /// Costo unitario = OPEX anual / toneladas procesadas.
  double unitCost(MiningCosts costs, double tonnes) {
    if (tonnes <= 0) {
      throw ArgumentError(
        'No se puede dividir entre cero: las toneladas deben ser mayores que '
        'cero.',
      );
    }
    return annualOperatingCost(costs, tonnes) / tonnes;
  }

  /// Costo por unidad de metal = OPEX anual / metal recuperado anual.
  double costPerMetalUnit(
    MiningCosts costs,
    double tonnes,
    double recoveredMetal,
  ) {
    if (recoveredMetal <= 0) {
      throw ArgumentError(
        'No se puede dividir entre cero: el metal recuperado debe ser mayor '
        'que cero.',
      );
    }
    return annualOperatingCost(costs, tonnes) / recoveredMetal;
  }

  /// Costo operativo total = OPEX anual × años de operación.
  double totalOperatingCost(MiningCosts costs, double tonnes, int years) {
    if (years < 0) {
      throw ArgumentError('Los años de operación no pueden ser negativos.');
    }
    return annualOperatingCost(costs, tonnes) * years;
  }

  /// Distribución porcentual del OPEX anual por partida.
  List<CostBreakdownItem> distribution(MiningCosts costs, double tonnes) {
    final entries = <(String, double, bool)>[
      ('Perforación', costs.drillingCost * tonnes, false),
      ('Voladura', costs.blastingCost * tonnes, false),
      ('Carguío y transporte', costs.loadHaulCost * tonnes, false),
      ('Extracción (otros mina)', costs.extractionCost * tonnes, false),
      ('Procesamiento', costs.processingCost * tonnes, false),
      ('Mantenimiento', costs.maintenanceCost * tonnes, false),
      ('Otros variables', costs.otherVariableCost * tonnes, false),
      ('Administrativos', costs.administrativeCost, true),
      ('Otros fijos', costs.otherFixedCost, true),
    ];
    final total = annualOperatingCost(costs, tonnes);
    return [
      for (final entry in entries)
        CostBreakdownItem(
          label: entry.$1,
          annualAmount: entry.$2,
          percent: total > 0 ? entry.$2 / total * 100 : 0,
          isFixed: entry.$3,
        ),
    ];
  }

  void _checkNonNegative(double value, String name) {
    if (value < 0) {
      throw ArgumentError('$name no pueden ser negativas.');
    }
  }
}
