import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculators/monthly_expense_calculator.dart';
import '../../domain/entities/monthly_expense_input.dart';
import '../../domain/entities/monthly_expense_result.dart';

final monthlyExpenseControllerProvider =
    StateNotifierProvider<MonthlyExpenseController, MonthlyExpenseResult?>(
  (ref) => MonthlyExpenseController(),
);

class MonthlyExpenseController extends StateNotifier<MonthlyExpenseResult?> {
  final _calculator = MonthlyExpenseCalculator();

  MonthlyExpenseController() : super(null);

  void calculate(MonthlyExpenseInput input) {
    state = _calculator.calculate(input);
  }

  void reset() => state = null;
}
