import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/notice.dart';
import '../../providers/notice_provider.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(noticesProvider);
    final readIds = ref.watch(readNoticeIdsProvider).valueOrNull ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('공지사항')),
      body: SafeArea(
        child: notices.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text('등록된 공지사항이 없습니다'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              itemBuilder: (context, index) => _NoticeCard(
                notice: items[index],
                isRead: readIds.contains(items[index].id),
                onTap: () => context.push('/notices/${items[index].id}'),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: items.length,
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

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  final bool isRead;
  final VoidCallback onTap;

  const _NoticeCard({
    required this.notice,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final publishedAt = DateFormat('yyyy.MM.dd HH:mm').format(
      notice.publishedAt,
    );

    return Material(
      color: isRead ? AppColors.surface : const Color(0xFFEFF6FF),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? AppColors.cardBorder : AppColors.primary,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isRead) ...[
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 8, right: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.title, style: AppTextStyles.heading3),
                    const SizedBox(height: 6),
                    Text(publishedAt, style: AppTextStyles.caption),
                    const SizedBox(height: 10),
                    Text(
                      notice.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySecondary.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
