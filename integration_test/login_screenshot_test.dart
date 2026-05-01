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
    await box.delete('login_skipped'); // 로그인 화면이 뜨도록 강제

    app.main();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    debugPrint('SNAP:00_login');
    await tester.pump(const Duration(milliseconds: 1500));

    debugPrint('DONE');
  });
}
