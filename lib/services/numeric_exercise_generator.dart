import 'dart:math' as math;

import '../models/mineral_type.dart';
import '../models/numeric_exercise.dart';
import '../utils/formatters.dart';

/// Genera ejercicios numéricos de economía minera con datos aleatorios pero
/// realistas. La misma semilla produce siempre los mismos ejercicios, lo que
/// permite repetir una práctica y probarla automáticamente.
class NumericExerciseGenerator {
  NumericExerciseGenerator({int? seed}) : _random = math.Random(seed);

  final math.Random _random;

  /// Número de tipos de ejercicio disponibles.
  static const int exerciseTypes = 8;

  /// Devuelve [count] ejercicios sin repetir tipo (máximo [exerciseTypes]).
  List<NumericExercise> generate({int count = 6}) {
    final builders = <NumericExercise Function()>[
      _unitCost,
      _containedCopper,
      _recoveredGold,
      _netRevenue,
      _cutoffGrade,
      _presentValue,
      _npvThreeYears,
      _payback,
    ]..shuffle(_random);
    final total = math.min(math.max(count, 1), exerciseTypes);
    return [for (var i = 0; i < total; i++) builders[i]()];
  }

  double _pick(double min, double max, double step) {
    final steps = ((max - min) / step).round();
    return min + step * _random.nextInt(steps + 1);
  }

  static String _n(double value, [int decimals = 2]) =>
      Formatters.number(value, decimals: decimals);

  NumericExercise _unitCost() {
    final variable = _pick(12, 30, 0.5);
    final fixed = _pick(8, 30, 1);
    final tonnes = _pick(1, 5, 0.5);
    final opex = variable * tonnes * 1e6 + fixed * 1e6;
    final answer = opex / (tonnes * 1e6);
    return NumericExercise(
      id: 'costo-unitario',
      topic: 'Costo unitario',
      prompt:
          'Una mina trata ${_n(tonnes, 1)} Mt al año con un costo variable de '
          '${_n(variable, 1)} USD/t y costos fijos de ${_n(fixed, 0)} M USD/año. '
          '¿Cuál es el costo unitario de operación?',
      answer: answer,
      unit: 'USD/t',
      steps: [
        'OPEX = ${_n(variable, 1)} × ${_n(tonnes * 1e6, 0)} + '
            '${_n(fixed * 1e6, 0)} = ${_n(opex, 0)} USD/año.',
        'Costo unitario = OPEX / t = ${_n(opex, 0)} / '
            '${_n(tonnes * 1e6, 0)} = ${_n(answer)} USD/t.',
      ],
    );
  }

  NumericExercise _containedCopper() {
    final tonnes = _pick(0.5, 4, 0.5);
    final grade = _pick(0.4, 1.5, 0.05);
    final factor = MineralType.cobre.conversionFactor;
    final answer = tonnes * grade * factor;
    return NumericExercise(
      id: 'metal-contenido',
      topic: 'Metal contenido',
      prompt:
          'Se tratan ${_n(tonnes, 1)} Mt de mineral con ley de '
          '${_n(grade)} % Cu. ¿Cuántos millones de libras de cobre contiene?',
      answer: answer,
      unit: 'M lb',
      steps: [
        '1 % de 1 t equivale a 10 kg = 22.0462 lb.',
        'Metal contenido = ${_n(tonnes, 1)} Mt × ${_n(grade)} × 22.0462 = '
            '${_n(answer)} M lb.',
      ],
    );
  }

  NumericExercise _recoveredGold() {
    final tonnes = _pick(200, 2000, 100);
    final grade = _pick(1, 8, 0.5);
    final recovery = _pick(80, 95, 1);
    final contained = tonnes * 1000 * grade / 31.1035;
    final answer = contained * recovery / 100 / 1000;
    return NumericExercise(
      id: 'oro-recuperado',
      topic: 'Metal recuperado',
      prompt:
          'Una planta procesa ${_n(tonnes, 0)} mil toneladas con '
          '${_n(grade, 1)} g/t Au y una recuperación de '
          '${_n(recovery, 0)} %. ¿Cuántas miles de onzas (koz) se recuperan?',
      answer: answer,
      unit: 'koz',
      steps: [
        'Oro contenido = ${_n(tonnes * 1000, 0)} t × ${_n(grade, 1)} g/t / '
            '31.1035 = ${_n(contained, 0)} oz.',
        'Oro recuperado = ${_n(contained, 0)} × ${_n(recovery, 0)} % = '
            '${_n(answer * 1000, 0)} oz = ${_n(answer)} koz.',
      ],
    );
  }

