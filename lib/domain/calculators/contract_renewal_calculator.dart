import '../entities/contract_renewal_input.dart';
import '../entities/contract_renewal_result.dart';

class ContractRenewalCalculator {
  ContractRenewalResult calculate(ContractRenewalInput input) {
    final multiplier = 1 + (input.increaseRate / 100);
    final maxDeposit = (input.currentDeposit * multiplier).round();
    final maxMonthlyRent = (input.currentMonthlyRent * multiplier).round();
    final depositIncrease = maxDeposit - input.currentDeposit;
    final monthlyRentIncrease = maxMonthlyRent - input.currentMonthlyRent;

    return ContractRenewalResult(
      currentDeposit: input.currentDeposit,
      currentMonthlyRent: input.currentMonthlyRent,
      increaseRate: input.increaseRate,
      maxDeposit: maxDeposit,
      maxMonthlyRent: maxMonthlyRent,
      depositIncrease: depositIncrease,
      monthlyRentIncrease: monthlyRentIncrease,
      summaryText:
          '갱신청구권 행사 시 ${input.increaseRate.toStringAsFixed(1)}% 상한 기준으로 '
          '보증금은 최대 ${_formatWon(maxDeposit)}, 월세는 최대 ${_formatWon(maxMonthlyRent)}까지 계산됩니다.',
    );
  }

  String _formatWon(int amount) {
    final formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formatted원';
  }
}
