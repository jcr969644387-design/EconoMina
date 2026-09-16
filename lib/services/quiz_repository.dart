import '../models/learning_models.dart';

/// Banco de preguntas de la evaluación práctica.
class QuizRepository {
  const QuizRepository();

  List<QuizQuestion> all() => _questions;

  static const List<QuizQuestion> _questions = [
    QuizQuestion(
      topic: 'CAPEX',
      prompt: '¿Cuál de los siguientes es un ejemplo de CAPEX?',
      options: [
        'La compra de la flota de camiones y la construcción de la planta',
        'El consumo mensual de explosivos',
        'Los sueldos del personal administrativo',
        'La energía eléctrica usada en la planta',
      ],
      correctIndex: 0,
      explanation:
          'El CAPEX es la inversión en activos de larga duración (equipos, '
          'planta, infraestructura). Explosivos, sueldos y energía son costos '
          'de operación (OPEX).',
    ),
    QuizQuestion(
      topic: 'OPEX',
      prompt: '¿Qué característica describe mejor al OPEX?',
      options: [
        'Se paga una sola vez antes de iniciar la producción',
        'Son los costos recurrentes necesarios para operar cada año',
        'Es el valor de rescate de los equipos',
        'Es el ingreso por venta del concentrado',
      ],
      correctIndex: 1,
      explanation:
          'El OPEX agrupa los costos recurrentes de operación: perforación, '
          'voladura, carguío, procesamiento, mantenimiento y administración.',
    ),
    QuizQuestion(
      topic: 'Costos unitarios',
      prompt:
          'Ejercicio: el OPEX anual es USD 50 M y se procesan 2 Mt al año. '
          '¿Cuál es el costo unitario?',
      options: ['2.5 USD/t', '25 USD/t', '100 USD/t', '250 USD/t'],
      correctIndex: 1,
      explanation:
          'Costo unitario = OPEX / toneladas = 50 000 000 / 2 000 000 = '
          '25 USD/t.',
      isExercise: true,
    ),
    QuizQuestion(
      topic: 'Producción',
      prompt:
          'Ejercicio: una planta procesa 5 000 t/día y opera 350 días al año. '
          '¿Cuál es su capacidad anual?',
      options: ['1.75 Mt/año', '5.35 Mt/año', '0.175 Mt/año', '17.5 Mt/año'],
      correctIndex: 0,
      explanation:
          'Capacidad anual = 5 000 t/día × 350 días = 1 750 000 t = '
          '1.75 Mt/año.',
      isExercise: true,
    ),
    QuizQuestion(
      topic: 'Producción',
      prompt:
          'Ejercicio: se procesan 1 000 000 t con ley de 1.0 % Cu. ¿Cuánto '
          'cobre contenido hay aproximadamente?',
      options: ['10 000 lb', '2.2 M lb', '22.05 M lb', '220.5 M lb'],
      correctIndex: 2,
      explanation:
          'Metal contenido = 1 000 000 t × 1.0 % × 22.0462 lb/(t·%) = '
          '22 046 200 lb ≈ 22.05 M lb.',
      isExercise: true,
    ),
    QuizQuestion(
      topic: 'Recuperación',
      prompt:
          'Ejercicio: el metal contenido es 10 M lb y la recuperación es '
          '90 %. ¿Cuál es el metal recuperado?',
      options: ['9 M lb', '10 M lb', '1 M lb', '11.1 M lb'],
      correctIndex: 0,
      explanation:
          'Metal recuperado = metal contenido × recuperación = 10 M lb × '
          '0.90 = 9 M lb.',
      isExercise: true,
    ),
    QuizQuestion(
      topic: 'Recuperación',
      prompt:
          'Si la recuperación metalúrgica baja, manteniendo lo demás '
          'constante, ¿qué ocurre?',
      options: [
        'Aumentan los ingresos',
        'Disminuyen los ingresos y sube la ley de corte',
        'Baja la ley de corte',
        'No cambia nada porque la ley es la misma',
      ],
      correctIndex: 1,
      explanation:
          'Con menor recuperación se vende menos metal por tonelada: bajan '
          'los ingresos y se necesita más ley para cubrir los mismos costos, '
          'por lo que la ley de corte sube.',
    ),
    QuizQuestion(
      topic: 'Ley de corte',
      prompt:
          'Si el precio del metal sube y los costos se mantienen, la ley de '
          'corte de equilibrio...',
      options: ['Sube', 'Baja', 'No cambia', 'Se vuelve negativa'],
      correctIndex: 1,
      explanation:
          'Ley de corte = costos / (precio neto × recuperación × factor). Si '
          'el precio aumenta, el denominador crece y la ley de corte baja: '
          'material de menor ley se vuelve económico.',
    ),
    QuizQuestion(
      topic: 'Ley de corte',
      prompt:
          'Ejercicio: costos de 20 USD/t, precio neto 4 USD/lb, recuperación '
          '90 % y factor 22.0462 lb/(t·%). ¿Cuál es la ley de corte?',
      options: ['0.025 %', '0.25 %', '2.5 %', '0.9 %'],
      correctIndex: 1,
      explanation:
          'Ley de corte = 20 / (4 × 0.90 × 22.0462) = 20 / 79.37 ≈ 0.25 % Cu.',
      isExercise: true,
    ),
    QuizQuestion(
      topic: 'Flujo de caja',
      prompt:
          'Ejercicio: ingreso neto USD 80 M, OPEX USD 50 M, impuestos '
          'USD 6 M y sin inversión ni cierre en el año. ¿Cuál es el flujo '
          'neto?',
      options: ['USD 30 M', 'USD 24 M', 'USD 36 M', 'USD 136 M'],
      correctIndex: 1,
      explanation:
          'Flujo neto = ingreso neto − OPEX − impuestos = 80 − 50 − 6 = '
          'USD 24 M.',
      isExercise: true,
    ),
    QuizQuestion(
      topic: 'VAN',
      prompt:
          'Ejercicio: I0 = 100, FC1 = 60, FC2 = 60 y r = 10 %. ¿Cuál es el '
          'VAN aproximado?',
      options: ['20.00', '4.13', '−4.13', '9.09'],
      correctIndex: 1,
      explanation:
          'VAN = 60/1.1 + 60/1.1² − 100 = 54.55 + 49.59 − 100 ≈ 4.13. Es '
          'positivo: los flujos descontados superan la inversión.',
      isExercise: true,
    ),
    QuizQuestion(
      topic: 'VAN',
      prompt:
          'Un VAN positivo significa, bajo los supuestos ingresados, que...',
      options: [
        'El proyecto está aprobado para construirse',
        'Los flujos descontados superan la inversión inicial',
        'La TIR es igual a cero',
        'No existe ningún riesgo',
      ],
      correctIndex: 1,
      explanation:
          'El VAN positivo indica que el proyecto genera valor por encima de '
          'la tasa exigida, pero no es una aprobación ni elimina riesgos.',
    ),
    QuizQuestion(
      topic: 'TIR',
      prompt: '¿Qué representa la TIR?',
      options: [
        'La tasa de impuestos del proyecto',
        'La tasa de descuento que hace el VAN igual a cero',
        'El porcentaje de recuperación metalúrgica',
        'La inflación esperada',
      ],
      correctIndex: 1,
      explanation:
          'La TIR es la tasa que iguala a cero el VAN. Se compara con la tasa '
          'de descuento exigida.',
    ),
    QuizQuestion(
      topic: 'TIR',
      prompt:
          'Un proyecto tiene TIR de 8 % y la tasa de descuento es 10 %. Con '
          'flujos convencionales, su VAN al 10 % será...',
      options: ['Positivo', 'Negativo', 'Igual a cero', 'Imposible de saber'],
      correctIndex: 1,
      explanation:
          'Si la TIR es menor que la tasa de descuento, descontar al 10 % '
          'reduce más los flujos y el VAN resulta negativo.',
    ),
    QuizQuestion(
      topic: 'Tasa de descuento',
      prompt:
          'Si la tasa de descuento aumenta, el VAN de un proyecto '
          'convencional...',
      options: ['Aumenta', 'Disminuye', 'No cambia', 'Se duplica'],
      correctIndex: 1,
      explanation:
          'Una tasa mayor reduce el valor presente de los flujos futuros, '
          'especialmente los más lejanos; por eso el VAN disminuye.',
    ),
    QuizQuestion(
      topic: 'Sensibilidad',
      prompt: '¿Para qué sirve el análisis de sensibilidad?',
      options: [
        'Para calcular la ley promedio',
        'Para identificar qué variables afectan más al VAN y a la TIR',
        'Para eliminar la incertidumbre del proyecto',
        'Para reemplazar el estudio de factibilidad',
      ],
      correctIndex: 1,
      explanation:
          'La sensibilidad muestra cómo cambian los resultados al variar una '
          'variable a la vez y ayuda a identificar las variables críticas.',
    ),
    QuizQuestion(
      topic: 'Riesgo económico',
      prompt:
          'El VAN base es positivo, pero el VAN pesimista es negativo. ¿Cómo '
          'clasifica EconoMina el riesgo?',
      options: ['Bajo', 'Medio', 'Alto', 'Nulo'],
      correctIndex: 1,
      explanation:
          'EconoMina asigna riesgo medio cuando el escenario base es atractivo '
          'pero el pesimista no: el resultado depende de que los supuestos se '
          'cumplan.',
    ),
  ];
}
