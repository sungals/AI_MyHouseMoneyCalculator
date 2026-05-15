import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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
    return Scaffold(
      body: _LazyIndexedStack(
        index: _selectedIndex,
        visitedIndexes: _visitedIndexes,
        children: [
          const HomeScreen(),
          const CalculatorCategoryScreen(
            title: '주거',
            headline: '계약과 임대료를\n비교하세요',
            description: '전세, 월세, 반전세, 계약 갱신처럼 집 계약에 직접 연결되는 계산입니다.',
            items: CalculatorMenus.housing,
          ),
          const CalculatorCategoryScreen(
            title: '금융',
            headline: '대출과 세금을\n따져보세요',
            description: '대출 부담, 월 고정비, 세액공제, 거래 비용을 한곳에 모았습니다.',
            items: CalculatorMenus.finance,
          ),
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
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment, color: AppColors.primary),
            label: '주거',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: AppColors.primary),
            label: '금융',
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
