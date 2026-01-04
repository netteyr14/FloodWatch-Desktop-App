import 'package:flutter/material.dart';

import '../widgets/sidebar_navigation.dart';
import 'admin_dashboard_screen.dart';
import 'operations_dashboard_screen.dart';
import 'profile_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int index = 0;
  bool _isSidebarCollapsed = true;

  final screens = const [
    AdminDashboardScreen(),
    OperationsDashboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarNavigation(
            selectedIndex: index,
            isCollapsed: _isSidebarCollapsed,
            onSelect: (i) => setState(() => index = i),
            onToggleCollapse: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),
          Expanded(
            child: screens[index],
          ),
        ],
      ),
    );
  }
}
