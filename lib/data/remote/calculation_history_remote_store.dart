import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calculation_history.dart';

class CalculationHistoryRemoteStore {
  SupabaseClient get _client => Supabase.instance.client;
  static const _table = 'calculation_history';

  Future<List<CalculationHistory>> fetchAll() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CalculationHistory.fromSupabaseJson(
              Map<String, dynamic>.from(json as Map),
            ))
        .toList();
  }

  Future<void> upsert(CalculationHistory history) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final json = {
      ...history.toSupabaseJson(),
      'user_id': userId,
    };

    await _client.from(_table).upsert(json);
  }

  Future<void> upsertMany(List<CalculationHistory> items) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    if (items.isEmpty) return;

    final rows = items
        .where((h) => !h.isDeleted)
        .map((h) => {
              ...h.toSupabaseJson(),
              'user_id': userId,
            })
        .toList();

    if (rows.isEmpty) return;

    await _client.from(_table).upsert(rows);
  }

  Future<void> delete(String id) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from(_table).delete().eq('id', id).eq('user_id', userId);
  }
}
