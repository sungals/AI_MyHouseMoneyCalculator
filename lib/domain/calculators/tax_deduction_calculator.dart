import '../entities/tax_deduction_input.dart';
import '../entities/tax_deduction_result.dart';

class TaxDeductionCalculator {
  static const int _rentDeductionLimit = 10000000;
  static const int _loanDeductionLimit = 4000000;
  static const double _loanDeductionRate = 0.4;
  static const int _highIncomeSalary = 70000000;
  static const int _midIncomeSalary = 55000000;

  TaxDeductionResult calculate(TaxDeductionInput input) {
    final rentDeductionRate = _getRentDeductionRate(input.annualSalary);

    final annualRentTotal = input.monthlyRent * 12;
    final eligibleAnnualRent = annualRentTotal.clamp(0, _rentDeductionLimit);
    final rentTaxCredit =
        (eligibleAnnualRent * rentDeductionRate / 100).round();

    final eligibleRepayment =
        input.annualLoanRepayment.clamp(0, _loanDeductionLimit);
    final incomeDeductionAmount =
        (eligibleRepayment * _loanDeductionRate).round();
    final loanTaxSaving =
        (incomeDeductionAmount * input.incomeTaxRate / 100).round();

    final totalTaxBenefit = rentTaxCredit + loanTaxSaving;

    final message = _buildMessage(
      rentDeductionRate: rentDeductionRate,
      hasRent: input.monthlyRent > 0,
      totalTaxBenefit: totalTaxBenefit,
    );

    return TaxDeductionResult(
      rentDeductionRate: rentDeductionRate,
      eligibleAnnualRent: eligibleAnnualRent,
      rentTaxCredit: rentTaxCredit,
      eligibleRepayment: eligibleRepayment,
      incomeDeductionAmount: incomeDeductionAmount,
      loanTaxSaving: loanTaxSaving,
      totalTaxBenefit: totalTaxBenefit,
      message: message,
    );
  }

  int _getRentDeductionRate(int annualSalary) {
    if (annualSalary <= _midIncomeSalary) return 17;
    if (annualSalary <= _highIncomeSalary) return 15;
    return 0;
  }

  TaxDeductionMessage _buildMessage({
    required int rentDeductionRate,
    required bool hasRent,
    required int totalTaxBenefit,
  }) {
    if (rentDeductionRate == 0 && hasRent) {
      return TaxDeductionMessage.incomeTooHighForRentTaxCredit;
    }
    if (totalTaxBenefit > 0) {
      return TaxDeductionMessage.hasTaxBenefit;
    }
    return TaxDeductionMessage.noDeductionInput;
  }
}
