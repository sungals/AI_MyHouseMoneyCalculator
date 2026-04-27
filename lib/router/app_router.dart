import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/rent_compare/rent_compare_screen.dart';
import '../features/semi_rent/semi_rent_screen.dart';
import '../features/loan_interest/loan_interest_screen.dart';
import '../features/monthly_expense/monthly_expense_screen.dart';
import '../features/history/history_screen.dart';
import '../features/history/history_detail_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/rent-compare',
        builder: (context, state) => const RentCompareScreen(),
      ),
      GoRoute(
        path: '/semi-rent',
        builder: (context, state) => const SemiRentScreen(),
      ),
      GoRoute(
        path: '/loan-interest',
        builder: (context, state) => const LoanInterestScreen(),
      ),
      GoRoute(
        path: '/monthly-expense',
        builder: (context, state) => const MonthlyExpenseScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/history/:id',
        builder: (context, state) => HistoryDetailScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
