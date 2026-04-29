import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/data/local/calculation_history_store.dart';
import 'package:house_money_calculator/data/repositories/calculation_history_repository.dart';

void main() {
  group('CalculationHistoryRepository', () {
    test('can be instantiated with local store only', () {
      final repo = CalculationHistoryRepository(
        localStore: CalculationHistoryStore(),
      );
      expect(repo, isNotNull);
    });

    test('getAll returns empty list gracefully before init', () {
      final repo = CalculationHistoryRepository(
        localStore: CalculationHistoryStore(),
      );
      expect(() => repo.getAll(), returnsNormally);
      expect(repo.getAll(), isEmpty);
    });
  });
}
