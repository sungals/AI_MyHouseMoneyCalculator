import '../entities/semi_rent_input.dart';
import '../entities/semi_rent_result.dart';

class SemiRentCalculator {
  SemiRentResult calculate(SemiRentInput input) {
    final reducedDeposit = input.baseJeonseDeposit - input.convertedDeposit;
    final fairMonthlyRent =
        (reducedDeposit * (input.conversionRate / 100) / 12).round();
    final actualMonthlyRent = input.monthlyRent;
    final monthlyDifference = actualMonthlyRent - fairMonthlyRent;
    final totalDifference = monthlyDifference * input.months;
    final isOverpriced = monthlyDifference > 0;

    final summaryText = monthlyDifference > 0
        ? SemiRentSummary.actualRentHigherThanFairRent
        : monthlyDifference < 0
            ? SemiRentSummary.actualRentLowerThanFairRent
            : SemiRentSummary.actualRentEqualsFairRent;

    return SemiRentResult(
      reducedDeposit: reducedDeposit,
      fairMonthlyRent: fairMonthlyRent,
      actualMonthlyRent: actualMonthlyRent,
      monthlyDifference: monthlyDifference,
      totalDifference: totalDifference,
      summaryText: summaryText,
      isOverpriced: isOverpriced,
    );
  }
}
