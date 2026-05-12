import '../entities/dsr_dti_input.dart';
import '../entities/dsr_dti_result.dart';

class DsrDtiCalculator {
  DsrDtiResult calculate(DsrDtiInput input) {
    if (input.annualIncome == 0) {
      return const DsrDtiResult(dsr: 0, dti: 0);
    }

    return DsrDtiResult(
      dti: input.housingDebtAnnualPayment / input.annualIncome * 100,
      dsr: (input.housingDebtAnnualPayment + input.otherDebtAnnualPayment) /
          input.annualIncome *
          100,
    );
  }
}
