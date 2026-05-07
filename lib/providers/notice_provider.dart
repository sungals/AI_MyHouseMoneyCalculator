import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/notice.dart';
import '../data/repositories/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepository();
});

final noticesProvider = StreamProvider<List<Notice>>((ref) {
  return ref.watch(noticeRepositoryProvider).watchNotices();
});
