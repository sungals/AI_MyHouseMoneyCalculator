import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/shared/main_shell.dart';
import '../features/rent_compare/rent_compare_screen.dart';
import '../features/semi_rent/semi_rent_screen.dart';
import '../features/loan_interest/loan_interest_screen.dart';
import '../features/monthly_expense/monthly_expense_screen.dart';
import '../features/history/history_screen.dart';
import '../features/history/history_detail_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/app_guide_screen.dart';
import '../features/settings/legal_document_screen.dart';
import '../features/settings/account_manage_screen.dart';
import '../features/settings/notices_screen.dart';
import '../features/settings/notice_detail_screen.dart';
import '../features/tax_deduction/tax_deduction_screen.dart';
import '../features/advanced_calculators/acquisition_tax_screen.dart';
import '../features/advanced_calculators/brokerage_fee_screen.dart';
import '../features/advanced_calculators/dsr_dti_screen.dart';
import '../features/contract_renewal/contract_renewal_screen.dart';
import '../features/jeonse_risk/jeonse_risk_screen.dart';
import '../features/scenario_compare/scenario_compare_screen.dart';
import '../core/constants/legal_texts.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/pin/biometric_auth_service.dart';
import '../features/auth/pin/biometric_login_screen.dart';
import '../features/auth/pin/pin_login_screen.dart';
import '../features/auth/pin/pin_notifier.dart';
import '../features/auth/pin/biometric_setup_screen.dart';
import '../features/auth/pin/pin_change_screen.dart';
import '../features/auth/pin/pin_setup_screen.dart';
import '../features/auth/pin/pin_state.dart';
import '../features/admin/admin_notices_screen.dart';
import '../features/admin/admin_notice_form_screen.dart';

class AppRouter {
  AppRouter._();

  static String? _pendingRouteAfterUnlock;

  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // redirect는 앱 시작, 라우팅, refresh 때마다 호출된다.
      // 여기서 사용하는 Hive box는 main.bootstrap에서 미리 열려 있어야 한다.
      final box = Hive.box('app_settings');
      final done = box.get('onboarding_done', defaultValue: false) as bool;

      if (!done && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      if (done) {
        final loginSkipped =
            box.get('login_skipped', defaultValue: false) as bool;
        final hasSession = Supabase.instance.client.auth.currentSession != null;
        final loc = state.matchedLocation;

        // 관리자 화면은 클라이언트 라우팅과 Supabase RLS 양쪽에서 보호한다.
        if (loc.startsWith('/admin')) {
          if (!hasSession) return '/login';
          final email = Supabase.instance.client.auth.currentUser?.email;
          if (email != AppConstants.adminEmail) return '/';
        }

        if (!hasSession &&
            !loginSkipped &&
            loc != '/login' &&
            loc != '/onboarding') {
          return '/login';
        }

        if (hasSession) {
          final container = ProviderScope.containerOf(context);
          final pinState = container.read(pinNotifierProvider);
          final pinRoutes = {
            '/biometric-login',
            '/pin-login',
            '/pin-setup',
            '/pin-change',
            '/biometric-setup',
            '/login',
            '/onboarding',
          };
          if (pinState is PinEnabled &&
              !pinState.isUnlocked &&
              !pinRoutes.contains(loc)) {
            final container = ProviderScope.containerOf(context);
            final biometricEnabled =
                container.read(biometricAuthServiceProvider).isEnabled;
            // PIN/생체인증 성공 뒤 원래 접근하려던 상세 화면으로 복귀하기 위한 임시 저장소.
            _pendingRouteAfterUnlock = state.uri.toString();
            return biometricEnabled ? '/biometric-login' : '/pin-login';
          }
        }
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
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/rent-compare',
        builder: (context, state) => const RentCompareScreen(),
      ),
      GoRoute(
        path: '/scenario-compare',
        builder: (context, state) => const ScenarioCompareScreen(),
      ),
      GoRoute(
        path: '/contract-renewal',
        builder: (context, state) => const ContractRenewalScreen(),
      ),
      GoRoute(
        path: '/jeonse-risk',
        builder: (context, state) => const JeonseRiskScreen(),
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
        path: '/dsr-dti',
        builder: (context, state) => const DsrDtiScreen(),
      ),
      GoRoute(
        path: '/brokerage-fee',
        builder: (context, state) => const BrokerageFeeScreen(),
      ),
      GoRoute(
        path: '/acquisition-tax',
        builder: (context, state) => const AcquisitionTaxScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/app-guide',
        builder: (context, state) => const AppGuideScreen(),
      ),
      GoRoute(
        path: '/account-manage',
        builder: (context, state) => const AccountManageScreen(),
      ),
      GoRoute(
        path: '/notices',
        builder: (context, state) => const NoticesScreen(),
      ),
      GoRoute(
        path: '/notices/:id',
        builder: (context, state) => NoticeDetailScreen(
          noticeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const LegalDocumentScreen(
          document: LegalTexts.terms,
        ),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const LegalDocumentScreen(
          document: LegalTexts.privacy,
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/biometric-login',
        builder: (context, state) => const BiometricLoginScreen(),
      ),
      GoRoute(
        path: '/pin-login',
        builder: (context, state) => const PinLoginScreen(),
      ),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: '/pin-change',
        builder: (context, state) => const PinChangeScreen(),
      ),
      GoRoute(
        path: '/biometric-setup',
        builder: (context, state) => const BiometricSetupScreen(),
      ),
      GoRoute(
        path: '/admin/notices',
        builder: (context, state) => const AdminNoticesScreen(),
      ),
      GoRoute(
        path: '/admin/notices/new',
        builder: (context, state) => const AdminNoticeFormScreen(),
      ),
      GoRoute(
        path: '/admin/notices/:id/edit',
        builder: (context, state) => AdminNoticeFormScreen(
          noticeId: state.pathParameters['id'],
        ),
      ),
    ],
  );

  static void openNoticeFromPush(String? noticeId) {
    final id = noticeId?.trim();
    // go('/') sets MainShell as the base so the back button exists on the pushed screen
    router.go('/');
    if (id == null || id.isEmpty) {
      router.push('/notices');
    } else {
      router.push('/notices/$id');
    }
  }

  static String consumePendingRouteAfterUnlock() {
    final route = _pendingRouteAfterUnlock;
    _pendingRouteAfterUnlock = null;
    return route == null || route.isEmpty ? '/' : route;
  }
}
