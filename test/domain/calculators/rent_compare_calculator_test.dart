import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/rent_compare_calculator.dart';
import 'package:house_money_calculator/domain/entities/rent_compare_input.dart';

void main() {
  late RentCompareCalculator calculator;

  setUp(() => calculator = RentCompareCalculator());

  group('RentCompareCalculator', () {
    test('전세가 유리한 경우 - monthlyDifference가 양수', () {
      // Arrange
      const input = RentCompareInput(
        jeonseDeposit: 300000000,
        jeonseLoan: 200000000,
        interestRate: 4.0,
        monthlyRentDeposit: 10000000,
        monthlyRent: 900000,
        maintenanceFee: 100000,
        months: 24,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      // 전세 월이자: 200,000,000 * 4% / 12 = 666,667원
      // 전세 월비용: 666,667 + 100,000 = 766,667원
      // 월세 월비용: 900,000 + 100,000 = 1,000,000원
      // 차이: 1,000,000 - 766,667 = 233,333원 (전세 유리)
      expect(result.jeonseMonthlyCost, equals(766667));
      expect(result.rentMonthlyCost, equals(1000000));
      expect(result.monthlyDifference, greaterThan(0));
      expect(result.isJeonseAdvantageous, isTrue);
      expect(result.totalDifference, equals(result.monthlyDifference * 24));
      expect(result.recommendationText, contains('전세가'));
    });

    test('월세가 유리한 경우 - monthlyDifference가 음수', () {
      // Arrange
      const input = RentCompareInput(
        jeonseDeposit: 500000000,
        jeonseLoan: 450000000,
        interestRate: 5.0,
        monthlyRentDeposit: 10000000,
        monthlyRent: 500000,
        maintenanceFee: 100000,
        months: 12,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      // 전세 월이자: 450,000,000 * 5% / 12 = 1,875,000원
      // 전세 월비용: 1,875,000 + 100,000 = 1,975,000원
      // 월세 월비용: 500,000 + 100,000 = 600,000원
      // 차이: 600,000 - 1,975,000 = -1,375,000원 (월세 유리)
      expect(result.monthlyDifference, lessThan(0));
      expect(result.isJeonseAdvantageous, isFalse);
      expect(result.recommendationText, contains('월세가'));
    });

    test('전세와 월세 비용이 동일한 경우', () {
      // Arrange - 전세 월이자 = 월세가 되도록 설정
      // 월이자: 12,000,000 * 12% / 12 = 120,000원
      // 전세비용: 120,000 + 0 = 120,000원
      // 월세비용: 120,000 + 0 = 120,000원
      const input = RentCompareInput(
        jeonseDeposit: 50000000,
        jeonseLoan: 12000000,
        interestRate: 12.0,
        monthlyRentDeposit: 0,
        monthlyRent: 120000,
        maintenanceFee: 0,
        months: 24,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.monthlyDifference, equals(0));
      expect(result.recommendationText, contains('같아요'));
    });

    test('거주 기간에 따라 총 차이가 비례해서 증가한다', () {
      // Arrange
      const input12 = RentCompareInput(
        jeonseDeposit: 300000000,
        jeonseLoan: 200000000,
        interestRate: 4.0,
        monthlyRentDeposit: 10000000,
        monthlyRent: 900000,
        maintenanceFee: 100000,
        months: 12,
      );
      const input24 = RentCompareInput(
        jeonseDeposit: 300000000,
        jeonseLoan: 200000000,
        interestRate: 4.0,
        monthlyRentDeposit: 10000000,
        monthlyRent: 900000,
        maintenanceFee: 100000,
        months: 24,
      );

      // Act
      final result12 = calculator.calculate(input12);
      final result24 = calculator.calculate(input24);

      // Assert
      expect(result24.totalDifference, equals(result12.totalDifference * 2));
    });

    test('대출이 없는 경우 전세 월비용은 관리비만', () {
      // Arrange
      const input = RentCompareInput(
        jeonseDeposit: 300000000,
        jeonseLoan: 0,
        interestRate: 4.0,
        monthlyRentDeposit: 0,
        monthlyRent: 300000,
        maintenanceFee: 100000,
        months: 12,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.jeonseMonthlyCost, equals(100000));
    });
  });
}
