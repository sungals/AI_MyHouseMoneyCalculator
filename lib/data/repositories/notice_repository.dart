import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notice.dart';

class NoticeRepository {
  NoticeRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<Notice>> fetchNotices() async {
    final rows = await _client
        .from('notices')
        .select()
        .eq('is_published', true)
        .order('published_at', ascending: false);

    return (rows as List)
        .map((row) => Notice.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Stream<List<Notice>> watchNotices() {
    return _client
        .from('notices')
        .stream(primaryKey: ['id'])
        .eq('is_published', true)
        .order('published_at', ascending: false)
        .map((rows) => rows.map(Notice.fromJson).toList());
  }
}
