import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/constants/app_constants.dart';
import 'package:house_money_calculator/core/utils/validation_error.dart';
import 'package:house_money_calculator/core/utils/validators.dart';

void main() {
  group('requiredAmountCode', () {
    test('빈 값은 amountRequired', () {
      expect(Validators.requiredAmountCode(''), ValidationError.amountRequired);
      expect(Validators.requiredAmountCode(null), ValidationError.amountRequired);
      expect(Validators.requiredAmountCode('   '), ValidationError.amountRequired);
    });

    test('숫자가 아니면 amountInvalid', () {
      expect(Validators.requiredAmountCode('abc'), ValidationError.amountInvalid);
    });

    test('음수는 amountInvalid', () {
      expect(Validators.requiredAmountCode('-1'), ValidationError.amountInvalid);
    });

    test('쉼표가 있는 정상 금액은 null', () {
      expect(Validators.requiredAmountCode('1,000,000'), isNull);
    });
  });

  group('interestRateCode', () {
    test('빈 값은 rateRequired', () {
      expect(Validators.interestRateCode(''), ValidationError.rateRequired);
    });

    test('상한 초과는 rateOutOfRange', () {
      expect(
        Validators.interestRateCode('${AppConstants.maxInterestRate + 1}'),
        ValidationError.rateOutOfRange,
      );
    });

    test('음수는 rateOutOfRange', () {
      expect(Validators.interestRateCode('-1'), ValidationError.rateOutOfRange);
    });

    test('정상 금리는 null', () {
      expect(Validators.interestRateCode('3.5'), isNull);
    });
  });

  group('monthsCode', () {
    test('빈 값은 monthsRequired', () {
      expect(Validators.monthsCode(''), ValidationError.monthsRequired);
    });

    test('상한 초과는 monthsOutOfRange', () {
      expect(
        Validators.monthsCode('${AppConstants.maxMonths + 1}'),
        ValidationError.monthsOutOfRange,
      );
    });

    test('하한 미만은 monthsOutOfRange', () {
      expect(
        Validators.monthsCode('${AppConstants.minMonths - 1}'),
        ValidationError.monthsOutOfRange,
      );
    });

    test('정상 개월수는 null', () {
      expect(Validators.monthsCode('${AppConstants.minMonths}'), isNull);
    });
  });

  group('loanNotExceedDepositCode', () {
    test('대출금이 크면 loanExceedsDeposit', () {
      expect(Validators.loanNotExceedDepositCode(200, 100),
          ValidationError.loanExceedsDeposit);
    });

    test('같거나 작으면 null', () {
      expect(Validators.loanNotExceedDepositCode(100, 100), isNull);
      expect(Validators.loanNotExceedDepositCode(50, 100), isNull);
    });
  });

  group('구형 API 병존', () {
    test('deprecated 메서드는 여전히 String을 반환한다', () {
      // ignore: deprecated_member_use_from_same_package
      final result = Validators.requiredAmount('');
      expect(result, isA<String>());
    });

    test('requiredAmount: 신구 API의 판정이 일치한다', () {
      final inputs = [
        '',           // empty
        'abc',        // non-numeric
        '-1',         // negative
        '0',          // boundary: zero is valid
        '1,000,000',  // valid with comma
      ];
      for (final input in inputs) {
        // ignore: deprecated_member_use_from_same_package
        final legacyFailed = Validators.requiredAmount(input) != null;
        final codeFailed = Validators.requiredAmountCode(input) != null;
        expect(codeFailed, legacyFailed,
            reason: 'requiredAmount 입력 "$input"에서 판정이 갈렸다');
      }
    });

    test('interestRate: 신구 API의 판정이 일치한다', () {
      final inputs = [
        '',                                      // empty
        '  ',                                    // whitespace
        null,                                    // null
        'abc',                                   // non-numeric
        '-0.1',                                  // negative
        '0',                                     // boundary: zero is valid
        '3.5',                                   // normal value
        AppConstants.maxInterestRate.toString(), // at max
        '${AppConstants.maxInterestRate + 0.1}', // above max
        '100',                                   // way above max
      ];
      for (final input in inputs) {
        // ignore: deprecated_member_use_from_same_package
        final legacyFailed = Validators.interestRate(input) != null;
        final codeFailed = Validators.interestRateCode(input) != null;
        expect(codeFailed, legacyFailed,
            reason: 'interestRate 입력 "$input"에서 판정이 갈렸다');
      }
    });

    test('months: 신구 API의 판정이 일치한다', () {
      final inputs = [
        '',                                  // empty
        ' ',                                 // whitespace
        null,                                // null
        'abc',                               // non-numeric
        '0',                                 // below min
        AppConstants.minMonths.toString(),   // at min
        '1',                                 // at min (redundant)
        '600',                               // at max
        '${AppConstants.maxMonths + 1}',     // above max
        '1200',                              // way above max
      ];
      for (final input in inputs) {
        // ignore: deprecated_member_use_from_same_package
        final legacyFailed = Validators.months(input) != null;
        final codeFailed = Validators.monthsCode(input) != null;
        expect(codeFailed, legacyFailed,
            reason: 'months 입력 "$input"에서 판정이 갈렸다');
      }
    });

    test('loanNotExceedDeposit: 신구 API의 판정이 일치한다', () {
      final cases = [
        (0, 0),           // equal, both zero
        (100, 100),       // equal
        (50, 100),        // loan less
        (101, 100),       // loan greater (fail case)
        (0, 100),         // zero loan
        (100, 0),         // zero deposit
      ];
      for (final (loan, deposit) in cases) {
        // ignore: deprecated_member_use_from_same_package
        final legacyFailed = Validators.loanNotExceedDeposit(loan, deposit) != null;
        final codeFailed =
            Validators.loanNotExceedDepositCode(loan, deposit) != null;
        expect(codeFailed, legacyFailed,
            reason: 'loanNotExceedDeposit($loan, $deposit)에서 판정이 갈렸다');
      }
    });
  });
}
