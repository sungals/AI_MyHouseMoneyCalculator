import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/loan_interest_calculator.dart';
import 'package:house_money_calculator/domain/entities/loan_interest_input.dart';

void main() {
  late LoanInterestCalculator calculator;

  setUp(() => calculator = LoanInterestCalculator());

  group('LoanInterestCalculator', () {
    test('월 이자 계산이 정확하다', () {
      // Arrange - 2억 대출, 연 4.35%
      // 월 이자: 200,000,000 * 4.35% / 12 = 725,000원
      const input = LoanInterestInput(
        loanAmount: 200000000,
        interestRate: 4.35,
        months: 24,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.monthlyInterest, equals(725000));
    });

    test('총 이자는 월 이자 * 개월 수', () {
      // Arrange
      const input = LoanInterestInput(
        loanAmount: 100000000,
        interestRate: 3.0,
        months: 12,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.totalInterest, equals(result.monthlyInterest * 12));
    });

    test('원리금균등상환은 매월 같은 납입액과 총 이자를 계산한다', () {
      const input = LoanInterestInput(
        loanAmount: 100000000,
        interestRate: 3.0,
        months: 12,
        repaymentMethod: LoanInterestRepaymentMethod.equalPrincipalAndInterest,
      );

      final result = calculator.calculate(input);

      expect(result.monthlyPayment, equals(8469370));
      expect(result.firstMonthPayment, equals(result.monthlyPayment));
      expect(result.lastMonthPayment, equals(result.monthlyPayment));
      expect(result.totalInterest, equals(1632440));
      expect(result.totalPayment, equals(101632440));
    });

    test('원금균등상환은 첫 달 납입액이 마지막 달보다 크다', () {
      const input = LoanInterestInput(
        loanAmount: 12000000,
        interestRate: 12.0,
        months: 12,
        repaymentMethod: LoanInterestRepaymentMethod.equalPrincipal,
      );

      final result = calculator.calculate(input);

      expect(result.firstMonthPayment, equals(1120000));
      expect(result.lastMonthPayment, equals(1010000));
      expect(result.monthlyPayment, equals(result.firstMonthPayment));
      expect(result.totalInterest, equals(780000));
      expect(result.totalPayment, equals(12780000));
    });

    test('금리 0%이면 이자 0원', () {
      // Arrange
      const input = LoanInterestInput(
        loanAmount: 100000000,
        interestRate: 0.0,
        months: 12,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.monthlyInterest, equals(0));
      expect(result.totalInterest, equals(0));
      expect(result.totalPayment, equals(100000000));
    });

    test('result에 대출금과 기간이 보존된다', () {
      // Arrange
      const input = LoanInterestInput(
        loanAmount: 150000000,
        interestRate: 3.5,
        months: 36,
      );

      // Act
      final result = calculator.calculate(input);

      // Assert
      expect(result.loanAmount, equals(150000000));
      expect(result.months, equals(36));
    });
  });
}
