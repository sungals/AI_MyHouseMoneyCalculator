import '../entities/loan_interest_input.dart';
import '../entities/loan_interest_result.dart';

class LoanInterestCalculator {
  LoanInterestResult calculate(LoanInterestInput input) {
    final monthlyInterest =
        (input.loanAmount * (input.interestRate / 100) / 12).round();
    final totalInterest = monthlyInterest * input.months;

    return LoanInterestResult(
      monthlyInterest: monthlyInterest,
      totalInterest: totalInterest,
      loanAmount: input.loanAmount,
      months: input.months,
    );
  }
}
