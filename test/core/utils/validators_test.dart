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
}
