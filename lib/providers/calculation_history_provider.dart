import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/calculation_history_store.dart';
import '../data/models/calculation_history.dart';
import '../data/remote/calculation_history_remote_store.dart';
import '../data/repositories/calculation_history_repository.dart';

enum HistorySyncState { idle, synced, failed }

class HistorySyncStatus {
  final HistorySyncState state;
  final String? operation;
  final DateTime? occurredAt;

  const HistorySyncStatus({
    this.state = HistorySyncState.idle,
    this.operation,
    this.occurredAt,
  });
}

class HistorySyncStatusNotifier extends StateNotifier<HistorySyncStatus> {
  HistorySyncStatusNotifier() : super(const HistorySyncStatus());

  void recordSuccess(String operation) {
    state = HistorySyncStatus(
      state: HistorySyncState.synced,
      operation: operation,
      occurredAt: DateTime.now(),
    );
  }

  void recordFailure(String operation, Object error, StackTrace stackTrace) {
    debugPrint(
      '[CalculationHistorySync] operation=$operation error=$error\n$stackTrace',
    );
    state = HistorySyncStatus(
      state: HistorySyncState.failed,
      operation: operation,
      occurredAt: DateTime.now(),
    );
  }
}

final calculationHistorySyncStatusProvider =
    StateNotifierProvider<HistorySyncStatusNotifier, HistorySyncStatus>((ref) {
  return HistorySyncStatusNotifier();
});

final calculationHistoryRepositoryProvider =
    Provider<CalculationHistoryRepository>((ref) {
  final syncStatus = ref.read(calculationHistorySyncStatusProvider.notifier);
  return CalculationHistoryRepository(
    localStore: CalculationHistoryStore(),
    remoteStore: CalculationHistoryRemoteStore(),
    onSyncSuccess: syncStatus.recordSuccess,
    onSyncFailure: syncStatus.recordFailure,
  );
});

final calculationHistoryListProvider =
    FutureProvider<List<CalculationHistory>>((ref) async {
  final repo = ref.watch(calculationHistoryRepositoryProvider);
  await repo.init();
  return repo.getAll();
});
