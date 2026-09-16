import 'package:flutter/material.dart';

import '../services/feedback_actions.dart';
import '../widgets/info_widgets.dart';
import 'cases_screen.dart';
import 'cash_flow_screen.dart';
import 'costs_screen.dart';
import 'cutoff_screen.dart';
import 'irr_screen.dart';
import 'npv_screen.dart';
import 'production_screen.dart';
import 'project_data_screen.dart';
import 'quiz_screen.dart';
import 'sensitivity_screen.dart';
import 'tutor_screen.dart';

/// Descripción de un módulo navegable del MVP.
class AppModule {
  const AppModule({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String id;
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Módulos accesibles desde la pantalla de inicio (el 1 es el inicio).
final List<AppModule> appModules = [
  AppModule(
    id: 'datos',
    number: 2,
    title: 'Datos del proyecto',
    description: 'Reservas, ley, recuperación, precio y tasa.',
    icon: Icons.edit_note,
    builder: (_) => const ProjectDataScreen(),
  ),
  AppModule(
    id: 'costos',
    number: 3,
    title: 'Costos mineros',
    description: 'CAPEX, OPEX, costos unitarios y distribución.',
    icon: Icons.construction,
    builder: (_) => const CostsScreen(),
  ),
  AppModule(
    id: 'ley-corte',
    number: 4,
    title: 'Ley de corte',
    description: 'Modelo configurable y sensibilidad.',
    icon: Icons.filter_alt_outlined,
    builder: (_) => const CutoffScreen(),
  ),
  AppModule(
    id: 'produccion',
    number: 5,
    title: 'Producción e ingresos',
    description: 'Metal contenido, recuperado, ingresos y margen.',
    icon: Icons.precision_manufacturing_outlined,
    builder: (_) => const ProductionScreen(),
  ),
  AppModule(
    id: 'flujo',
    number: 6,
    title: 'Flujo económico',
    description: 'Tabla anual por escenario.',
    icon: Icons.table_chart_outlined,
    builder: (_) => const CashFlowScreen(),
  ),
  AppModule(
    id: 'van',
    number: 7,
    title: 'VAN',
    description: 'VAN, perfil y precio de equilibrio.',
    icon: Icons.savings_outlined,
    builder: (_) => const NpvScreen(),
  ),
  AppModule(
    id: 'tir',
    number: 8,
    title: 'TIR',
    description: 'Tasa interna de retorno y comparación.',
    icon: Icons.percent,
    builder: (_) => const IrrScreen(),
  ),
  AppModule(
    id: 'sensibilidad',
    number: 9,
    title: 'Sensibilidad',
    description: 'Escenarios y variables críticas.',
    icon: Icons.tune,
    builder: (_) => const SensitivityScreen(),
  ),
  AppModule(
    id: 'casos',
    number: 10,
    title: 'Casos empresariales',
    description: 'Seis proyectos ficticios para decidir.',
    icon: Icons.business_center_outlined,
    builder: (_) => const CasesScreen(),
  ),
  AppModule(
    id: 'evaluacion',
    number: 11,
    title: 'Evaluación práctica',
    description: 'Preguntas y ejercicios numéricos con puntaje.',
    icon: Icons.quiz_outlined,
    builder: (_) => const QuizScreen(),
  ),
  AppModule(
    id: 'tutor',
    number: 12,
    title: 'Tutor económico',
    description: 'Explicaciones locales sin conexión.',
    icon: Icons.support_agent,
    builder: (_) => const TutorScreen(),
  ),
];

/// Abre un módulo en una nueva ruta.
void openModule(BuildContext context, AppModule module) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: module.builder));
}

/// Abre la pantalla de datos del proyecto para corregir errores.
void openProjectData(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const ProjectDataScreen()));
}

/// Estructura común de las pantallas de módulo.
class ModuleScaffold extends StatelessWidget {
  const ModuleScaffold({
    super.key,
    required this.title,
    required this.children,
    this.showAppBar = true,
    this.actions = const [],
  });

  final String title;
  final List<Widget> children;
  final bool showAppBar;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: SimulatedBadge(),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
    if (!showAppBar) {
      return content;
    }
    final navigator = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        leading: navigator.canPop()
            ? BackButton(
                onPressed: context.onButton(() => navigator.maybePop()),
              )
            : null,
      ),
      body: content,
    );
  }
}
