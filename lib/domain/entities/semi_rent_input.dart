class SemiRentInput {
  final int baseJeonseDeposit;
  final int convertedDeposit;
  final int monthlyRent;
  final double conversionRate;
  final int maintenanceFee;
  final int months;

  const SemiRentInput({
    required this.baseJeonseDeposit,
    required this.convertedDeposit,
    required this.monthlyRent,
    required this.conversionRate,
    required this.maintenanceFee,
    required this.months,
  });
}
