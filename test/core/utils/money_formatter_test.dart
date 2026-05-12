import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/utils/money_formatter.dart';

void main() {
  group('MoneyFormatter', () {
    test('formatKorean returns empty string for zero', () {
      expect(MoneyFormatter.formatKorean(0), isEmpty);
    });

    test('formatKorean formats ten-thousand and hundred-million units', () {
      expect(MoneyFormatter.formatKorean(10000), equals('1만원'));
      expect(MoneyFormatter.formatKorean(20000000), equals('2천만원'));
      expect(MoneyFormatter.formatKorean(320000000), equals('3억2천만원'));
    });

    test('formatKorean keeps won unit for amounts below ten-thousand', () {
      expect(MoneyFormatter.formatKorean(3500), equals('3,500원'));
    });
  });
}
