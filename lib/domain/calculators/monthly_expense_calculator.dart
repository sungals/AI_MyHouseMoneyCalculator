import '../entities/monthly_expense_input.dart';
import '../entities/monthly_expense_result.dart';

class MonthlyExpenseCalculator {
  MonthlyExpenseResult calculate(MonthlyExpenseInput input) {
    final breakdown = {
      MonthlyExpenseCategory.housing: input.housing,
      MonthlyExpenseCategory.maintenance: input.maintenance,
      MonthlyExpenseCategory.communication: input.communication,
      MonthlyExpenseCategory.transportation: input.transportation,
      MonthlyExpenseCategory.insurance: input.insurance,
      MonthlyExpenseCategory.subscription: input.subscription,
      MonthlyExpenseCategory.food: input.food,
      MonthlyExpenseCategory.other: input.other,
    };

    final totalMonthly = breakdown.values.fold(0, (sum, v) => sum + v);
    final totalAnnual = totalMonthly * 12;

    return MonthlyExpenseResult(
      totalMonthly: totalMonthly,
      totalAnnual: totalAnnual,
      breakdown: breakdown,
    );
  }
}
