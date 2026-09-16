import 'dart:math' as math;

import '../models/project_data.dart';
import '../models/scenario.dart';

/// Aplica los factores de un escenario a un proyecto.
class ScenarioBuilder {
  const ScenarioBuilder();

  ProjectData apply(ProjectData project, ScenarioType scenario) {
    if (scenario == ScenarioType.base) {
      return project;
    }
    return project.copyWith(
      metalPrice: project.metalPrice * scenario.priceFactor,
      averageGrade: project.averageGrade * scenario.gradeFactor,
      recoveryPct: math.min(
        100.0,
        project.recoveryPct * scenario.recoveryFactor,
      ),
      costs: project.costs.scaled(
        capexFactor: scenario.capexFactor,
        opexFactor: scenario.opexFactor,
      ),
    );
  }
}
