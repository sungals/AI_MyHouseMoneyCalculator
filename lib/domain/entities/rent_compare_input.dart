class RentCompareInput {
  final int jeonseDeposit;
  final int jeonseLoan;
  final double interestRate;
  final int monthlyRentDeposit;
  final int monthlyRent;
  final int maintenanceFee;
  final int months;
  final double depositInterestRate;

  const RentCompareInput({
    required this.jeonseDeposit,
    required this.jeonseLoan,
    required this.interestRate,
    required this.monthlyRentDeposit,
    required this.monthlyRent,
    required this.maintenanceFee,
    required this.months,
    this.depositInterestRate = 3.5,
  });
}
