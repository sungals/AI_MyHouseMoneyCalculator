import '../entities/rent_compare_input.dart';
import '../entities/rent_compare_result.dart';

class RentCompareCalculator {
  RentCompareResult calculate(RentCompareInput input) {
    final monthlyInterest =
        (input.jeonseLoan * (input.interestRate / 100) / 12).round();
    final jeonseMonthlyCost = monthlyInterest + input.maintenanceFee;

    final rentMonthlyCost = input.monthlyRent + input.maintenanceFee;

    final depositDiff = input.jeonseDeposit - input.monthlyRentDeposit;
    // 월세를 선택하면 전세 대비 덜 묶이는 보증금을 예금/투자할 수 있다고 보고
    // 그 기회수익을 월세 비용에서 차감해 보정한다.
    final opportunityCostMonthly =
        (depositDiff * (input.depositInterestRate / 100) / 12).round();

    final adjustedRentMonthlyCost = rentMonthlyCost - opportunityCostMonthly;

    final monthlyDifference = adjustedRentMonthlyCost - jeonseMonthlyCost;
    final totalDifference = monthlyDifference * input.months;
    // 양수면 보정 월세 비용이 전세 비용보다 크다는 뜻이므로 전세가 유리하다.
    final isJeonseAdvantageous = monthlyDifference >= 0;

    final recommendationText = monthlyDifference > 0
        ? '전세가 월 ${_formatWon(monthlyDifference)} 유리해요.'
        : monthlyDifference < 0
            ? '월세가 월 ${_formatWon(monthlyDifference.abs())} 유리해요.'
            : '전세와 월세의 월 비용이 같아요.';

    return RentCompareResult(
      jeonseMonthlyCost: jeonseMonthlyCost,
      rentMonthlyCost: rentMonthlyCost,
      opportunityCostMonthly: opportunityCostMonthly,
      adjustedRentMonthlyCost: adjustedRentMonthlyCost,
      monthlyDifference: monthlyDifference,
      totalDifference: totalDifference,
      recommendationText: recommendationText,
      isJeonseAdvantageous: isJeonseAdvantageous,
    );
  }

  String _formatWon(int amount) {
    final formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formatted원';
  }
}
