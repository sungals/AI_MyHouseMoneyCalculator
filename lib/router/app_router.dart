import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/rent_compare/rent_compare_screen.dart';
import '../features/semi_rent/semi_rent_screen.dart';
import '../features/loan_interest/loan_interest_screen.dart';
import '../features/monthly_expense/monthly_expense_screen.dart';
import '../features/history/history_screen.dart';
import '../features/history/history_detail_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tax_deduction/tax_deduction_screen.dart';
import '../features/auth/login_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final box = Hive.box('app_settings');
      final done = box.get('onboarding_done', defaultValue: false) as bool;
      if (!done && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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
        path: '/tax-deduction',
        builder: (context, state) => const TaxDeductionScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
