import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  int _historyRefreshKey = 0;
  final Set<int> _visitedIndexes = {0};

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
      _visitedIndexes.add(index);
      if (index == 1) {
        _historyRefreshKey++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _LazyIndexedStack(
        index: _selectedIndex,
        visitedIndexes: _visitedIndexes,
        children: [
          const HomeScreen(),
          HistoryScreen(key: ValueKey(_historyRefreshKey)),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: '최근계산',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.primary),
            label: '설정',
          ),
        ],
      ),
    );
  }
}

class _LazyIndexedStack extends StatelessWidget {
  const _LazyIndexedStack({
    required this.index,
    required this.visitedIndexes,
    required this.children,
  });

  final int index;
  final Set<int> visitedIndexes;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: [
        for (var i = 0; i < children.length; i++)
          visitedIndexes.contains(i) ? children[i] : const SizedBox.shrink(),
      ],
    );
  }
}
