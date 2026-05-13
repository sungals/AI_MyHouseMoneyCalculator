import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/notice.dart';
import '../data/repositories/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepository();
});

final noticesProvider = StreamProvider<List<Notice>>((ref) {
  return ref.watch(noticeRepositoryProvider).watchNotices();
});

final readNoticeIdsProvider = FutureProvider<Set<String>>((ref) {
  return ref.watch(noticeRepositoryProvider).fetchReadNoticeIds();
});

final noticeDetailProvider =
    FutureProvider.family<Notice?, String>((ref, noticeId) {
  return ref.watch(noticeRepositoryProvider).fetchNoticeById(noticeId);
});

final allNoticesAdminProvider = FutureProvider<List<Notice>>((ref) {
  return ref.watch(noticeRepositoryProvider).fetchAllNoticesForAdmin();
});
