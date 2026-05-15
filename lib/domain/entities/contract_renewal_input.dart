class ContractRenewalInput {
  final int currentDeposit;
  final int currentMonthlyRent;
  final double increaseRate;

  const ContractRenewalInput({
    required this.currentDeposit,
    required this.currentMonthlyRent,
    this.increaseRate = 5.0,
  });
}
