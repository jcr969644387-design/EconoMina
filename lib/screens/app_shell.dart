import 'package:flutter/material.dart';

import 'cases_screen.dart';
import 'home_screen.dart';
import 'project_data_screen.dart';
import 'tutor_screen.dart';

/// Contenedor principal con navegación inferior.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    ProjectDataScreen(),
    CasesScreen(),
    TutorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Proyecto'),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'Casos',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent),
            label: 'Tutor',
          ),
        ],
      ),
    );
  }
}
