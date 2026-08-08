import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/gen/app_localizations.dart';
import '../history/history_screen.dart';
import '../home/calculator_category_screen.dart';
import '../home/calculator_menu.dart';
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
      if (index == 3) {
        _historyRefreshKey++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    return Scaffold(
      body: _LazyIndexedStack(
        index: _selectedIndex,
        visitedIndexes: _visitedIndexes,
        children: [
          HomeScreen(),
          CalculatorCategoryScreen(
            title: l10n.sharedHousingTab,
            headline: l10n.sharedHousingHeadline,
            description: l10n.sharedHousingDescription,
            items: CalculatorMenus.housing,
          ),
          CalculatorCategoryScreen(
            title: l10n.sharedFinanceTab,
            headline: l10n.sharedFinanceHeadline,
            description: l10n.sharedFinanceDescription,
            items: CalculatorMenus.finance,
          ),
          HistoryScreen(key: ValueKey(_historyRefreshKey)),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectDestination,
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withOpacity(0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: palette.primary),
            label: l10n.sharedHomeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment, color: palette.primary),
            label: l10n.sharedHousingTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: palette.primary),
            label: l10n.sharedFinanceTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: palette.primary),
            label: l10n.sharedRecentTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: palette.primary),
            label: l10n.sharedSettingsTab,
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
