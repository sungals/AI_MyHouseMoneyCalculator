import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/dsr_dti_calculator.dart';
import 'package:house_money_calculator/domain/entities/dsr_dti_input.dart';

void main() {
  late DsrDtiCalculator calculator;

  setUp(() => calculator = DsrDtiCalculator());

  group('DsrDtiCalculator', () {
    test('DSR은 전체 연간 원리금 상환액을 연소득으로 나눈다', () {
      const input = DsrDtiInput(
        annualIncome: 100000000,
        housingDebtAnnualPayment: 20000000,
        otherDebtAnnualPayment: 10000000,
      );

      final result = calculator.calculate(input);

      expect(result.dsr, equals(30));
    });

    test('DTI는 주택담보대출 연간 원리금만 연소득으로 나눈다', () {
      const input = DsrDtiInput(
        annualIncome: 80000000,
        housingDebtAnnualPayment: 24000000,
        otherDebtAnnualPayment: 8000000,
      );

      final result = calculator.calculate(input);

      expect(result.dti, equals(30));
    });

    test('연소득이 0이면 DSR과 DTI는 0으로 처리한다', () {
      const input = DsrDtiInput(
        annualIncome: 0,
        housingDebtAnnualPayment: 24000000,
        otherDebtAnnualPayment: 8000000,
      );

      final result = calculator.calculate(input);

      expect(result.dsr, equals(0));
      expect(result.dti, equals(0));
    });
  });
}
