import '../constants/app_constants.dart';
import 'validation_error.dart';

class Validators {
  Validators._();

  // ---- 신규 API: 코드 반환 ----

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

  // ---- 구형 API: 한글 메시지 반환 ----
  // FormFieldValidator<String> tear-off로 38곳에서 쓰이고 있어 제거할 수 없다.
  // Phase 1이 호출부를 (v) => ...Code(v)?.localize(context) 로 옮긴 뒤 삭제한다.

  @Deprecated('requiredAmountCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? requiredAmount(String? value) {
    if (value == null || value.trim().isEmpty) return '금액을 입력해 주세요.';
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount < 0) return '올바른 금액을 입력해 주세요.';
    return null;
  }

  @Deprecated('interestRateCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? interestRate(String? value) {
    if (value == null || value.trim().isEmpty) return '금리를 입력해 주세요.';
    final rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > AppConstants.maxInterestRate) {
      return '금리는 0 이상 ${AppConstants.maxInterestRate} 이하로 입력해 주세요.';
    }
    return null;
  }

  @Deprecated('monthsCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? months(String? value) {
    if (value == null || value.trim().isEmpty) return '거주 기간을 입력해 주세요.';
    final m = int.tryParse(value);
    if (m == null || m < AppConstants.minMonths || m > AppConstants.maxMonths) {
      return '거주 기간은 ${AppConstants.minMonths}~${AppConstants.maxMonths}개월로 입력해 주세요.';
    }
    return null;
  }

  @Deprecated('loanNotExceedDepositCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? loanNotExceedDeposit(int loan, int deposit) {
    if (loan > deposit) return '대출금은 전세 보증금보다 클 수 없습니다.';
    return null;
  }
}