  NumericExercise _netRevenue() {
    final metal = _pick(10, 60, 1);
    final price = _pick(3, 5, 0.1);
    final royalty = _pick(1, 5, 0.5);
    final gross = metal * price;
    final answer = gross * (1 - royalty / 100);
    return NumericExercise(
      id: 'ingreso-neto',
      topic: 'Ingresos',
      prompt:
          'Se venden ${_n(metal, 0)} M lb de cobre a ${_n(price)} USD/lb y se '
          'paga una regalía de ${_n(royalty, 1)} % sobre el ingreso bruto. '
          '¿Cuál es el ingreso neto en millones de USD?',
      answer: answer,
      unit: 'M USD',
      steps: [
        'Ingreso bruto = ${_n(metal, 0)} × ${_n(price)} = ${_n(gross)} M USD.',
        'Regalías = ${_n(gross)} × ${_n(royalty, 1)} % = '
            '${_n(gross - answer)} M USD.',
        'Ingreso neto = ${_n(gross)} − ${_n(gross - answer)} = '
            '${_n(answer)} M USD.',
      ],
    );
  }

  NumericExercise _cutoffGrade() {
    final cost = _pick(15, 40, 1);
    final price = _pick(3, 5, 0.25);
    final recovery = _pick(80, 92, 1);
    final factor = MineralType.cobre.conversionFactor;
    final value = price * recovery / 100 * factor;
    final answer = cost / value;
    return NumericExercise(
      id: 'ley-de-corte',
      topic: 'Ley de corte',
      prompt:
          'Los costos de mina, planta y generales suman ${_n(cost, 0)} USD/t. '
          'El cobre vale ${_n(price)} USD/lb (sin regalías ni costos de venta) '
          'y la recuperación es ${_n(recovery, 0)} %. ¿Cuál es la ley de corte '
          'de equilibrio en % Cu?',
      answer: answer,
      unit: '% Cu',
      decimals: 3,
      steps: [
        'Valor por tonelada y por 1 % de ley = ${_n(price)} × '
            '${_n(recovery / 100)} × 22.0462 = ${_n(value)} USD.',
        'Ley de corte = ${_n(cost, 0)} / ${_n(value)} = '
            '${_n(answer, 3)} % Cu.',
      ],
    );
  }

  NumericExercise _presentValue() {
    final flow = _pick(20, 120, 5);
    final rate = _pick(6, 15, 1);
    final year = 2 + _random.nextInt(7);
    final factor = 1 / math.pow(1 + rate / 100, year).toDouble();
    final answer = flow * factor;
    return NumericExercise(
      id: 'valor-presente',
      topic: 'Valor del dinero en el tiempo',
      prompt:
          'Un proyecto recibirá ${_n(flow, 0)} M USD en el año $year. Con una '
          'tasa de descuento de ${_n(rate, 0)} %, ¿cuál es su valor presente '
          'en millones de USD?',
      answer: answer,
      unit: 'M USD',
      steps: [
        'Factor = 1 / (1 + ${_n(rate / 100)})^$year = ${_n(factor, 4)}.',
        'Valor presente = ${_n(flow, 0)} × ${_n(factor, 4)} = '
            '${_n(answer)} M USD.',
      ],
    );
  }

  NumericExercise _npvThreeYears() {
    final investment = _pick(80, 200, 10);
    final flow = _pick(30, 90, 5);
    final rate = _pick(8, 14, 1);
    final r = rate / 100;
    var pv = 0.0;
    final parts = <String>[];
    for (var t = 1; t <= 3; t++) {
      final value = flow / math.pow(1 + r, t).toDouble();
      pv += value;
      parts.add(_n(value));
    }
    final answer = pv - investment;
    return NumericExercise(
      id: 'van-tres-anios',
      topic: 'VAN',
      prompt:
          'Un proyecto invierte ${_n(investment, 0)} M USD en el año 0 y '
          'genera ${_n(flow, 0)} M USD al final de cada uno de los 3 años '
          'siguientes. Con una tasa de ${_n(rate, 0)} %, ¿cuál es el VAN en '
          'millones de USD? (usa signo negativo si corresponde)',
      answer: answer,
      unit: 'M USD',
      tolerancePct: 2,
      decimals: 1,
      steps: [
        'Valores presentes: ${parts.join(' + ')} = ${_n(pv)} M USD.',
        'VAN = ${_n(pv)} − ${_n(investment, 0)} = ${_n(answer)} M USD.',
        answer >= 0
            ? 'VAN positivo: el proyecto supera la tasa exigida.'
            : 'VAN negativo: el proyecto no alcanza la tasa exigida.',
      ],
    );
  }

  NumericExercise _payback() {
    final investment = _pick(100, 400, 20);
    final flow = _pick(30, 100, 5);
    final answer = investment / flow;
    return NumericExercise(
      id: 'recuperacion',
      topic: 'Periodo de recuperación',
      prompt:
          'La inversión inicial es ${_n(investment, 0)} M USD y el flujo neto '
          'es constante de ${_n(flow, 0)} M USD por año. ¿En cuántos años se '
          'recupera la inversión (sin descontar)?',
      answer: answer,
      unit: 'años',
      steps: [
        'Periodo de recuperación = inversión / flujo anual.',
        '${_n(investment, 0)} / ${_n(flow, 0)} = ${_n(answer)} años.',
        'No considera el valor del dinero en el tiempo ni los flujos '
            'posteriores.',
      ],
    );
  }
}
