class MonthlyExpenseResult {
  final int totalMonthly;
  final int totalAnnual;
  final Map<String, int> breakdown;

  const MonthlyExpenseResult({
    required this.totalMonthly,
    required this.totalAnnual,
    required this.breakdown,
  });
}
