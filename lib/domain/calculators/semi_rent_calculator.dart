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
        ? '입력한 월세는 전환율 기준보다 월 ${_formatWon(monthlyDifference)} 높아요.\n${input.months}개월 기준 약 ${_formatWon(totalDifference.abs())} 차이입니다.'
        : monthlyDifference < 0
            ? '입력한 월세는 전환율 기준보다 월 ${_formatWon(monthlyDifference.abs())} 낮아요.\n${input.months}개월 기준 약 ${_formatWon(totalDifference.abs())} 유리합니다.'
            : '입력한 월세가 전환율 기준과 동일해요.';

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

  String _formatWon(int amount) {
    final formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formatted원';
  }
}
