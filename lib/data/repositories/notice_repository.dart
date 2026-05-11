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

  Future<Notice?> fetchNoticeById(String id) async {
    final row = await _client
        .from('notices')
        .select()
        .eq('id', id)
        .eq('is_published', true)
        .maybeSingle();

    if (row == null) return null;
    return Notice.fromJson(row);
  }

  Future<Set<String>> fetchReadNoticeIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};

    final rows = await _client
        .from('notice_reads')
        .select('notice_id')
        .eq('user_id', userId);

    return (rows as List)
        .map((row) => (row as Map<String, dynamic>)['notice_id'] as String)
        .toSet();
  }

  Future<void> markAsRead(String noticeId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('notice_reads').upsert(
      {
        'notice_id': noticeId,
        'user_id': userId,
        'read_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'notice_id,user_id',
    );
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
