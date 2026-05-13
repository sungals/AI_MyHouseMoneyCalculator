import 'dart:typed_data';

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

  Future<Notice?> fetchNoticeByIdForAdmin(String id) async {
    final row =
        await _client.from('notices').select().eq('id', id).maybeSingle();

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

  Future<List<Notice>> fetchAllNoticesForAdmin() async {
    final rows = await _client
        .from('notices')
        .select()
        .order('published_at', ascending: false)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => Notice.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> createNotice({
    required String title,
    required String body,
    String? contentHtml,
    required DateTime publishedAt,
    required bool isPublished,
  }) async {
    await _client.from('notices').insert({
      'title': title,
      'body': body,
      'content_html': contentHtml,
      'published_at': publishedAt.toUtc().toIso8601String(),
      'is_published': isPublished,
    });
  }

  Future<void> updateNotice({
    required String id,
    required String title,
    required String body,
    String? contentHtml,
    required DateTime publishedAt,
    required bool isPublished,
  }) async {
    await _client.from('notices').update({
      'title': title,
      'body': body,
      'content_html': contentHtml,
      'published_at': publishedAt.toUtc().toIso8601String(),
      'is_published': isPublished,
    }).eq('id', id);
  }

  Future<void> deleteNotice(String id) async {
    await _client.from('notices').delete().eq('id', id);
  }

  Future<String> uploadNoticeImage(String fileName, Uint8List bytes) async {
    final path = 'notices/$fileName';
    await _client.storage.from('notice-images').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('notice-images').getPublicUrl(path);
  }
}
