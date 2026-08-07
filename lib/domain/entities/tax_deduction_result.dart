enum TaxDeductionMessage {
  incomeTooHighForRentTaxCredit,
  hasTaxBenefit,
  noDeductionInput,
}

class TaxDeductionResult {
  final int rentDeductionRate;
  final int eligibleAnnualRent;
  final int rentTaxCredit;
  final int eligibleRepayment;
  final int incomeDeductionAmount;
  final int loanTaxSaving;
  final int totalTaxBenefit;
  final TaxDeductionMessage message;

  const TaxDeductionResult({
    required this.rentDeductionRate,
    required this.eligibleAnnualRent,
    required this.rentTaxCredit,
    required this.eligibleRepayment,
    required this.incomeDeductionAmount,
    required this.loanTaxSaving,
    required this.totalTaxBenefit,
    required this.message,
  });
}
