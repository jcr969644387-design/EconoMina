/// Escenarios económicos predefinidos.
///
/// Cada escenario multiplica precio, ley, recuperación, OPEX y CAPEX por un
/// factor. La producción, las reservas y la vida útil no cambian.
enum ScenarioType {
  pesimista(
    label: 'Pesimista',
    priceFactor: 0.90,
    gradeFactor: 0.95,
    recoveryFactor: 0.98,
    opexFactor: 1.10,
    capexFactor: 1.10,
  ),
  base(
    label: 'Base',
    priceFactor: 1,
    gradeFactor: 1,
    recoveryFactor: 1,
    opexFactor: 1,
    capexFactor: 1,
  ),
  optimista(
    label: 'Optimista',
    priceFactor: 1.10,
    gradeFactor: 1.05,
    recoveryFactor: 1.01,
    opexFactor: 0.95,
    capexFactor: 0.95,
  );

  const ScenarioType({
    required this.label,
    required this.priceFactor,
    required this.gradeFactor,
    required this.recoveryFactor,
    required this.opexFactor,
    required this.capexFactor,
  });

  final String label;
  final double priceFactor;
  final double gradeFactor;
  final double recoveryFactor;
  final double opexFactor;
  final double capexFactor;

  String get description {
    String pct(double factor) {
      final change = (factor - 1) * 100;
      if (change.abs() < 1e-9) {
        return 'sin cambio';
      }
      final sign = change > 0 ? '+' : '';
      return '$sign${change.toStringAsFixed(0)} %';
    }

    return 'Precio ${pct(priceFactor)}, ley ${pct(gradeFactor)}, '
        'recuperación ${pct(recoveryFactor)}, OPEX ${pct(opexFactor)}, '
        'CAPEX ${pct(capexFactor)}.';
  }
}
