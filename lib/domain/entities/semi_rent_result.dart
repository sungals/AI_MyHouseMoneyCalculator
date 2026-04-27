class SemiRentResult {
  final int reducedDeposit;
  final int fairMonthlyRent;
  final int actualMonthlyRent;
  final int monthlyDifference;
  final int totalDifference;
  final String summaryText;
  final bool isOverpriced;

  const SemiRentResult({
    required this.reducedDeposit,
    required this.fairMonthlyRent,
    required this.actualMonthlyRent,
    required this.monthlyDifference,
    required this.totalDifference,
    required this.summaryText,
    required this.isOverpriced,
  });
}
