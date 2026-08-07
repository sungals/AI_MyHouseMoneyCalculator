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
      summaryText: ContractRenewalSummary.renewalClaimIncreaseLimitApplied,
    );
  }
}
