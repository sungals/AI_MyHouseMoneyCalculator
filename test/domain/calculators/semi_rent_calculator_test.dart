import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/semi_rent_calculator.dart';
import 'package:house_money_calculator/domain/entities/semi_rent_input.dart';
import 'package:house_money_calculator/domain/entities/semi_rent_result.dart';

void main() {
  late SemiRentCalculator calculator;

  setUp(() => calculator = SemiRentCalculator());

  group('SemiRentCalculator', () {
    test('월세가 전환율보다 높을 때 isOverpriced는 true', () {
      // Arrange - 기준 5억, 전환 2억, 전환율 5%
      // 줄어든 보증금: 5억 - 2억 = 3억
      // 적정 월세: 3억 * 5% / 12 = 1,250,000원
      // 실제 월세: 1,500,000원 → 과다
      const input = SemiRentInput(
        baseJeonseDeposit: 500000000,
        convertedDeposit: 200000000,
        monthlyRent: 1500000,
        conversionRate: 5.0,
        maintenanceFee: 0,
        months: 24,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.reducedDeposit, equals(300000000));
      expect(result.fairMonthlyRent, equals(1250000));
      expect(result.monthlyDifference, equals(250000));
      expect(result.isOverpriced, isTrue);
      expect(result.summaryText, isA<SemiRentSummary>());
      expect(result.summaryText, SemiRentSummary.actualRentHigherThanFairRent);
    });

    test('월세가 전환율보다 낮을 때 isOverpriced는 false', () {
      // Arrange
      const input = SemiRentInput(
        baseJeonseDeposit: 500000000,
        convertedDeposit: 200000000,
        monthlyRent: 1000000,
        conversionRate: 5.0,
        maintenanceFee: 0,
        months: 24,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.monthlyDifference, lessThan(0));
      expect(result.isOverpriced, isFalse);
      expect(result.summaryText, SemiRentSummary.actualRentLowerThanFairRent);
    });

    test('총 차이는 월 차이 * 개월 수와 같다', () {
      // Arrange
      const input = SemiRentInput(
        baseJeonseDeposit: 300000000,
        convertedDeposit: 100000000,
        monthlyRent: 1000000,
        conversionRate: 4.0,
        maintenanceFee: 0,
        months: 12,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.totalDifference, equals(result.monthlyDifference * 12));
    });
  });
}
