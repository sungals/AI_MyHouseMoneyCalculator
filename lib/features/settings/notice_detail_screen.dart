import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/notice_provider.dart';

class NoticeDetailScreen extends ConsumerStatefulWidget {
  const NoticeDetailScreen({super.key, required this.noticeId});

  final String noticeId;

  @override
  ConsumerState<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends ConsumerState<NoticeDetailScreen> {
  bool _markRequested = false;

  Future<void> _markAsRead() async {
    if (_markRequested) return;
    _markRequested = true;
    await ref.read(noticeRepositoryProvider).markAsRead(widget.noticeId);
    ref.invalidate(readNoticeIdsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final notice = ref.watch(noticeDetailProvider(widget.noticeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('공지사항')),
      body: SafeArea(
        child: notice.when(
          data: (item) {
            if (item == null) {
              return const Center(child: Text('공지사항을 찾을 수 없습니다'));
            }

            Future.microtask(_markAsRead);
            final publishedAt = DateFormat('yyyy.MM.dd HH:mm').format(
              item.publishedAt,
            );

            return ListView(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              children: [
                Text(item.title, style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Text(publishedAt, style: AppTextStyles.caption),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    item.body,
                    style: AppTextStyles.body.copyWith(height: 1.6),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '공지사항을 불러오지 못했습니다\n$error',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
