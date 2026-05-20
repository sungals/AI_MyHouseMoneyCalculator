import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:house_money_calculator/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture_login_screenshot', (tester) async {
    await Hive.initFlutter();
    final box = await Hive.openBox('app_settings');
    await box.put('onboarding_done', true);
    await box.put('login_skipped', true); // 스테일 값이 있어도 로그인으로 가야 함

    await app.bootstrap(
      initializeNotifications: false,
      cleanupStalePushToken: false,
      clearPersistedSession: true,
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));

    debugPrint('SNAP:00_login');
    await tester.pump(const Duration(milliseconds: 1500));

    debugPrint('DONE');
  });
}
