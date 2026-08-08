import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/notice.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/notice_provider.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notices = ref.watch(noticesProvider);
    final readIds = ref.watch(readNoticeIdsProvider).valueOrNull ?? {};

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(title: Text(l10n.settingsNotices)),
      body: SafeArea(
        child: notices.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Text(l10n.settingsNoticesEmpty),
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
                l10n.settingsNoticesLoadError('$error'),
                textAlign: TextAlign.center,
                style: context.typography.bodySecondary,
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
    final palette = context.palette;
    final typo = context.typography;
    final publishedAt = DateFormat('yyyy.MM.dd HH:mm').format(
      notice.publishedAt,
    );

    return Material(
      // 읽지 않은 공지는 primary 를 옅게 깔아 강조한다.
      // 고정 hex 를 쓰면 다크모드에서 배경만 밝아진다.
      color: isRead
          ? palette.surface
          : Color.alphaBlend(
              palette.primary.withOpacity(0.08),
              palette.surface,
            ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? palette.cardBorder : palette.primary,
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
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.title, style: typo.heading3),
                    const SizedBox(height: 6),
                    Text(publishedAt, style: typo.caption),
                    const SizedBox(height: 10),
                    Text(
                      notice.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typo.bodySecondary.copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: palette.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
