/// Unidad en la que se expresa la ley del mineral.
enum GradeUnit {
  percent('%'),
  gramsPerTonne('g/t');

  const GradeUnit(this.label);

  final String label;
}

/// Tipos de mineral disponibles en el simulador.
///
/// El factor de conversión transforma "toneladas × ley" en unidades de metal:
/// - Ley en %: 1 % de 1 t = 10 kg = 22.0462 lb.
/// - Ley en g/t: 1 g = 1 / 31.1035 onzas troy.
///
/// Los precios y leyes de referencia son valores educativos, no cotizaciones
/// de mercado vigentes.
enum MineralType {
  cobre(
    label: 'Cobre (Cu)',
    gradeUnit: GradeUnit.percent,
    metalUnit: 'lb',
    conversionFactor: 22.0462,
    referencePrice: 4.0,
    referenceGrade: 0.8,
  ),
  zinc(
    label: 'Zinc (Zn)',
    gradeUnit: GradeUnit.percent,
    metalUnit: 'lb',
    conversionFactor: 22.0462,
    referencePrice: 1.2,
    referenceGrade: 6.0,
  ),
  plomo(
    label: 'Plomo (Pb)',
    gradeUnit: GradeUnit.percent,
    metalUnit: 'lb',
    conversionFactor: 22.0462,
    referencePrice: 0.95,
    referenceGrade: 4.0,
  ),
  oro(
    label: 'Oro (Au)',
    gradeUnit: GradeUnit.gramsPerTonne,
    metalUnit: 'oz',
    conversionFactor: 1 / 31.1035,
    referencePrice: 2000,
    referenceGrade: 1.5,
  ),
  plata(
    label: 'Plata (Ag)',
    gradeUnit: GradeUnit.gramsPerTonne,
    metalUnit: 'oz',
    conversionFactor: 1 / 31.1035,
    referencePrice: 25,
    referenceGrade: 120,
  );

  const MineralType({
    required this.label,
    required this.gradeUnit,
    required this.metalUnit,
    required this.conversionFactor,
    required this.referencePrice,
    required this.referenceGrade,
  });

  final String label;
  final GradeUnit gradeUnit;
  final String metalUnit;
  final double conversionFactor;
  final double referencePrice;
  final double referenceGrade;

  String get gradeUnitLabel => gradeUnit.label;

  /// Ley máxima físicamente razonable para validar datos.
  double get maxGrade => gradeUnit == GradeUnit.percent ? 100 : 100000;

  String priceUnitLabel(String currency) => '$currency/$metalUnit';

  String get conversionExplanation => gradeUnit == GradeUnit.percent
      ? '1 % de 1 t equivale a 10 kg = 22.0462 lb'
      : '1 g equivale a 1 / 31.1035 onzas troy';
}
