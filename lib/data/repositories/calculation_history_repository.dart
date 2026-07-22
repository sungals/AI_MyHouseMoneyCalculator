import '../local/calculation_history_store.dart';
import '../models/calculation_history.dart';
import '../remote/calculation_history_remote_store.dart';

typedef SyncSuccessCallback = void Function(String operation);
typedef SyncFailureCallback = void Function(
  String operation,
  Object error,
  StackTrace stackTrace,
);

class CalculationHistoryRepository {
  final CalculationHistoryStore localStore;
  final CalculationHistoryRemoteStore? remoteStore;
  final SyncSuccessCallback? onSyncSuccess;
  final SyncFailureCallback? onSyncFailure;

  CalculationHistoryRepository({
    required this.localStore,
    this.remoteStore,
    this.onSyncSuccess,
    this.onSyncFailure,
  });

  Future<void> init() => localStore.init();

  Future<void> save(CalculationHistory history) async {
    final now = DateTime.now();
    final item = history.copyWith(updatedAt: now, syncedAt: null);
    await localStore.save(item);
    if (remoteStore != null) {
      try {
        await remoteStore!.upsert(item);
        await localStore.markSynced(item.id);
        onSyncSuccess?.call('save');
      } catch (error, stackTrace) {
        // 오프라인이거나 서버 오류 — 로컬 저장은 완료됨
        onSyncFailure?.call('save', error, stackTrace);
      }
    }
  }

  List<CalculationHistory> getAll() {
    try {
      return localStore.getAll();
    } catch (_) {
      return [];
    }
  }

  CalculationHistory? getById(String id) {
    try {
      return localStore.getById(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateMemo(String id, String memo) async {
    await localStore.updateMemo(id, memo);
    await _syncOne(id);
  }

  Future<void> toggleFavorite(String id) async {
    await localStore.toggleFavorite(id);
    await _syncOne(id);
  }

  Future<void> delete(String id) async {
    await localStore.markDeleted(id);
    if (remoteStore != null) {
      try {
        await remoteStore!.delete(id);
        await localStore.delete(id);
        onSyncSuccess?.call('delete');
      } catch (error, stackTrace) {
        onSyncFailure?.call('delete', error, stackTrace);
      }
    } else {
      await localStore.delete(id);
    }
  }

  Future<void> syncUnsynced() async {
    if (remoteStore == null) return;
    try {
      await _syncUnsynced();
      onSyncSuccess?.call('sync_unsynced');
    } catch (error, stackTrace) {
      onSyncFailure?.call('sync_unsynced', error, stackTrace);
    }
  }

  Future<void> migrateLocalToRemote() async {
    if (remoteStore == null) return;
    try {
      final all = localStore.getAll();
      if (all.isEmpty) return;
      await remoteStore!.upsertMany(all);
      for (final item in all) {
        await localStore.markSynced(item.id);
      }
      onSyncSuccess?.call('migrate');
    } catch (error, stackTrace) {
      onSyncFailure?.call('migrate', error, stackTrace);
    }
  }

  Future<void> syncWithRemote() async {
    if (remoteStore == null) return;
    try {
      await _syncUnsynced();
      final remoteItems = await remoteStore!.fetchAll();
      for (final remote in remoteItems) {
        final local = localStore.getById(remote.id);
        // 단순 last-write-wins 정책. 충돌 UI는 두지 않고 updatedAt이 최신인 쪽을 채택한다.
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await localStore.save(
            remote.copyWith(syncedAt: DateTime.now(), clearDeletedAt: true),
          );
        }
      }
      onSyncSuccess?.call('full_sync');
    } catch (error, stackTrace) {
      onSyncFailure?.call('full_sync', error, stackTrace);
    }
  }

  Future<void> clearLocal() => localStore.clear();

  Future<void> _syncOne(String id) async {
    if (remoteStore == null) return;
    final item = localStore.getById(id);
    if (item == null) return;
    try {
      await remoteStore!.upsert(item);
      await localStore.markSynced(id);
      onSyncSuccess?.call('update');
    } catch (error, stackTrace) {
      onSyncFailure?.call('update', error, stackTrace);
    }
  }

  Future<void> _syncUnsynced() async {
    // 삭제 tombstone을 먼저 원격에 반영해야 이후 fetch에서 되살아나지 않는다.
    final unsynced = localStore.getAllUnsynced();
    if (unsynced.isEmpty) return;
    final deleted = unsynced.where((item) => item.isDeleted).toList();
    final active = unsynced.where((item) => !item.isDeleted).toList();

    for (final item in deleted) {
      await remoteStore!.delete(item.id);
      await localStore.delete(item.id);
    }

    await remoteStore!.upsertMany(active);
    for (final item in active) {
      await localStore.markSynced(item.id);
    }
  }
}
