import '../entities/monthly_expense_input.dart';
import '../entities/monthly_expense_result.dart';

class MonthlyExpenseCalculator {
  MonthlyExpenseResult calculate(MonthlyExpenseInput input) {
    final breakdown = {
      '주거비': input.housing,
      '관리비': input.maintenance,
      '통신비': input.communication,
      '교통비': input.transportation,
      '보험료': input.insurance,
      '구독료': input.subscription,
      '식비': input.food,
      '기타': input.other,
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
