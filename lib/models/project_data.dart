import 'mineral_type.dart';
import 'mining_costs.dart';

/// Datos generales de un proyecto minero educativo.
///
/// Unidades base: toneladas (t), años, porcentajes expresados de 0 a 100 y
/// montos en la moneda de análisis.
class ProjectData {
  const ProjectData({
    required this.name,
    required this.currency,
    required this.lifeYears,
    required this.discountRatePct,
    required this.metalPrice,
    required this.mineralType,
    required this.reservesTonnes,
    required this.averageGrade,
    required this.recoveryPct,
    required this.annualProductionTonnes,
    required this.plantCapacityTpd,
    required this.operatingDaysPerYear,
    required this.royaltyPct,
    required this.taxEnabled,
    required this.taxRatePct,
    required this.costs,
  });

  /// Proyecto base ficticio que se carga al iniciar la aplicación.
  factory ProjectData.defaultProject() {
    return const ProjectData(
      name: 'Proyecto Andino Cu (ficticio)',
      currency: 'USD',
      lifeYears: 10,
      discountRatePct: 10,
      metalPrice: 4.0,
      mineralType: MineralType.cobre,
      reservesTonnes: 20000000,
      averageGrade: 0.8,
      recoveryPct: 88,
      annualProductionTonnes: 2000000,
      plantCapacityTpd: 6000,
      operatingDaysPerYear: 350,
      royaltyPct: 3,
      taxEnabled: false,
      taxRatePct: 29.5,
      costs: MiningCosts(
        capex: 300000000,
        developmentCost: 40000000,
        drillingCost: 1.2,
        blastingCost: 1.0,
        loadHaulCost: 3.0,
        extractionCost: 1.8,
        processingCost: 9.0,
        maintenanceCost: 2.0,
        otherVariableCost: 0.5,
        administrativeCost: 12000000,
        otherFixedCost: 6000000,
        closureCost: 30000000,
      ),
    );
  }

  /// Periodo de evaluación del MVP.
  static const String evaluationPeriod = 'Anual';

  static const List<String> supportedCurrencies = ['USD', 'PEN'];

  final String name;
  final String currency;
  final int lifeYears;
  final double discountRatePct;
  final double metalPrice;
  final MineralType mineralType;
  final double reservesTonnes;
  final double averageGrade;
  final double recoveryPct;
  final double annualProductionTonnes;
  final double plantCapacityTpd;
  final int operatingDaysPerYear;
  final double royaltyPct;
  final bool taxEnabled;
  final double taxRatePct;
  final MiningCosts costs;

  double get discountRate => discountRatePct / 100;

  /// Capacidad anual de planta = t/día × días de operación.
  double get plantAnnualCapacity => plantCapacityTpd * operatingDaysPerYear;

  /// Años que durarían las reservas con la producción anual ingresada.
  double get reserveLifeYears =>
      annualProductionTonnes > 0 ? reservesTonnes / annualProductionTonnes : 0;

  ProjectData copyWith({
    String? name,
    String? currency,
    int? lifeYears,
    double? discountRatePct,
    double? metalPrice,
    MineralType? mineralType,
    double? reservesTonnes,
    double? averageGrade,
    double? recoveryPct,
    double? annualProductionTonnes,
    double? plantCapacityTpd,
    int? operatingDaysPerYear,
    double? royaltyPct,
    bool? taxEnabled,
    double? taxRatePct,
    MiningCosts? costs,
  }) {
    return ProjectData(
      name: name ?? this.name,
      currency: currency ?? this.currency,
      lifeYears: lifeYears ?? this.lifeYears,
      discountRatePct: discountRatePct ?? this.discountRatePct,
      metalPrice: metalPrice ?? this.metalPrice,
      mineralType: mineralType ?? this.mineralType,
      reservesTonnes: reservesTonnes ?? this.reservesTonnes,
      averageGrade: averageGrade ?? this.averageGrade,
      recoveryPct: recoveryPct ?? this.recoveryPct,
      annualProductionTonnes:
          annualProductionTonnes ?? this.annualProductionTonnes,
      plantCapacityTpd: plantCapacityTpd ?? this.plantCapacityTpd,
      operatingDaysPerYear: operatingDaysPerYear ?? this.operatingDaysPerYear,
      royaltyPct: royaltyPct ?? this.royaltyPct,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      taxRatePct: taxRatePct ?? this.taxRatePct,
      costs: costs ?? this.costs,
    );
  }

  /// Representación serializable (para guardar el proyecto localmente).
  Map<String, Object> toJson() => {
    'name': name,
    'currency': currency,
    'lifeYears': lifeYears,
    'discountRatePct': discountRatePct,
    'metalPrice': metalPrice,
    'mineralType': mineralType.name,
    'reservesTonnes': reservesTonnes,
    'averageGrade': averageGrade,
    'recoveryPct': recoveryPct,
    'annualProductionTonnes': annualProductionTonnes,
    'plantCapacityTpd': plantCapacityTpd,
    'operatingDaysPerYear': operatingDaysPerYear,
    'royaltyPct': royaltyPct,
    'taxEnabled': taxEnabled,
    'taxRatePct': taxRatePct,
    'costs': costs.toJson(),
  };

  /// Reconstruye un proyecto guardado; devuelve nulo si los datos están
  /// incompletos o dañados.
  static ProjectData? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    double? number(String key) {
      final value = json[key];
      return value is num ? value.toDouble() : null;
    }

    final name = json['name'];
    final currency = json['currency'];
    final mineralName = json['mineralType'];
    final taxEnabled = json['taxEnabled'];
    final mineral = mineralName is String
        ? MineralType.values.asNameMap()[mineralName]
        : null;
    final costs = MiningCosts.fromJson(json['costs']);
    final lifeYears = number('lifeYears');
    final days = number('operatingDaysPerYear');
    final rate = number('discountRatePct');
    final price = number('metalPrice');
    final reserves = number('reservesTonnes');
    final grade = number('averageGrade');
    final recovery = number('recoveryPct');
    final production = number('annualProductionTonnes');
    final capacity = number('plantCapacityTpd');
    final royalty = number('royaltyPct');
    final taxRate = number('taxRatePct');
    if (name is! String ||
        currency is! String ||
        taxEnabled is! bool ||
        mineral == null ||
        costs == null ||
        lifeYears == null ||
        days == null ||
        rate == null ||
        price == null ||
        reserves == null ||
        grade == null ||
        recovery == null ||
        production == null ||
        capacity == null ||
        royalty == null ||
        taxRate == null) {
      return null;
    }
    return ProjectData(
      name: name,
      currency: currency,
      lifeYears: lifeYears.round(),
      discountRatePct: rate,
      metalPrice: price,
      mineralType: mineral,
      reservesTonnes: reserves,
      averageGrade: grade,
      recoveryPct: recovery,
      annualProductionTonnes: production,
      plantCapacityTpd: capacity,
      operatingDaysPerYear: days.round(),
      royaltyPct: royalty,
      taxEnabled: taxEnabled,
      taxRatePct: taxRate,
      costs: costs,
    );
  }
}
