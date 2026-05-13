import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/notice.dart';
import '../../providers/notice_provider.dart';

class AdminNoticesScreen extends ConsumerWidget {
  const AdminNoticesScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    final _ = await ref.refresh(allNoticesAdminProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(allNoticesAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('공지사항 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final saved = await context.push<bool>('/admin/notices/new');
              if (saved == true) {
                await _refresh(ref);
              }
            },
          ),
        ],
      ),
      body: notices.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('등록된 공지사항이 없습니다'));
          }
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _NoticeAdminTile(notice: list[index], ref: ref),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _NoticeAdminTile extends StatelessWidget {
  const _NoticeAdminTile({required this.notice, required this.ref});

  final Notice notice;
  final WidgetRef ref;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('"${notice.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(noticeRepositoryProvider).deleteNotice(notice.id);
    final _ = await ref.refresh(allNoticesAdminProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('yyyy.MM.dd').format(notice.publishedAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            if (!notice.isPublished)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '비공개',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: Text(
                notice.title,
                style: AppTextStyles.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(date, style: AppTextStyles.caption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: AppColors.primary,
              onPressed: () async {
                final saved = await context.push<bool>(
                  '/admin/notices/${notice.id}/edit',
                );
                if (saved == true) {
                  final _ = await ref.refresh(allNoticesAdminProvider.future);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.danger,
              onPressed: () => _delete(context),
            ),
          ],
        ),
      ),
    );
  }
}
