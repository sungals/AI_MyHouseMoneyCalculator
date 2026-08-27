import '../constants/app_constants.dart';
import 'validation_error.dart';

class Validators {
  Validators._();

  static ValidationError? requiredAmountCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.amountRequired;
    }
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount < 0) return ValidationError.amountInvalid;
    return null;
  }

  static ValidationError? interestRateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.rateRequired;
    }
    final rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > AppConstants.maxInterestRate) {
      return ValidationError.rateOutOfRange;
    }
    return null;
  }

  static ValidationError? monthsCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.monthsRequired;
    }
    final m = int.tryParse(value);
    if (m == null || m < AppConstants.minMonths || m > AppConstants.maxMonths) {
      return ValidationError.monthsOutOfRange;
    }
    return null;
  }

  static ValidationError? loanNotExceedDepositCode(int loan, int deposit) {
    if (loan > deposit) return ValidationError.loanExceedsDeposit;
    return null;
  }
}
