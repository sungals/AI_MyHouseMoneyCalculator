class TaxDeductionInput {
  final int annualSalary;
  final int monthlyRent;
  final int annualLoanRepayment;
  final double incomeTaxRate;

  const TaxDeductionInput({
    required this.annualSalary,
    required this.monthlyRent,
    required this.annualLoanRepayment,
    this.incomeTaxRate = 15.0,
  });
}
