import 'package:economina/models/mining_costs.dart';
import 'package:economina/models/project_data.dart';

/// Proyecto base usado por las pruebas (igual al proyecto por defecto).
ProjectData baseProject() => ProjectData.defaultProject();

/// Costos sencillos para verificar cálculos a mano.
const MiningCosts simpleCosts = MiningCosts(
  capex: 1000,
  developmentCost: 200,
  drillingCost: 1,
  blastingCost: 1,
  loadHaulCost: 2,
  extractionCost: 1,
  processingCost: 4,
  maintenanceCost: 0.5,
  otherVariableCost: 0.5,
  administrativeCost: 60,
  otherFixedCost: 40,
  closureCost: 100,
);
