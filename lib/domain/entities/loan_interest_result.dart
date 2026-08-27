import 'loan_interest_input.dart';

class LoanInterestResult {
  final int monthlyInterest;
  final int monthlyPayment;
  final int firstMonthPayment;
  final int lastMonthPayment;
  final int totalInterest;
  final int totalPayment;
  final int loanAmount;
  final int months;
  final LoanInterestRepaymentMethod repaymentMethod;

  const LoanInterestResult({
    required this.monthlyInterest,
    required this.monthlyPayment,
    required this.firstMonthPayment,
    required this.lastMonthPayment,
    required this.totalInterest,
    required this.totalPayment,
    required this.loanAmount,
    required this.months,
    required this.repaymentMethod,
  });
}
