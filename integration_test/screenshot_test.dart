import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:house_money_calculator/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture_screenshots', (tester) async {
    tester.testTextInput.register();

    await Hive.initFlutter();
    final box = await Hive.openBox('app_settings');
    await box.put('onboarding_done', true);
    await box.put('login_skipped', true);

    app.main();
    await tester.pump(const Duration(seconds: 3));

    final docsDir = await getApplicationDocumentsDirectory();
    final screensDir = Directory('${docsDir.path}/screenshots');
    await screensDir.create(recursive: true);
    debugPrint('SCREENSHOTS_DIR:${screensDir.path}');

    Future<void> markSnap(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      debugPrint('SNAP:$name');
      await tester.pump(const Duration(milliseconds: 1500));
    }

    Future<void> go() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> tapCalc() async {
      await tester.ensureVisible(find.text('계산하기'));
      await go();
      await tester.tap(find.text('계산하기'));
      await tester.pumpAndSettle();
    }

    // ── 홈 화면 ──
    await markSnap('01_home');

    // ── 전세 vs 월세 비교 ──
    await tester.tap(find.text('전세 vs 월세 비교'));
    await go();

    await tester.enterText(find.byType(TextFormField).at(0), '300000000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(1), '200000000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(2), '3.5');
    await go();
    await tester.enterText(find.byType(TextFormField).at(3), '10000000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(4), '900000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(5), '100000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(6), '24');
    await go();

    await tapCalc();
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -600));
    await go();
    await markSnap('02_rent_compare');

    await tester.pageBack();
    await go();

    // ── 대출이자 계산 ──
    await tester.tap(find.text('대출이자 계산'));
    await go();
    await tester.enterText(find.byType(TextFormField).at(0), '200000000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(1), '4.5');
    await go();
    await tester.enterText(find.byType(TextFormField).at(2), '36');
    await go();
    await tapCalc();
    await markSnap('03_loan_interest');

    await tester.pageBack();
    await go();

    // ── 월 고정비 계산 ──
    await tester.tap(find.text('월 고정비 계산'));
    await go();
    await tester.enterText(find.byType(TextFormField).at(0), '900000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(1), '120000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(2), '80000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(3), '150000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(4), '200000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(5), '50000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(6), '400000');
    await go();
    await tapCalc();
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -600));
    await go();
    await markSnap('04_monthly_expense');

    await tester.pageBack();
    await go();

    // ── 연말정산 세액공제 ──
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -150));
    await go();
    await tester.tap(find.text('연말정산 세액공제'));
    await go();
    await tester.enterText(find.byType(TextFormField).at(0), '50000000');
    await go();
    await tester.enterText(find.byType(TextFormField).at(1), '900000');
    await go();
    await tapCalc();
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -400));
    await go();
    await markSnap('05_tax_deduction');

    debugPrint('DONE');
  });
}
