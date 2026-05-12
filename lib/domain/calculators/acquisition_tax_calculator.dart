import '../entities/acquisition_tax_input.dart';
import '../entities/acquisition_tax_result.dart';

class AcquisitionTaxCalculator {
  AcquisitionTaxResult calculate(AcquisitionTaxInput input) {
    final rate = _taxRate(input);
    return AcquisitionTaxResult(
      tax: (input.price * rate).round(),
      rate: rate,
    );
  }

  double _taxRate(AcquisitionTaxInput input) {
    if (input.houseCount == HouseCountType.threePlus) return 0.12;
    if (input.houseCount == HouseCountType.two && input.regulatedArea) {
      return 0.08;
    }
    if (input.price <= 600000000) return 0.01;
    if (input.price <= 900000000) {
      final hundredMillion = input.price / 100000000;
      return ((hundredMillion * 2 / 3) - 3) / 100;
    }
    return 0.03;
  }
}
