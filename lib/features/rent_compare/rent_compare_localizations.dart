import '../../core/utils/money_formatter.dart';
import '../../domain/entities/rent_compare_result.dart';

String rentCompareRecommendationText(RentCompareResult result) {
  switch (result.recommendationText) {
    case RentCompareRecommendation.jeonseAdvantageous:
      return '전세가 월 ${MoneyFormatter.formatWithWon(result.monthlyDifference)} 유리해요.';
    case RentCompareRecommendation.monthlyRentAdvantageous:
      return '월세가 월 ${MoneyFormatter.formatWithWon(result.monthlyDifference.abs())} 유리해요.';
    case RentCompareRecommendation.costsEqual:
      return '전세와 월세의 월 비용이 같아요.';
  }
}
