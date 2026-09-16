import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'services/progress_store.dart';
import 'services/project_controller.dart';
import 'services/project_scope.dart';
import 'theme/app_theme.dart';
import 'utils/app_texts.dart';

/// Aplicación EconoMina.
class EconoMinaApp extends StatefulWidget {
  const EconoMinaApp({super.key, this.controller});

  /// Controlador opcional (útil para pruebas). Si no se entrega, se crea uno
  /// que guarda el progreso en el dispositivo.
  final ProjectController? controller;

  @override
  State<EconoMinaApp> createState() => _EconoMinaAppState();
}

class _EconoMinaAppState extends State<EconoMinaApp> {
  late final ProjectController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    final provided = widget.controller;
    _ownsController = provided == null;
    _controller =
        provided ?? ProjectController(store: SharedPreferencesProgressStore());
    if (_ownsController) {
      unawaited(_controller.restore());
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProjectScope(
      controller: _controller,
      child: MaterialApp(
        title: AppTexts.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        home: const AppShell(),
      ),
    );
  }
}
