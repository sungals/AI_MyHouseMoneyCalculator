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
    await localStore.save(history);
    if (remoteStore != null) {
      try {
        await remoteStore!.upsert(history);
        await localStore.markSynced(history.id);
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

  Future<void> delete(String id) async {
    await localStore.delete(id);
    if (remoteStore != null) {
      try {
        await remoteStore!.delete(id);
      } catch (_) {}
    }
  }

  Future<void> syncUnsynced() async {
    if (remoteStore == null) return;
    try {
      final unsynced = localStore.getAllUnsynced();
      if (unsynced.isEmpty) return;
      await remoteStore!.upsertMany(unsynced);
      for (final item in unsynced) {
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
}
