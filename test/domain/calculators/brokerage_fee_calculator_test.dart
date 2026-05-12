import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/brokerage_fee_calculator.dart';
import 'package:house_money_calculator/domain/entities/brokerage_fee_input.dart';

void main() {
  late BrokerageFeeCalculator calculator;

  setUp(() => calculator = BrokerageFeeCalculator());

  group('BrokerageFeeCalculator', () {
    test('5천만원 미만 매매는 상한액 25만원을 적용한다', () {
      const input = BrokerageFeeInput(
        transactionType: BrokerageTransactionType.sale,
        transactionAmount: 49000000,
      );

      final result = calculator.calculate(input);

      expect(result.rate, equals(0.006));
      expect(result.cap, equals(250000));
      expect(result.fee, equals(250000));
    });

    test('6억원 매매는 0.4% 요율과 한도 없음이 적용된다', () {
      const input = BrokerageFeeInput(
        transactionType: BrokerageTransactionType.sale,
        transactionAmount: 600000000,
      );

      final result = calculator.calculate(input);

      expect(result.rate, equals(0.004));
      expect(result.cap, isNull);
      expect(result.fee, equals(2400000));
    });

    test('1억원 이상 6억원 미만 임대차는 0.3% 요율을 적용한다', () {
      const input = BrokerageFeeInput(
        transactionType: BrokerageTransactionType.lease,
        transactionAmount: 300000000,
      );

      final result = calculator.calculate(input);

      expect(result.rate, equals(0.003));
      expect(result.cap, isNull);
      expect(result.fee, equals(900000));
    });
  });
}
