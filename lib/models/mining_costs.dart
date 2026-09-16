/// Costos del proyecto minero.
///
/// - Inversión (CAPEX y desarrollo) y cierre: montos totales en la moneda.
/// - Costos unitarios variables: moneda por tonelada tratada.
/// - Costos fijos: moneda por año.
class MiningCosts {
  const MiningCosts({
    required this.capex,
    required this.developmentCost,
    required this.drillingCost,
    required this.blastingCost,
    required this.loadHaulCost,
    required this.extractionCost,
    required this.processingCost,
    required this.maintenanceCost,
    required this.otherVariableCost,
    required this.administrativeCost,
    required this.otherFixedCost,
    required this.closureCost,
  });

  /// Inversión inicial en infraestructura, equipos y planta.
  final double capex;

  /// Costos de desarrollo o preproducción (se suman a la inversión inicial).
  final double developmentCost;

  /// Perforación (moneda/t).
  final double drillingCost;

  /// Voladura (moneda/t).
  final double blastingCost;

  /// Carguío y transporte (moneda/t).
  final double loadHaulCost;

  /// Otros costos de extracción en mina (moneda/t).
  final double extractionCost;

  /// Procesamiento o tratamiento en planta (moneda/t).
  final double processingCost;

  /// Mantenimiento (moneda/t).
  final double maintenanceCost;

  /// Otros costos variables (moneda/t).
  final double otherVariableCost;

  /// Costos administrativos (moneda/año).
  final double administrativeCost;

  /// Otros costos fijos (moneda/año).
  final double otherFixedCost;

  /// Costo de cierre de mina (monto total al final de la operación).
  final double closureCost;

  /// Inversión inicial I0 = CAPEX + desarrollo.
  double get initialInvestment => capex + developmentCost;

  /// Costo de mina por tonelada: perforación + voladura + carguío + extracción.
  double get miningUnitCost =>
      drillingCost + blastingCost + loadHaulCost + extractionCost;

  /// Suma de todos los costos variables por tonelada.
  double get variableUnitCost =>
      miningUnitCost + processingCost + maintenanceCost + otherVariableCost;

  /// Suma de los costos fijos anuales.
  double get annualFixedCost => administrativeCost + otherFixedCost;

  /// Lista de montos que no pueden ser negativos, con su nombre.
  Map<String, double> get namedValues => {
    'CAPEX': capex,
    'Costos de desarrollo': developmentCost,
    'Perforación': drillingCost,
    'Voladura': blastingCost,
    'Carguío y transporte': loadHaulCost,
    'Extracción (otros costos mina)': extractionCost,
    'Procesamiento': processingCost,
    'Mantenimiento': maintenanceCost,
    'Otros costos variables': otherVariableCost,
    'Costos administrativos': administrativeCost,
    'Otros costos fijos': otherFixedCost,
    'Costos de cierre': closureCost,
  };

  /// Devuelve una copia con la inversión y el OPEX escalados.
  MiningCosts scaled({double capexFactor = 1, double opexFactor = 1}) {
    return MiningCosts(
      capex: capex * capexFactor,
      developmentCost: developmentCost * capexFactor,
      drillingCost: drillingCost * opexFactor,
      blastingCost: blastingCost * opexFactor,
      loadHaulCost: loadHaulCost * opexFactor,
      extractionCost: extractionCost * opexFactor,
      processingCost: processingCost * opexFactor,
      maintenanceCost: maintenanceCost * opexFactor,
      otherVariableCost: otherVariableCost * opexFactor,
      administrativeCost: administrativeCost * opexFactor,
      otherFixedCost: otherFixedCost * opexFactor,
      closureCost: closureCost,
    );
  }

  /// Representación serializable (para guardar el proyecto localmente).
  Map<String, double> toJson() => {
    'capex': capex,
    'developmentCost': developmentCost,
    'drillingCost': drillingCost,
    'blastingCost': blastingCost,
    'loadHaulCost': loadHaulCost,
    'extractionCost': extractionCost,
    'processingCost': processingCost,
    'maintenanceCost': maintenanceCost,
    'otherVariableCost': otherVariableCost,
    'administrativeCost': administrativeCost,
    'otherFixedCost': otherFixedCost,
    'closureCost': closureCost,
  };

  /// Reconstruye los costos; devuelve nulo si falta algún dato o no es
  /// numérico.
  static MiningCosts? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    double? read(String key) {
      final value = json[key];
      return value is num ? value.toDouble() : null;
    }

    final values = [for (final key in _jsonKeys) read(key)];
    if (values.any((value) => value == null)) {
      return null;
    }
    return MiningCosts(
      capex: values[0]!,
      developmentCost: values[1]!,
      drillingCost: values[2]!,
      blastingCost: values[3]!,
      loadHaulCost: values[4]!,
      extractionCost: values[5]!,
      processingCost: values[6]!,
      maintenanceCost: values[7]!,
      otherVariableCost: values[8]!,
      administrativeCost: values[9]!,
      otherFixedCost: values[10]!,
      closureCost: values[11]!,
    );
  }

  static const List<String> _jsonKeys = [
    'capex',
    'developmentCost',
    'drillingCost',
    'blastingCost',
    'loadHaulCost',
    'extractionCost',
    'processingCost',
    'maintenanceCost',
    'otherVariableCost',
    'administrativeCost',
    'otherFixedCost',
    'closureCost',
  ];
}
