// Validators 한국어 메시지 골든 스냅샷.
// ValidationError.localize(context)가 사용자에게 보이는 문구를 만든다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/constants/app_constants.dart';
import 'package:house_money_calculator/core/utils/validation_error.dart';
import 'package:house_money_calculator/core/utils/validation_error_l10n.dart';
import 'package:house_money_calculator/core/utils/validators.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

class _V {
  final String fn;
  final String? input;
  final String? expected;

  const _V(this.fn, this.input, this.expected);
}

class _L {
  final int loan;
  final int deposit;
  final String? expected;

  const _L(this.loan, this.deposit, this.expected);
}

const _cases = <_V>[
  _V('requiredAmount', '', '금액을 입력해 주세요.'),
  _V('requiredAmount', '   ', '금액을 입력해 주세요.'),
  _V('requiredAmount', null, '금액을 입력해 주세요.'),
  _V('requiredAmount', 'abc', '올바른 금액을 입력해 주세요.'),
  _V('requiredAmount', '-1', '올바른 금액을 입력해 주세요.'),
  _V('requiredAmount', '0', null),
  _V('requiredAmount', '1', null),
  _V('requiredAmount', '1,000', null),
  _V('requiredAmount', '1000', null),
  _V('requiredAmount', '99999999999', null),
  _V('interestRate', '', '금리를 입력해 주세요.'),
  _V('interestRate', '  ', '금리를 입력해 주세요.'),
  _V('interestRate', null, '금리를 입력해 주세요.'),
  _V('interestRate', 'abc', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '-0.1', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '100', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '1000', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '0', null),
  _V('interestRate', '3.5', null),
  _V('months', '', '거주 기간을 입력해 주세요.'),
  _V('months', ' ', '거주 기간을 입력해 주세요.'),
  _V('months', null, '거주 기간을 입력해 주세요.'),
  _V('months', 'abc', '거주 기간은 1~600개월로 입력해 주세요.'),
  _V('months', '0', '거주 기간은 1~600개월로 입력해 주세요.'),
  _V('months', '1200', '거주 기간은 1~600개월로 입력해 주세요.'),
  _V('months', '1', null),
  _V('months', '12', null),
  _V('months', '600', null),
];

const _loanCases = <_L>[
  _L(0, 0, null),
  _L(100, 100, null),
  _L(0, 100, null),
  _L(101, 100, '대출금은 전세 보증금보다 클 수 없습니다.'),
  _L(100, 0, '대출금은 전세 보증금보다 클 수 없습니다.'),
];

ValidationError? _code(String fn, String? input) {
  switch (fn) {
    case 'requiredAmount':
      return Validators.requiredAmountCode(input);
    case 'interestRate':
      return Validators.interestRateCode(input);
    case 'months':
      return Validators.monthsCode(input);
    default:
      throw ArgumentError('알 수 없는 검증기: $fn');
  }
}

Future<BuildContext> _koContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return captured;
}

void main() {
  group('Validators 골든 스냅샷 (한국어 메시지 고정)', () {
    for (final c in _cases) {
      testWidgets('${c.fn}(${c.input == null ? 'null' : "'${c.input}'"})',
          (tester) async {
        final context = await _koContext(tester);
        final code = _code(c.fn, c.input);
        expect(code?.localize(context), c.expected);
      });
    }

    for (final c in _loanCases) {
      testWidgets('loanNotExceedDeposit(${c.loan}, ${c.deposit})',
          (tester) async {
        final context = await _koContext(tester);
        final code =
            Validators.loanNotExceedDepositCode(c.loan, c.deposit);
        expect(code?.localize(context), c.expected);
      });
    }
  });

  group('메시지가 의존하는 상수', () {
    test('AppConstants 값이 골든 캡처 시점과 같다', () {
      expect(AppConstants.maxInterestRate, 30.0);
      expect(AppConstants.minMonths, 1);
      expect(AppConstants.maxMonths, 600);
    });
  });
}
