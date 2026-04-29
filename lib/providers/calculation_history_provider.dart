import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/calculation_history_store.dart';
import '../data/models/calculation_history.dart';
import '../data/remote/calculation_history_remote_store.dart';
import '../data/repositories/calculation_history_repository.dart';

final calculationHistoryRepositoryProvider =
    Provider<CalculationHistoryRepository>((ref) {
  return CalculationHistoryRepository(
    localStore: CalculationHistoryStore(),
    remoteStore: CalculationHistoryRemoteStore(),
  );
});

final calculationHistoryListProvider =
    FutureProvider<List<CalculationHistory>>((ref) async {
  final repo = ref.watch(calculationHistoryRepositoryProvider);
  await repo.init();
  return repo.getAll();
});
