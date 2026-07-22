import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/data/local/calculation_history_store.dart';
import 'package:house_money_calculator/data/models/calculation_history.dart';
import 'package:house_money_calculator/data/remote/calculation_history_remote_store.dart';
import 'package:house_money_calculator/data/repositories/calculation_history_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCalculationHistoryStore extends Mock
    implements CalculationHistoryStore {}

class MockCalculationHistoryRemoteStore extends Mock
    implements CalculationHistoryRemoteStore {}

void main() {
  setUpAll(() {
    registerFallbackValue(_history());
  });

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

    test('reports remote save failure while preserving local save', () async {
      final localStore = MockCalculationHistoryStore();
      final remoteStore = MockCalculationHistoryRemoteStore();
      final failures = <String>[];
      when(() => localStore.save(any())).thenAnswer((_) async {});
      when(() => remoteStore.upsert(any())).thenThrow(Exception('offline'));

      final repo = CalculationHistoryRepository(
        localStore: localStore,
        remoteStore: remoteStore,
        onSyncFailure: (operation, error, stackTrace) {
          failures.add(operation);
        },
      );

      await repo.save(_history());

      verify(() => localStore.save(any())).called(1);
      verify(() => remoteStore.upsert(any())).called(1);
      expect(failures, ['save']);
    });

    test('reports full sync failure', () async {
      final localStore = MockCalculationHistoryStore();
      final remoteStore = MockCalculationHistoryRemoteStore();
      final failures = <String>[];
      when(localStore.getAllUnsynced).thenReturn([]);
      when(remoteStore.fetchAll).thenThrow(Exception('server error'));

      final repo = CalculationHistoryRepository(
        localStore: localStore,
        remoteStore: remoteStore,
        onSyncFailure: (operation, error, stackTrace) {
          failures.add(operation);
        },
      );

      await repo.syncWithRemote();

      expect(failures, ['full_sync']);
    });
  });
}

CalculationHistory _history() {
  final now = DateTime(2026, 6, 18);
  return CalculationHistory(
    id: 'history-1',
    typeIndex: CalculationType.rentCompare.index,
    title: '전세 vs 월세 비교',
    summary: '전세가 유리해요.',
    input: const {},
    result: const {},
    createdAt: now,
  );
}
