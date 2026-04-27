import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculators/loan_interest_calculator.dart';
import '../../domain/entities/loan_interest_input.dart';
import '../../domain/entities/loan_interest_result.dart';

final loanInterestControllerProvider =
    StateNotifierProvider<LoanInterestController, LoanInterestResult?>(
  (ref) => LoanInterestController(),
);

class LoanInterestController extends StateNotifier<LoanInterestResult?> {
  final _calculator = LoanInterestCalculator();

  LoanInterestController() : super(null);

  void calculate(LoanInterestInput input) {
    state = _calculator.calculate(input);
  }

  void reset() => state = null;
}
