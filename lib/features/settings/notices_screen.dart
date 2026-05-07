import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              itemBuilder: (context, index) => _NoticeCard(items[index]),
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

  const _NoticeCard(this.notice);

  @override
  Widget build(BuildContext context) {
    final publishedAt = DateFormat('yyyy.MM.dd HH:mm').format(
      notice.publishedAt,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notice.title, style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Text(publishedAt, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Text(
            notice.body,
            style: AppTextStyles.bodySecondary.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}
