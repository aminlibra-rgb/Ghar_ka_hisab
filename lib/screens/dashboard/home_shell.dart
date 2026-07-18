import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../dashboard/dashboard_screen.dart';
import '../reports/reports_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

/// نچلی نیویگیشن بار کے ساتھ مرکزی ایپ شیل
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ReportsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: AppStrings.dashboard),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: AppStrings.reports),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: AppStrings.search),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: AppStrings.settings),
        ],
      ),
    );
  }
}
