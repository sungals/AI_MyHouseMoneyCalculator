import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_notification_service.dart';

class NoticeRealtimeService {
  NoticeRealtimeService({
    required LocalNotificationService notificationService,
  });

  // 공지 목록 realtime 갱신은 Firestore snapshots 기반 NoticeRepository가 담당한다.
  // 이 서비스는 기존 provider 의존성을 유지하기 위한 lifecycle placeholder이다.
  void start() {}

  void stop() {}
}

final noticeRealtimeServiceProvider = Provider<NoticeRealtimeService>((ref) {
  final service = NoticeRealtimeService(
    notificationService: ref.watch(localNotificationServiceProvider),
  );
  ref.onDispose(service.stop);
  return service;
});
