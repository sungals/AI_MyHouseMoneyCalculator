import 'package:hive_flutter/hive_flutter.dart';
import '../models/calculation_history.dart';

class CalculationHistoryStore {
  static const _boxName = 'calculation_history';

  Box<CalculationHistory>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CalculationHistoryAdapter());
    }
    _box = await Hive.openBox<CalculationHistory>(_boxName);
  }

  Box<CalculationHistory> get _safeBox {
    assert(_box != null, 'CalculationHistoryStore not initialized');
    return _box!;
  }

  List<CalculationHistory> getAll() {
    return _safeBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  CalculationHistory? getById(String id) {
    try {
      return _safeBox.values.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CalculationHistory history) async {
    await _safeBox.put(history.id, history);
  }

  Future<void> delete(String id) async {
    final key = _safeBox.keys.firstWhere(
      (k) => _safeBox.get(k)?.id == id,
      orElse: () => null,
    );
    if (key != null) await _safeBox.delete(key);
  }

  Future<void> clear() async {
    await _safeBox.clear();
  }
}
