enum ContractRenewalSummary {
  renewalClaimIncreaseLimitApplied,
}

class ContractRenewalResult {
  final int currentDeposit;
  final int currentMonthlyRent;
  final double increaseRate;
  final int maxDeposit;
  final int maxMonthlyRent;
  final int depositIncrease;
  final int monthlyRentIncrease;
  final ContractRenewalSummary summaryText;

  const ContractRenewalResult({
    required this.currentDeposit,
    required this.currentMonthlyRent,
    required this.increaseRate,
    required this.maxDeposit,
    required this.maxMonthlyRent,
    required this.depositIncrease,
    required this.monthlyRentIncrease,
    required this.summaryText,
  });
}
