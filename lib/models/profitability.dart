/// Clasificación educativa de rentabilidad bajo los supuestos ingresados.
enum Profitability {
  atractivo('Atractivo'),
  indiferente('Indiferente'),
  noAtractivo('No atractivo');

  const Profitability(this.label);

  final String label;
}

/// Nivel de riesgo económico educativo.
enum RiskLevel {
  bajo('Riesgo bajo'),
  medio('Riesgo medio'),
  alto('Riesgo alto');

  const RiskLevel(this.label);

  final String label;
}
