import '../local/calculation_history_store.dart';
import '../models/calculation_history.dart';
import '../remote/calculation_history_remote_store.dart';

class CalculationHistoryRepository {
  final CalculationHistoryStore localStore;
  final CalculationHistoryRemoteStore? remoteStore;

  CalculationHistoryRepository({
    required this.localStore,
    this.remoteStore,
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
      } catch (_) {
        // 오프라인이거나 서버 오류 — 로컬 저장은 완료됨
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
      } catch (_) {}
    } else {
      await localStore.delete(id);
    }
  }

  Future<void> syncUnsynced() async {
    if (remoteStore == null) return;
    try {
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
    } catch (_) {}
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
    } catch (_) {}
  }

  Future<void> syncWithRemote() async {
    if (remoteStore == null) return;
    try {
      await syncUnsynced();
      final remoteItems = await remoteStore!.fetchAll();
      for (final remote in remoteItems) {
        final local = localStore.getById(remote.id);
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await localStore.save(
            remote.copyWith(syncedAt: DateTime.now(), clearDeletedAt: true),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _syncOne(String id) async {
    if (remoteStore == null) return;
    final item = localStore.getById(id);
    if (item == null) return;
    try {
      await remoteStore!.upsert(item);
      await localStore.markSynced(id);
    } catch (_) {}
  }
}
