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

  List<CalculationHistory> getAll() {
    final items = _safeBox.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  CalculationHistory? getById(String id) {
    return _safeBox.get(id);
  }

  List<CalculationHistory> getAllUnsynced() {
    return _safeBox.values
        .where((h) => h.syncedAt == null)
        .toList();
  }

  Future<void> markSynced(String id) async {
    final item = _safeBox.get(id);
    if (item == null) return;
    final updated = item.copyWith(syncedAt: DateTime.now());
    await _safeBox.put(id, updated);
  }

  Future<void> delete(String id) async {
    await _safeBox.delete(id);
  }

  Future<void> clear() async {
    await _safeBox.clear();
  }
}
