import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/data/models/calculation_history.dart';

void main() {
  group('CalculationHistory', () {
    final sample = CalculationHistory(
      id: 'test-id',
      typeIndex: 0,
      title: '전월세 비교',
      summary: '월세 50만원',
      input: {'deposit': 100000000},
      result: {'monthlyRent': 500000},
      createdAt: DateTime(2026, 4, 28),
      syncedAt: null,
    );

    test('copyWith updates specified fields only', () {
      final now = DateTime(2026, 4, 29);
      final updated = sample.copyWith(syncedAt: now);
      expect(updated.id, equals('test-id'));
      expect(updated.syncedAt, equals(now));
      expect(updated.title, equals('전월세 비교'));
    });

    test('CalculationType.taxDeduction exists at index 4', () {
      expect(CalculationType.values.length, equals(8));
      expect(CalculationType.values[4], equals(CalculationType.taxDeduction));
      expect(CalculationType.values[5], equals(CalculationType.dsrDti));
      expect(CalculationType.values[6], equals(CalculationType.brokerageFee));
      expect(CalculationType.values[7], equals(CalculationType.acquisitionTax));
    });

    test('featureType returns correct string', () {
      expect(sample.featureType, equals('rent_compare'));
      final taxSample = CalculationHistory(
        id: 'tax-id',
        typeIndex: 4,
        title: '세금 공제',
        summary: '공제 10만원',
        input: {},
        result: {},
        createdAt: DateTime.now(),
        syncedAt: null,
      );
      expect(taxSample.featureType, equals('tax_deduction'));
    });
  });
}
