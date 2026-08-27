enum LoanInterestRepaymentMethod {
  interestOnly,
  equalPrincipalAndInterest,
  equalPrincipal,
}

class LoanInterestInput {
  final int loanAmount;
  final double interestRate;
  final int months;
  final LoanInterestRepaymentMethod repaymentMethod;

  const LoanInterestInput({
    required this.loanAmount,
    required this.interestRate,
    required this.months,
    this.repaymentMethod = LoanInterestRepaymentMethod.interestOnly,
  });
}
