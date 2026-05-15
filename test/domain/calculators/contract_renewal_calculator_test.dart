import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/contract_renewal_calculator.dart';
import 'package:house_money_calculator/domain/entities/contract_renewal_input.dart';

void main() {
  group('ContractRenewalCalculator', () {
    test('5% 상한 기준 보증금과 월세를 계산한다', () {
      final result = ContractRenewalCalculator().calculate(
        const ContractRenewalInput(
          currentDeposit: 100000000,
          currentMonthlyRent: 500000,
          increaseRate: 5.0,
        ),
      );

      expect(result.maxDeposit, 105000000);
      expect(result.maxMonthlyRent, 525000);
      expect(result.depositIncrease, 5000000);
      expect(result.monthlyRentIncrease, 25000);
    });
  });
}
