import 'tutor_models.dart';

/// Contenido educativo de un tema del tutor.
class TutorEntry {
  const TutorEntry({
    required this.topic,
    required this.keywords,
    required this.explanation,
    required this.keyPoints,
    this.formula,
  });

  final TutorTopic topic;

  /// Palabras o frases clave normalizadas (minúsculas y sin tildes).
  final List<String> keywords;
  final String explanation;
  final List<String> keyPoints;
  final String? formula;
}

/// Base de conocimiento del tutor económico local.
const List<TutorEntry> tutorKnowledgeBase = [
  TutorEntry(
    topic: TutorTopic.capexOpex,
    keywords: [
      'capex',
      'opex',
      'inversion',
      'inversion inicial',
      'costo de capital',
      'costo operativo',
      'costos operativos',
    ],
    explanation:
        'El CAPEX es la inversión en activos de larga duración: equipos, '
        'planta, infraestructura y desarrollo de la mina. Se concentra antes '
        'de producir (periodo 0). El OPEX son los costos recurrentes para '
        'operar cada año: perforación, voladura, carguío, procesamiento, '
        'mantenimiento y administración.',
    keyPoints: [
      'El CAPEX se recupera con los flujos futuros; por eso pesa mucho en el '
          'VAN.',
      'El OPEX se expresa por tonelada (costo unitario) o por año.',
      'Reducir OPEX mejora el margen de todos los años de operación.',
    ],
    formula: 'I0 = CAPEX + desarrollo;  OPEX = costo variable × t + fijos',
  ),
  TutorEntry(
    topic: TutorTopic.precio,
    keywords: ['precio', 'cotizacion', 'mercado', 'valor del metal'],
    explanation:
        'El precio del mineral multiplica directamente al metal recuperado. '
        'Como los costos no cambian con el precio, una variación pequeña del '
        'precio produce una variación mayor del margen y del VAN. Además, un '
        'precio más alto reduce la ley de corte.',
    keyPoints: [
      'Ingreso bruto = metal recuperado × precio.',
      'Los proyectos de margen estrecho son muy sensibles al precio.',
      'Usa precios conservadores de largo plazo para evaluar proyectos.',
    ],
    formula: 'Ingreso = metal recuperado × precio',
  ),
  TutorEntry(
    topic: TutorTopic.recuperacion,
    keywords: [
      'recuperacion',
      'recuperacion metalurgica',
      'metalurgica',
      'planta concentradora',
    ],
    explanation:
        'La recuperación metalúrgica es el porcentaje del metal contenido que '
        'la planta logra capturar en el producto vendible. Una recuperación '
        'menor reduce el metal vendido sin reducir los costos, por lo que '
        'baja los ingresos y sube la ley de corte.',
    keyPoints: [
      'Metal recuperado = metal contenido × recuperación.',
      'Depende de la mineralogía y del proceso.',
      'Debe confirmarse con pruebas metalúrgicas.',
    ],
    formula: 'Metal recuperado = metal contenido × R / 100',
  ),
  TutorEntry(
    topic: TutorTopic.leyMetal,
    keywords: [
      'ley',
      'ley promedio',
      'metal contenido',
      'contenido metalico',
      'tonelaje',
    ],
    explanation:
        'La ley indica cuánto metal hay en cada tonelada de mineral. El metal '
        'contenido es el producto de las toneladas por la ley y por un factor '
        'de conversión de unidades (22.0462 lb por tonelada y por 1 %, o '
        '1/31.1035 oz por tonelada y por 1 g/t).',
    keyPoints: [
      'A mayor ley, más metal por tonelada procesada.',
      'La dilución reduce la ley real enviada a planta.',
      'Leyes altas permiten tolerar costos unitarios más altos.',
    ],
    formula: 'Metal contenido = t × ley × F',
  ),
  TutorEntry(
    topic: TutorTopic.leyCorte,
    keywords: [
      'ley de corte',
      'ley corte',
      'cut off',
      'cutoff',
      'corte',
      'break even',
    ],
    explanation:
        'La ley de corte es la ley mínima para que una tonelada pague sus '
        'costos. En el modelo de equilibrio se incluyen costos de mina, '
        'procesamiento y generales; en el marginal se excluye el costo de '
        'mina porque el material ya fue extraído. Es un modelo simplificado: '
        'en la práctica también influyen la capacidad, la dilución, los '
        'impuestos y la planificación.',
    keyPoints: [
      'Material con ley mayor que la de corte se considera mineral.',
      'Sube si aumentan los costos o bajan el precio o la recuperación.',
      'No existe una fórmula única válida para todos los casos.',
    ],
    formula: 'Ley de corte = C / (Pn × R × F)',
  ),
  TutorEntry(
    topic: TutorTopic.van,
    keywords: ['van', 'valor actual neto', 'valor presente neto', 'vpn', 'npv'],
    explanation:
        'El VAN suma los flujos de caja descontados a la tasa exigida y resta '
        'la inversión inicial. Si es positivo, el proyecto genera valor '
        'adicional a esa tasa; si es cero, solo la iguala; si es negativo, no '
        'alcanza a remunerarla. Siempre se interpreta bajo los supuestos '
        'ingresados.',
    keyPoints: [
      'VAN > 0: escenario atractivo bajo los supuestos.',
      'VAN = 0: escenario indiferente.',
      'VAN < 0: escenario no atractivo bajo los supuestos.',
    ],
    formula: 'VAN = Σ FCt / (1 + r)^t − I0',
  ),
  TutorEntry(
    topic: TutorTopic.tir,
    keywords: ['tir', 'tasa interna', 'tasa interna de retorno', 'irr'],
    explanation:
        'La TIR es la tasa de descuento que hace que el VAN sea cero. Se '
        'compara con la tasa exigida: si la TIR es mayor, el proyecto rinde '
        'más que el costo de oportunidad. Si el flujo no cambia de signo, la '
        'TIR no existe; si cambia de signo varias veces, puede haber varias '
        'TIR.',
    keyPoints: [
      'TIR > tasa de descuento: escenario atractivo.',
      'TIR = tasa: escenario indiferente.',
      'TIR < tasa: escenario menos atractivo.',
    ],
    formula: 'Σ FCt / (1 + TIR)^t − I0 = 0',
  ),
  TutorEntry(
    topic: TutorTopic.vanVsTir,
    keywords: [
      'diferencia entre van y tir',
      'van y tir',
      'van vs tir',
      'van o tir',
      'tir y van',
    ],
    explanation:
        'El VAN mide cuánto valor (en dinero) genera el proyecto a una tasa '
        'dada. La TIR mide la rentabilidad porcentual implícita. El VAN '
        'depende de la tasa elegida; la TIR no. Para comparar proyectos de '
        'distinto tamaño, el VAN suele ser más confiable.',
    keyPoints: [
      'VAN: resultado en moneda; TIR: resultado en porcentaje.',
      'Con flujos convencionales, ambos indicadores coinciden en la '
          'decisión.',
      'Con varios cambios de signo, la TIR puede ser ambigua.',
    ],
  ),
  TutorEntry(
    topic: TutorTopic.tasaDescuento,
    keywords: [
      'tasa de descuento',
      'descuento',
      'wacc',
      'costo de oportunidad',
      'tasa exigida',
    ],
    explanation:
        'La tasa de descuento representa el rendimiento mínimo exigido por '
        'el inversionista, considerando el costo de oportunidad y el riesgo. '
        'Al aumentarla, los flujos futuros valen menos hoy y el VAN baja. El '
        'efecto es mayor en proyectos de larga vida.',
    keyPoints: [
      'Mayor tasa: menor VAN.',
      'Los flujos lejanos se reducen más.',
      'Proyectos más riesgosos suelen exigir tasas más altas.',
    ],
    formula: 'Factor de descuento = 1 / (1 + r)^t',
  ),
  TutorEntry(
    topic: TutorTopic.costosProduccion,
    keywords: [
      'costo',
      'costos',
      'produccion',
      'capacidad',
      'escala',
      'costo unitario',
      'margen',
    ],
    explanation:
        'Los costos fijos se reparten entre más toneladas cuando la '
        'producción aumenta, por lo que el costo unitario baja (economías de '
        'escala). Sin embargo, producir más agota antes las reservas y puede '
        'requerir más inversión. El margen operativo es la diferencia entre '
        'el ingreso neto y el OPEX.',
    keyPoints: [
      'Costo unitario = OPEX anual / toneladas.',
      'La producción está limitada por la capacidad de planta.',
      'Vida por reservas = reservas / producción anual.',
    ],
    formula: 'Margen = ingreso neto − OPEX',
  ),
  TutorEntry(
    topic: TutorTopic.sensibilidad,
    keywords: [
      'sensibilidad',
      'escenario',
      'escenarios',
      'riesgo',
      'pesimista',
      'optimista',
      'incertidumbre',
    ],
    explanation:
        'El análisis de sensibilidad cambia una variable a la vez (precio, '
        'ley, recuperación, producción, CAPEX, OPEX, tasa o ley de corte) y '
        'observa su efecto en el VAN y la TIR. Permite identificar las '
        'variables críticas y preparar medidas de mitigación.',
    keyPoints: [
      'Las variables con mayor rango de VAN son las más críticas.',
      'Un proyecto robusto mantiene VAN positivo en el escenario pesimista.',
      'La sensibilidad no reemplaza un análisis probabilístico de riesgo.',
    ],
  ),
];
