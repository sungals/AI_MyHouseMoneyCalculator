import 'package:hive_flutter/hive_flutter.dart';
import '../models/calculation_history.dart';

class CalculationHistoryStore {
  static const String boxName = 'calculation_history';

  Box<CalculationHistory>? _box;

  Box<CalculationHistory> get _safeBox {
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
