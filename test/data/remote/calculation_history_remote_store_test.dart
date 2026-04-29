import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/data/models/calculation_history.dart';
import 'package:house_money_calculator/data/remote/calculation_history_remote_store.dart';

void main() {
  group('CalculationHistoryRemoteStore', () {
    test('can be instantiated', () {
      final store = CalculationHistoryRemoteStore();
      expect(store, isNotNull);
    });

    test('toSupabaseJson produces correct keys', () {
      final history = CalculationHistory(
        id: 'abc',
        typeIndex: 0,
        title: '비교',
        summary: '요약',
        input: {'a': 1},
        result: {'b': 2},
        createdAt: DateTime.utc(2026, 4, 28),
        syncedAt: null,
      );
      final json = history.toSupabaseJson();
      expect(json['feature_type'], equals('rent_compare'));
      expect(json['input_data'], equals({'a': 1}));
      expect(json['created_at'], contains('2026-04-28'));
    });
  });
}
