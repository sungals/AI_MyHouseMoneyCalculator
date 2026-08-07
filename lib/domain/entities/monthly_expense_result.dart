enum MonthlyExpenseCategory {
  housing,
  maintenance,
  communication,
  transportation,
  insurance,
  subscription,
  food,
  other,
}

class MonthlyExpenseResult {
  final int totalMonthly;
  final int totalAnnual;
  final Map<MonthlyExpenseCategory, int> breakdown;

  const MonthlyExpenseResult({
    required this.totalMonthly,
    required this.totalAnnual,
    required this.breakdown,
  });
}
