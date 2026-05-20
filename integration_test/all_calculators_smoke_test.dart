import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:house_money_calculator/main.dart' as app;
import 'package:house_money_calculator/router/app_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('all calculator result flows', (tester) async {
    await Hive.initFlutter();
    final box = await Hive.openBox('app_settings');
    await box.put('onboarding_done', true);
    await box.put('login_skipped', true);
    await box.put('simple_login_enabled', false);
    await box.delete('simple_login_pin_hash');
    await box.delete('simple_login_biometric_enabled');
    await box.delete('simple_login_require_auth_on_launch');

    await app.bootstrap(
      initializeNotifications: false,
      cleanupStalePushToken: false,
      resetLoginSkipOnNoSession: false,
    );
    await _pumpUntilFound(tester, find.text('홈'));

    await _runCalculator(
      tester,
      route: '/rent-compare',
      title: '전세 vs 월세 비교',
      values: [
        '300000000',
        '200000000',
        '3.5',
        '10000000',
        '900000',
        '100000',
        '24'
      ],
    );
    await _runCalculator(
      tester,
      route: '/scenario-compare',
      title: '복수 시나리오 비교',
      buttonLabel: '시나리오 비교하기',
      values: [
        '300000000',
        '200000000',
        '10000000',
        '900000',
        '100000',
        '24',
        '3.0',
        '3.5',
        '4.0',
      ],
    );
    await _runCalculator(
      tester,
      route: '/contract-renewal',
      title: '계약 갱신 계산',
      values: ['300000000', '800000', '5'],
    );
    await _runCalculator(
      tester,
      route: '/jeonse-risk',
      title: '전세사기 위험도 체크',
      buttonLabel: '위험도 체크하기',
      values: ['300000000', '280000000', '70000000'],
    );
    await _runCalculator(
      tester,
      route: '/semi-rent',
      title: '반전세 계산',
      values: ['300000000', '100000000', '900000', '5.0', '100000', '24'],
    );
    await _runCalculator(
      tester,
      route: '/loan-interest',
      title: '대출이자 계산',
      values: ['200000000', '4.5', '36'],
    );
    await _runCalculator(
      tester,
      route: '/monthly-expense',
      title: '월 고정비 계산',
      values: [
        '900000',
        '120000',
        '80000',
        '150000',
        '200000',
        '50000',
        '400000',
        '100000',
      ],
    );
    await _runCalculator(
      tester,
      route: '/tax-deduction',
      title: '연말정산 세액공제',
      values: ['50000000', '900000', '12000000'],
    );
    await _runCalculator(
      tester,
      route: '/dsr-dti',
      title: 'DSR/DTI 계산',
      values: ['60000000', '12000000', '6000000'],
      pdfLabel: 'PDF',
    );
    await _runCalculator(
      tester,
      route: '/brokerage-fee',
      title: '중개보수 계산',
      values: ['600000000'],
      pdfLabel: 'PDF',
    );
    await _runCalculator(
      tester,
      route: '/acquisition-tax',
      title: '취득세 계산',
      values: ['600000000'],
      pdfLabel: 'PDF',
    );

    expect(tester.takeException(), isNull);
  });
}

Future<void> _runCalculator(
  WidgetTester tester, {
  required String route,
  required String title,
  required List<String> values,
  String buttonLabel = '계산하기',
  String pdfLabel = 'PDF 내보내기',
}) async {
  AppRouter.router.go(route);
  await tester.pumpAndSettle();
  await _pumpUntilFound(tester, find.text(title));
  await _pumpUntilFieldCount(tester, values.length);

  for (var i = 0; i < values.length; i++) {
    final field = find.byType(TextFormField).at(i);
    await tester.ensureVisible(field);
    await tester.enterText(field, values[i]);
    await tester.pump(const Duration(milliseconds: 120));
  }

  final button = find.text(buttonLabel);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();

  final pdf = find.text(pdfLabel);
  await tester.ensureVisible(pdf);
  expect(pdf, findsOneWidget);
}

Future<void> _pumpUntilFieldCount(
  WidgetTester tester,
  int count, {
  Duration timeout = const Duration(seconds: 12),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (find.byType(TextFormField).evaluate().length >= count) return;
  }
  debugPrint('VISIBLE_TEXTS:${_visibleTexts(tester).join('|')}');
  expect(find.byType(TextFormField), findsAtLeastNWidgets(count));
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 60),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) return;
  }
  await tester.pumpAndSettle();
  debugPrint('VISIBLE_TEXTS:${_visibleTexts(tester).join('|')}');
  expect(finder, findsOneWidget);
}

List<String> _visibleTexts(WidgetTester tester) {
  return find
      .byType(Text)
      .evaluate()
      .map((element) => element.widget)
      .whereType<Text>()
      .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
      .where((text) => text.isNotEmpty)
      .toList(growable: false);
}
