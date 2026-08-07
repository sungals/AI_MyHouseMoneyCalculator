import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/monthly_expense_calculator.dart';
import 'package:house_money_calculator/domain/entities/monthly_expense_input.dart';
import 'package:house_money_calculator/domain/entities/monthly_expense_result.dart';

void main() {
  late MonthlyExpenseCalculator calculator;

  setUp(() => calculator = MonthlyExpenseCalculator());

  group('MonthlyExpenseCalculator', () {
    test('모든 항목의 합산이 정확하다', () {
      // Arrange
      const input = MonthlyExpenseInput(
        housing: 800000,
        maintenance: 100000,
        communication: 50000,
        transportation: 120000,
        insurance: 150000,
        subscription: 30000,
        food: 400000,
        other: 200000,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.totalMonthly, equals(1850000));
    });

    test('연간 합계는 월 합계 * 12', () {
      // Arrange
      const input = MonthlyExpenseInput(
        housing: 700000,
        maintenance: 0,
        communication: 0,
        transportation: 0,
        insurance: 0,
        subscription: 0,
        food: 0,
        other: 0,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.totalAnnual, equals(result.totalMonthly * 12));
    });

    test('0원 항목이 있어도 정상 계산된다', () {
      // Arrange
      const input = MonthlyExpenseInput(
        housing: 1000000,
        maintenance: 0,
        communication: 0,
        transportation: 0,
        insurance: 0,
        subscription: 0,
        food: 0,
        other: 0,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.totalMonthly, equals(1000000));
    });

    test('breakdown에 8개 항목이 모두 포함된다', () {
      // Arrange
      const input = MonthlyExpenseInput(
        housing: 1,
        maintenance: 2,
        communication: 3,
        transportation: 4,
        insurance: 5,
        subscription: 6,
        food: 7,
        other: 8,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.breakdown, isA<Map<MonthlyExpenseCategory, int>>());
      expect(result.breakdown.length, equals(8));
      expect(
          result.breakdown.containsKey(MonthlyExpenseCategory.housing), isTrue);
      expect(
          result.breakdown.containsKey(MonthlyExpenseCategory.other), isTrue);
    });
  });
}
