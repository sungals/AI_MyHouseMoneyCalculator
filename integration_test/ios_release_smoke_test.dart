import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:house_money_calculator/main.dart' as app;
import 'package:house_money_calculator/router/app_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('result smoke flow', (tester) async {
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
    AppRouter.router.go('/jeonse-risk');
    await _pumpUntilFieldCount(tester, 3);
    expect(find.text('전세사기 위험도 체크'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '300000000');
    await tester.enterText(find.byType(TextFormField).at(1), '280000000');
    await tester.enterText(find.byType(TextFormField).at(2), '70000000');
    await tester.ensureVisible(find.text('위험도 체크하기'));
    await tester.tap(find.text('위험도 체크하기'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );

    await tester.ensureVisible(find.text('권장 조치'));
    expect(find.text('권장 조치'), findsOneWidget);
    await tester.ensureVisible(find.text('보호 절차 체크리스트'));
    expect(find.text('보호 절차 체크리스트'), findsOneWidget);

    await tester.ensureVisible(find.text('공유'));
    expect(find.text('공유'), findsOneWidget);
    expect(find.text('저장'), findsOneWidget);
    await tester.ensureVisible(find.text('PDF 내보내기'));
    expect(find.text('PDF 내보내기'), findsOneWidget);

    // Give the banner a chance to load. If the network or AdMob test service is
    // unavailable, this should not fail the app flow; the ad widget is optional.
    await tester.pump(const Duration(seconds: 5));
    debugPrint(
      find.text('광고').evaluate().isNotEmpty
          ? 'SMOKE_AD_BANNER_VISIBLE'
          : 'SMOKE_AD_BANNER_NOT_LOADED',
    );

    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(minutes: 3)));
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

Future<void> _pumpUntilFieldCount(
  WidgetTester tester,
  int count, {
  Duration timeout = const Duration(seconds: 60),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.byType(TextFormField).evaluate().length >= count) return;
  }
  debugPrint('VISIBLE_TEXTS:${_visibleTexts(tester).join('|')}');
  expect(find.byType(TextFormField), findsAtLeastNWidgets(count));
}
