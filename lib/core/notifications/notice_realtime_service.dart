import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/notice.dart';
import 'local_notification_service.dart';

class NoticeRealtimeService {
  NoticeRealtimeService({
    SupabaseClient? client,
    required LocalNotificationService notificationService,
  })  : _client = client ?? Supabase.instance.client,
        _notificationService = notificationService;

  final SupabaseClient _client;
  final LocalNotificationService _notificationService;
  RealtimeChannel? _channel;

  void start() {
    if (_channel != null) return;

    _channel = _client
        .channel('public:notices')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notices',
          callback: (payload) async {
            final notice = Notice.fromJson(payload.newRecord);
            final isPublished =
                payload.newRecord['is_published'] as bool? ?? false;
            if (!isPublished) return;

            await _notificationService.showNotice(
              title: notice.title,
              body: notice.body,
            );
          },
        )
        .subscribe();
  }

  void stop() {
    final channel = _channel;
    if (channel == null) return;
    _client.removeChannel(channel);
    _channel = null;
  }
}

final noticeRealtimeServiceProvider = Provider<NoticeRealtimeService>((ref) {
  final service = NoticeRealtimeService(
    notificationService: ref.watch(localNotificationServiceProvider),
  );
  ref.onDispose(service.stop);
  return service;
});
