import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/acquisition_tax_calculator.dart';
import 'package:house_money_calculator/domain/entities/acquisition_tax_input.dart';

void main() {
  late AcquisitionTaxCalculator calculator;

  setUp(() => calculator = AcquisitionTaxCalculator());

  group('AcquisitionTaxCalculator', () {
    test('6억원 이하는 1% 세율을 적용한다', () {
      const input = AcquisitionTaxInput(
        price: 600000000,
        houseCount: HouseCountType.one,
        regulatedArea: false,
      );

      final result = calculator.calculate(input);

      expect(result.rate, equals(0.01));
      expect(result.tax, equals(6000000));
    });

    test('6억원 초과 9억원 이하는 누진 산식 세율을 적용한다', () {
      const input = AcquisitionTaxInput(
        price: 750000000,
        houseCount: HouseCountType.one,
        regulatedArea: false,
      );

      final result = calculator.calculate(input);

      expect(result.rate, closeTo(0.02, 0.0000001));
      expect(result.tax, equals(15000000));
    });

    test('조정대상지역 2주택은 8% 중과 세율을 적용한다', () {
      const input = AcquisitionTaxInput(
        price: 500000000,
        houseCount: HouseCountType.two,
        regulatedArea: true,
      );

      final result = calculator.calculate(input);

      expect(result.rate, equals(0.08));
      expect(result.tax, equals(40000000));
    });

    test('3주택 이상은 12% 중과 세율을 적용한다', () {
      const input = AcquisitionTaxInput(
        price: 500000000,
        houseCount: HouseCountType.threePlus,
        regulatedArea: false,
      );

      final result = calculator.calculate(input);

      expect(result.rate, equals(0.12));
      expect(result.tax, equals(60000000));
    });
  });
}
