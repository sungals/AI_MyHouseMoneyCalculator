import 'package:hive_flutter/hive_flutter.dart';
import '../models/calculation_history.dart';

class CalculationHistoryStore {
  static const String boxName = 'calculation_history';

  Box<CalculationHistory>? _box;

  Box<CalculationHistory> get _safeBox {
    // Repository가 여러 provider 경로에서 만들어져도 이미 열린 box를 재사용한다.
    if (_box != null && _box!.isOpen) return _box!;
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<CalculationHistory>(boxName);
      return _box!;
    }
    throw StateError('CalculationHistory box is not open. Call init() first.');
  }

  Future<void> init() async {
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<CalculationHistory>(boxName);
      return;
    }
    _box = await Hive.openBox<CalculationHistory>(boxName);
  }

  Future<void> save(CalculationHistory history) async {
    await _safeBox.put(history.id, history);
  }

  List<CalculationHistory> getAll({bool includeDeleted = false}) {
    final items =
        _safeBox.values.where((h) => includeDeleted || !h.isDeleted).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  CalculationHistory? getById(String id) {
    final item = _safeBox.get(id);
    if (item?.isDeleted ?? false) return null;
    return item;
  }

  List<CalculationHistory> getAllUnsynced() {
    // 신규/수정/삭제 tombstone 중 원격 반영이 필요한 항목만 sync 대상으로 본다.
    return _safeBox.values.where((h) {
      final syncedAt = h.syncedAt;
      if (syncedAt == null) return true;
      if (h.updatedAt.isAfter(syncedAt)) return true;
      final deletedAt = h.deletedAt;
      return deletedAt != null && deletedAt.isAfter(syncedAt);
    }).toList();
  }

  Future<void> markSynced(String id) async {
    final item = _safeBox.get(id);
    if (item == null) return;
    final updated = item.copyWith(syncedAt: DateTime.now());
    await _safeBox.put(id, updated);
  }

  Future<void> updateMemo(String id, String memo) async {
    final item = _safeBox.get(id);
    if (item == null) return;
    final updated = item.copyWith(
      memo: memo,
      updatedAt: DateTime.now(),
      syncedAt: null,
    );
    await _safeBox.put(id, updated);
  }

  Future<void> toggleFavorite(String id) async {
    final item = _safeBox.get(id);
    if (item == null) return;
    final updated = item.copyWith(
      isFavorite: !item.isFavorite,
      updatedAt: DateTime.now(),
      syncedAt: null,
    );
    await _safeBox.put(id, updated);
  }

  Future<void> markDeleted(String id) async {
    final item = _safeBox.get(id);
    if (item == null) return;
    final now = DateTime.now();
    // 오프라인 삭제를 보존하기 위해 즉시 remove하지 않고 deletedAt을 남긴다.
    final updated = item.copyWith(
      deletedAt: now,
      updatedAt: now,
      syncedAt: null,
    );
    await _safeBox.put(id, updated);
  }

  Future<void> delete(String id) async {
    await _safeBox.delete(id);
  }

  Future<void> clear() async {
    await _safeBox.clear();
  }
}
