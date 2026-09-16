import '../models/learning_models.dart';
import '../models/mineral_type.dart';
import '../models/mining_costs.dart';
import '../models/project_data.dart';

/// Casos empresariales educativos. Todos los proyectos son ficticios.
class CaseRepository {
  const CaseRepository();

  List<CaseStudy> all() => _cases;

  CaseStudy? byId(String id) {
    for (final item in _cases) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  static const List<CaseStudy> _cases = [
    CaseStudy(
      id: 'caso-1-rentable',
      title: 'Caso 1: Mina cuprífera rentable',
      summary:
          'Proyecto de cobre a tajo abierto con VAN positivo y TIR superior a '
          'la tasa de descuento.',
      project: ProjectData(
        name: 'Mina Santa Clara Cu (ficticia)',
        currency: 'USD',
        lifeYears: 10,
        discountRatePct: 10,
        metalPrice: 4.0,
        mineralType: MineralType.cobre,
        reservesTonnes: 24000000,
        averageGrade: 0.95,
        recoveryPct: 88,
        annualProductionTonnes: 2400000,
        plantCapacityTpd: 7000,
        operatingDaysPerYear: 350,
        royaltyPct: 3,
        taxEnabled: false,
        taxRatePct: 29.5,
        costs: MiningCosts(
          capex: 320000000,
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
      ),
      assumptions: [
        'Precio del cobre constante de 4.00 USD/lb durante toda la vida.',
        'Producción constante de 2.4 Mt/año durante 10 años.',
        'Regalía de 3 % sobre el ingreso bruto; impuestos desactivados.',
        'Cierre de mina de USD 30 M en el último año.',
      ],
      questions: [
        '¿Cuál es el cobre recuperado por año?',
        '¿Cuál es el costo unitario de operación (USD/t)?',
        '¿El VAN al 10 % es positivo? ¿Qué significa?',
        '¿La TIR supera la tasa de descuento?',
      ],
      expectedCalculations: [
        'Metal contenido = 2 400 000 t × 0.95 % × 22.0462 lb/(t·%) ≈ 50.27 M lb.',
        'Metal recuperado = 50.27 M lb × 88 % ≈ 44.23 M lb/año.',
        'OPEX = 18.5 USD/t × 2.4 Mt + USD 18 M ≈ USD 62.4 M/año '
            '(≈ 26 USD/t).',
        'VAN al 10 % ≈ USD 300 M; TIR ≈ 27 %.',
      ],
      interpretation:
          'El VAN es positivo y la TIR supera ampliamente la tasa de '
          'descuento: bajo los supuestos ingresados, el escenario es '
          'económicamente atractivo e incluso resiste el escenario pesimista.',
      risks: [
        'Caída prolongada del precio del cobre.',
        'Sobrecostos de CAPEX durante la construcción.',
        'Menor ley real que la estimada (dilución).',
      ],
      educationalDecision:
          'Continuar con estudios de mayor detalle (prefactibilidad), '
          'confirmando reservas y costos.',
      explanation:
          'La combinación de buena ley, costos moderados y escala adecuada '
          'genera flujos que recuperan la inversión en pocos años. Aun así, '
          'un VAN positivo en un simulador no es una decisión de inversión.',
      expectedNpvPositive: true,
      expectedIrrAboveRate: true,
      expectedPessimisticNpvPositive: true,
    ),
    CaseStudy(
      id: 'caso-2-van-negativo',
      title: 'Caso 2: Proyecto aurífero con VAN negativo',
      summary:
          'Proyecto de oro de baja ley y costos altos que no cubre la tasa de '
          'descuento exigida.',
      project: ProjectData(
        name: 'Proyecto Qori Au (ficticio)',
        currency: 'USD',
        lifeYears: 10,
        discountRatePct: 10,
        metalPrice: 2000,
        mineralType: MineralType.oro,
        reservesTonnes: 15000000,
        averageGrade: 1.3,
        recoveryPct: 85,
        annualProductionTonnes: 1500000,
        plantCapacityTpd: 4500,
        operatingDaysPerYear: 350,
        royaltyPct: 3,
        taxEnabled: false,
        taxRatePct: 29.5,
        costs: MiningCosts(
          capex: 200000000,
          developmentCost: 20000000,
          drillingCost: 2.0,
          blastingCost: 1.8,
          loadHaulCost: 4.5,
          extractionCost: 3.2,
          processingCost: 16.0,
          maintenanceCost: 3.0,
          otherVariableCost: 1.0,
          administrativeCost: 18000000,
          otherFixedCost: 7000000,
          closureCost: 8000000,
        ),
      ),
      assumptions: [
        'Precio del oro constante de 2 000 USD/oz.',
        'Ley de 1.3 g/t y recuperación de 85 %.',
        'Tasa de descuento de 10 % exigida por el inversionista.',
      ],
      questions: [
        '¿Cuántas onzas se recuperan por año?',
        '¿Por qué el VAN es negativo si el margen operativo es positivo?',
        '¿Qué relación hay entre la TIR y la tasa de descuento?',
      ],
      expectedCalculations: [
        'Metal contenido = 1 500 000 t × 1.3 g/t ÷ 31.1035 ≈ 62.7 koz.',
        'Metal recuperado ≈ 62.7 koz × 85 % ≈ 53.3 koz/año.',
        'VAN al 10 % ≈ USD −32 M; TIR ≈ 6.5 %.',
      ],
      interpretation:
          'El VAN es negativo y la TIR es menor que la tasa de descuento: '
          'bajo los supuestos ingresados, el escenario no es atractivo. Los '
          'flujos son positivos, pero no alcanzan para remunerar la inversión '
          'al 10 %.',
      risks: [
        'Alta dependencia del precio del oro.',
        'Costos de procesamiento elevados para la ley disponible.',
        'Recuperación metalúrgica aún no confirmada con pruebas.',
      ],
      educationalDecision:
          'No avanzar con el diseño actual; buscar optimizaciones (mayor ley, '
          'menor CAPEX o mejor recuperación) antes de reevaluar.',
      explanation:
          'Un margen operativo positivo no garantiza un VAN positivo: el VAN '
          'compara los flujos descontados con la inversión inicial. Una TIR '
          'de 6.5 % frente a una exigencia de 10 % indica que el proyecto '
          'rinde menos que el costo de oportunidad.',
      expectedNpvPositive: false,
      expectedIrrAboveRate: false,
    ),
    CaseStudy(
      id: 'caso-3-alta-ley',
      title: 'Caso 3: Alta ley y bajas reservas',
      summary:
          'Veta aurífera subterránea de alta ley, pequeña escala y vida corta.',
      project: ProjectData(
        name: 'Veta Filón Alto Au (ficticia)',
        currency: 'USD',
        lifeYears: 4,
        discountRatePct: 10,
        metalPrice: 2000,
        mineralType: MineralType.oro,
        reservesTonnes: 800000,
        averageGrade: 9.0,
        recoveryPct: 93,
        annualProductionTonnes: 200000,
        plantCapacityTpd: 600,
        operatingDaysPerYear: 350,
        royaltyPct: 3,
        taxEnabled: false,
        taxRatePct: 29.5,
        costs: MiningCosts(
          capex: 70000000,
          developmentCost: 25000000,
          drillingCost: 14,
          blastingCost: 10,
          loadHaulCost: 22,
          extractionCost: 30,
          processingCost: 28,
          maintenanceCost: 8,
          otherVariableCost: 3,
          administrativeCost: 8000000,
          otherFixedCost: 4000000,
          closureCost: 6000000,
        ),
      ),
      assumptions: [
        'Minería subterránea con costo variable de 115 USD/t.',
        'Reservas de 0.8 Mt que se agotan en 4 años.',
        'Sin exploración adicional considerada.',
      ],
      questions: [
        '¿Por qué un costo de 115 USD/t puede ser rentable aquí?',
        '¿Qué ocurre con la ley de corte cuando los costos son altos?',
        '¿Cuál es el principal riesgo de un proyecto con vida corta?',
      ],
      expectedCalculations: [
        'Metal recuperado = 200 000 t × 9 g/t ÷ 31.1035 × 93 % ≈ 53.8 koz/año.',
        'Ley de corte de equilibrio ≈ 3.0 g/t (menor que la ley de 9 g/t).',
        'VAN al 10 % ≈ USD 121 M; TIR ≈ 62 %.',
      ],
      interpretation:
          'La alta ley compensa los costos subterráneos: VAN positivo y TIR '
          'muy superior a la tasa. Sin embargo, la vida de 4 años concentra '
          'el riesgo en pocos periodos.',
      risks: [
        'Reservas pequeñas: cualquier error de estimación afecta mucho.',
        'Continuidad de la veta y dilución en la explotación.',
        'Poco tiempo para recuperar la inversión si hay retrasos.',
      ],
      educationalDecision:
          'Escenario atractivo bajo los supuestos; priorizar exploración para '
          'ampliar reservas y controlar la dilución.',
      explanation:
          'Con leyes altas, cada tonelada tiene mucho valor, por lo que se '
          'toleran costos unitarios altos. La TIR elevada refleja una '
          'recuperación rápida de una inversión relativamente pequeña.',
      expectedNpvPositive: true,
      expectedIrrAboveRate: true,
      expectedPessimisticNpvPositive: true,
    ),
    CaseStudy(
      id: 'caso-4-baja-ley',
      title: 'Caso 4: Baja ley y grandes reservas',
      summary:
          'Pórfido de cobre a gran escala: baja ley compensada con volumen y '
          'costos unitarios bajos.',
      project: ProjectData(
        name: 'Pórfido Gran Pampa Cu (ficticio)',
        currency: 'USD',
        lifeYears: 20,
        discountRatePct: 8,
        metalPrice: 4.0,
        mineralType: MineralType.cobre,
        reservesTonnes: 500000000,
        averageGrade: 0.42,
        recoveryPct: 86,
        annualProductionTonnes: 25000000,
        plantCapacityTpd: 72000,
        operatingDaysPerYear: 350,
        royaltyPct: 3,
        taxEnabled: false,
        taxRatePct: 29.5,
        costs: MiningCosts(
          capex: 1800000000,
          developmentCost: 200000000,
          drillingCost: 0.35,
          blastingCost: 0.30,
          loadHaulCost: 1.20,
          extractionCost: 0.45,
          processingCost: 4.8,
          maintenanceCost: 0.9,
          otherVariableCost: 0.2,
          administrativeCost: 45000000,
          otherFixedCost: 25000000,
          closureCost: 150000000,
        ),
      ),
      assumptions: [
        'Economías de escala: costo variable de 8.2 USD/t.',
        'Inversión inicial de USD 2 000 M.',
        'Tasa de descuento de 8 % para un proyecto de larga vida.',
      ],
      questions: [
        '¿Cómo compensa la escala la baja ley?',
        '¿Por qué la ley de corte es baja en este proyecto?',
        '¿Qué efecto tiene la tasa de descuento en flujos de 20 años?',
      ],
      expectedCalculations: [
        'Metal recuperado = 25 Mt × 0.42 % × 22.0462 × 86 % ≈ 199.1 M lb/año.',
        'Ley de corte de equilibrio ≈ 0.15 % Cu.',
        'VAN al 8 % ≈ USD 2 852 M; TIR ≈ 24.5 %.',
      ],
      interpretation:
          'El gran volumen y los costos bajos generan un VAN positivo alto. '
          'La inversión es muy grande, por lo que el riesgo de financiamiento '
          'y de sobrecostos es relevante.',
      risks: [
        'Sobrecostos en un CAPEX de USD 2 000 M.',
        'Sensibilidad del VAN a la tasa de descuento por la larga vida.',
        'Riesgos sociales y ambientales de una operación de gran escala.',
      ],
      educationalDecision:
          'Escenario atractivo bajo los supuestos; analizar a fondo el '
          'financiamiento, la tasa de descuento y la gestión social.',
      explanation:
          'Con baja ley, cada tonelada vale poco, pero procesar 25 Mt/año con '
          'costos bajos produce mucho metal. Por eso la ley de corte también '
          'es baja: el material marginal todavía paga sus costos.',
      expectedNpvPositive: true,
      expectedIrrAboveRate: true,
      expectedPessimisticNpvPositive: true,
    ),
    CaseStudy(
      id: 'caso-5-sensible-precio',
      title: 'Caso 5: Proyecto sensible al precio',
      summary:
          'Proyecto argentífero con margen estrecho: pequeñas caídas del '
          'precio vuelven negativo el VAN.',
      project: ProjectData(
        name: 'Proyecto Plata Sur Ag (ficticio)',
        currency: 'USD',
        lifeYears: 10,
        discountRatePct: 10,
        metalPrice: 25,
        mineralType: MineralType.plata,
        reservesTonnes: 9000000,
        averageGrade: 125,
        recoveryPct: 85,
        annualProductionTonnes: 900000,
        plantCapacityTpd: 2700,
        operatingDaysPerYear: 340,
        royaltyPct: 3,
        taxEnabled: false,
        taxRatePct: 29.5,
        costs: MiningCosts(
          capex: 160000000,
          developmentCost: 20000000,
          drillingCost: 2.5,
          blastingCost: 2.0,
          loadHaulCost: 5.0,
          extractionCost: 4.5,
          processingCost: 14,
          maintenanceCost: 4,
          otherVariableCost: 1.0,
          administrativeCost: 9000000,
          otherFixedCost: 4000000,
          closureCost: 12000000,
        ),
      ),
      assumptions: [
        'Precio de la plata de 25 USD/oz en el escenario base.',
        'Escenario pesimista: precio −10 %, ley −5 %, recuperación −2 %, '
            'costos +10 %.',
      ],
      questions: [
        '¿El VAN base es positivo?',
        '¿Qué ocurre con el VAN en el escenario pesimista?',
        'Usa el módulo de sensibilidad: ¿qué variable mueve más el VAN?',
      ],
      expectedCalculations: [
        'VAN base al 10 % ≈ USD 11 M; TIR ≈ 11.5 %.',
        'VAN pesimista ≈ USD −107 M.',
        'Una variación de −10 % en el precio vuelve negativo el VAN.',
      ],
      interpretation:
          'El VAN base es apenas positivo y la TIR supera por poco la tasa: '
          'el proyecto es atractivo solo si el precio se mantiene. El riesgo '
          'económico es medio o alto.',
      risks: [
        'Volatilidad del precio de la plata.',
        'Margen estrecho frente a aumentos de costos.',
        'Poca holgura para errores en la ley.',
      ],
      educationalDecision:
          'No tomar una decisión solo con el escenario base; evaluar '
          'coberturas de precio, reducción de costos o mayor ley.',
      explanation:
          'Cuando el margen es estrecho, el VAN depende mucho del precio. El '
          'análisis de sensibilidad muestra que un proyecto "rentable" en el '
          'escenario base puede volverse no atractivo con cambios moderados.',
      expectedNpvPositive: true,
      expectedIrrAboveRate: true,
      expectedPessimisticNpvPositive: false,
    ),
    CaseStudy(
      id: 'caso-6-opex-elevado',
      title: 'Caso 6: Costos operativos elevados',
      summary:
          'Mina polimetálica de zinc cuyos altos costos por tonelada '
          'consumen casi todo el ingreso.',
      project: ProjectData(
        name: 'Mina Cerro Azul Zn (ficticia)',
        currency: 'USD',
        lifeYears: 10,
        discountRatePct: 10,
        metalPrice: 1.2,
        mineralType: MineralType.zinc,
        reservesTonnes: 6000000,
        averageGrade: 6.0,
        recoveryPct: 85,
        annualProductionTonnes: 600000,
        plantCapacityTpd: 1800,
        operatingDaysPerYear: 340,
        royaltyPct: 3,
        taxEnabled: false,
        taxRatePct: 29.5,
        costs: MiningCosts(
          capex: 110000000,
          developmentCost: 30000000,
          drillingCost: 8,
          blastingCost: 7,
          loadHaulCost: 14,
          extractionCost: 12,
          processingCost: 25,
          maintenanceCost: 9,
          otherVariableCost: 4,
          administrativeCost: 14000000,
          otherFixedCost: 8000000,
          closureCost: 5000000,
        ),
      ),
      assumptions: [
        'Costo variable de 79 USD/t y costos fijos de USD 22 M/año.',
        'Precio del zinc de 1.20 USD/lb.',
      ],
      questions: [
        '¿Cuál es el costo unitario total por tonelada?',
        '¿Qué margen operativo deja cada tonelada?',
        '¿Cuánto tendría que bajar el OPEX para que el VAN sea positivo?',
      ],
      expectedCalculations: [
        'OPEX = 79 USD/t × 0.6 Mt + USD 22 M = USD 69.4 M/año '
            '(≈ 115.7 USD/t).',
        'Ingreso neto ≈ USD 78.5 M/año; margen ≈ 11.6 %.',
        'VAN al 10 % ≈ USD −86 M; la TIR es negativa.',
      ],
      interpretation:
          'Los costos operativos consumen la mayor parte del ingreso: el VAN '
          'es negativo y la TIR es menor que la tasa de descuento. Bajo los '
          'supuestos ingresados, el escenario no es atractivo.',
      risks: [
        'Costos de energía, mano de obra y reactivos al alza.',
        'Productividad baja de equipos.',
        'Precio del zinc insuficiente para la estructura de costos.',
      ],
      educationalDecision:
          'No avanzar sin un plan de reducción de costos; evaluar mayor '
          'escala, mecanización o cambio de método de minado.',
      explanation:
          'Un yacimiento con ley aceptable puede no ser económico si los '
          'costos por tonelada son altos. En el escenario optimista (OPEX '
          '−5 %, precio +10 %) el VAN se vuelve positivo, lo que muestra la '
          'importancia de gestionar costos.',
      expectedNpvPositive: false,
      expectedIrrAboveRate: false,
      expectedPessimisticNpvPositive: false,
    ),
  ];
}
