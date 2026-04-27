class RentCompareResult {
  final int jeonseMonthlyCost;
  final int rentMonthlyCost;
  final int monthlyDifference;
  final int totalDifference;
  final String recommendationText;
  final bool isJeonseAdvantageous;

  const RentCompareResult({
    required this.jeonseMonthlyCost,
    required this.rentMonthlyCost,
    required this.monthlyDifference,
    required this.totalDifference,
    required this.recommendationText,
    required this.isJeonseAdvantageous,
  });
}
