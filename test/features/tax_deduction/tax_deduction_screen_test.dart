import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/utils/money_formatter.dart';
import 'package:house_money_calculator/features/tax_deduction/tax_deduction_screen.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

/// 화면을 지역화 델리게이트와 함께 띄우고, 단언에 쓸 [AppLocalizations]를 돌려준다.
Future<AppLocalizations> _pumpScreen(WidgetTester tester, Locale locale) async {
  late AppLocalizations l10n;

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const TaxDeductionScreen();
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return l10n;
}

/// 총급여 / 월세 / 연간 원리금 상환액을 채우고 계산을 실행한다.
Future<void> _calculate(
  WidgetTester tester,
  AppLocalizations l10n, {
  required String salary,
  required String monthlyRent,
  required String repayment,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), salary);
  await tester.enterText(fields.at(1), monthlyRent);
  await tester.enterText(fields.at(2), repayment);

  final button = find.text(l10n.taxDeductionCalculate);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('총급여가 7천만원을 넘어도 전세대출 절세액이 있으면 절세 가능 금액을 함께 알린다', (tester) async {
    final l10n = await _pumpScreen(tester, const Locale('ko'));

    await _calculate(
      tester,
      l10n,
      salary: '80000000',
      monthlyRent: '500000',
      repayment: '4000000',
    );

    // 상환액 400만원 × 40% = 160만원 소득공제, 기본 세율 15% → 24만원 절세.
    const expectedSaving = 240000;

    // 월세 세액공제만 불가하다는 문구만 뜨면 아래 절세액 행과 앞뒤가 맞지 않는다.
    expect(find.text(l10n.taxDeductionMessageIncomeTooHigh), findsNothing);
    expect(find.text(l10n.taxDeductionEligibleAnnualRentLabel), findsNothing);
    expect(find.text(l10n.taxDeductionLoanResultSection), findsOneWidget);
    expect(
      find.text(l10n.taxDeductionMessageIncomeTooHighWithLoan(
        MoneyFormatter.formatWithWon(expectedSaving),
      )),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('총급여가 7천만원을 넘고 다른 공제도 없으면 월세 공제 불가 문구만 보여준다', (tester) async {
    final l10n = await _pumpScreen(tester, const Locale('ko'));

    await _calculate(
      tester,
      l10n,
      salary: '80000000',
      monthlyRent: '500000',
      repayment: '0',
    );

    expect(find.text(l10n.taxDeductionMessageIncomeTooHigh), findsOneWidget);
    // 공제율이 0%이므로 '공제 대상 연 월세'를 노출하면 공제되는 것처럼 읽힌다.
    expect(
      find.text(l10n.taxDeductionEligibleAnnualRentLabel),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('월세 공제 대상이면 공제율과 세액공제액을 표시한다', (tester) async {
    final l10n = await _pumpScreen(tester, const Locale('ko'));

    await _calculate(
      tester,
      l10n,
      salary: '50000000',
      monthlyRent: '500000',
      repayment: '0',
    );

    expect(find.text(l10n.taxDeductionRentRateRowLabel), findsOneWidget);
    expect(
      find.text(l10n.taxDeductionEligibleAnnualRentLabel),
      findsOneWidget,
    );
    expect(find.text(l10n.taxDeductionRentTaxCreditLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('en 로케일에서 한글 없이 화면이 그려진다', (tester) async {
    final l10n = await _pumpScreen(tester, const Locale('en'));

    expect(find.text(l10n.taxDeductionTitle), findsOneWidget);
    expect(find.text(l10n.taxDeductionIncomeSection), findsOneWidget);
    expect(find.text(l10n.taxDeductionCalculate), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
