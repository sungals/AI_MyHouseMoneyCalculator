import 'dart:math' as math;

import '../entities/loan_interest_input.dart';
import '../entities/loan_interest_result.dart';

class LoanInterestCalculator {
  LoanInterestResult calculate(LoanInterestInput input) {
    final monthlyRate = input.interestRate / 100 / 12;

    return switch (input.repaymentMethod) {
      LoanInterestRepaymentMethod.interestOnly =>
        _calculateInterestOnly(input, monthlyRate),
      LoanInterestRepaymentMethod.equalPrincipalAndInterest =>
        _calculateEqualPrincipalAndInterest(input, monthlyRate),
      LoanInterestRepaymentMethod.equalPrincipal =>
        _calculateEqualPrincipal(input, monthlyRate),
    };
  }

  LoanInterestResult _calculateInterestOnly(
    LoanInterestInput input,
    double monthlyRate,
  ) {
    final monthlyInterest = (input.loanAmount * monthlyRate).round();
    final totalInterest = monthlyInterest * input.months;
    final totalPayment = input.loanAmount + totalInterest;

    return LoanInterestResult(
      monthlyInterest: monthlyInterest,
      monthlyPayment: monthlyInterest,
      firstMonthPayment: monthlyInterest,
      lastMonthPayment: monthlyInterest,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      loanAmount: input.loanAmount,
      months: input.months,
      repaymentMethod: input.repaymentMethod,
    );
  }

  LoanInterestResult _calculateEqualPrincipalAndInterest(
    LoanInterestInput input,
    double monthlyRate,
  ) {
    final monthlyPayment = monthlyRate == 0
        ? (input.loanAmount / input.months).round()
        : (input.loanAmount *
                monthlyRate *
                math.pow(1 + monthlyRate, input.months) /
                (math.pow(1 + monthlyRate, input.months) - 1))
            .round();
    final totalPayment = monthlyPayment * input.months;
    final totalInterest = totalPayment - input.loanAmount;

    return LoanInterestResult(
      monthlyInterest: (input.loanAmount * monthlyRate).round(),
      monthlyPayment: monthlyPayment,
      firstMonthPayment: monthlyPayment,
      lastMonthPayment: monthlyPayment,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      loanAmount: input.loanAmount,
      months: input.months,
      repaymentMethod: input.repaymentMethod,
    );
  }

  LoanInterestResult _calculateEqualPrincipal(
    LoanInterestInput input,
    double monthlyRate,
  ) {
    final monthlyPrincipal = input.loanAmount / input.months;
    var totalPayment = 0;
    var firstMonthPayment = 0;
    var lastMonthPayment = 0;

    for (var month = 0; month < input.months; month += 1) {
      final remainingPrincipal = input.loanAmount - (monthlyPrincipal * month);
      final payment =
          (monthlyPrincipal + remainingPrincipal * monthlyRate).round();
      if (month == 0) firstMonthPayment = payment;
      if (month == input.months - 1) lastMonthPayment = payment;
      totalPayment += payment;
    }

    return LoanInterestResult(
      monthlyInterest: (input.loanAmount * monthlyRate).round(),
      monthlyPayment: firstMonthPayment,
      firstMonthPayment: firstMonthPayment,
      lastMonthPayment: lastMonthPayment,
      totalInterest: totalPayment - input.loanAmount,
      totalPayment: totalPayment,
      loanAmount: input.loanAmount,
      months: input.months,
      repaymentMethod: input.repaymentMethod,
    );
  }
}
