import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? requiredAmount(String? value) {
    if (value == null || value.trim().isEmpty) return '금액을 입력해 주세요.';
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount < 0) return '올바른 금액을 입력해 주세요.';
    return null;
  }

  static String? interestRate(String? value) {
    if (value == null || value.trim().isEmpty) return '금리를 입력해 주세요.';
    final rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > AppConstants.maxInterestRate) {
      return '금리는 0 이상 ${AppConstants.maxInterestRate} 이하로 입력해 주세요.';
    }
    return null;
  }

  static String? months(String? value) {
    if (value == null || value.trim().isEmpty) return '거주 기간을 입력해 주세요.';
    final m = int.tryParse(value);
    if (m == null || m < AppConstants.minMonths || m > AppConstants.maxMonths) {
      return '거주 기간은 ${AppConstants.minMonths}~${AppConstants.maxMonths}개월로 입력해 주세요.';
    }
    return null;
  }

  static String? loanNotExceedDeposit(int loan, int deposit) {
    if (loan > deposit) return '대출금은 전세 보증금보다 클 수 없습니다.';
    return null;
  }
}
