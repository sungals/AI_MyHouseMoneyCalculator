import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/gen/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final typo = context.typography;
    final notice = ref.watch(noticeDetailProvider(widget.noticeId));

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.settingsNotices)),
      body: SafeArea(
        child: notice.when(
          data: (item) {
            if (item == null) {
              return Center(child: Text(l10n.settingsNoticeNotFound));
            }

            Future.microtask(_markAsRead);
            final publishedAt = DateFormat('yyyy.MM.dd HH:mm').format(
              item.publishedAt,
            );

            return ListView(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              children: [
                Text(item.title, style: typo.heading2),
                const SizedBox(height: 8),
                Text(publishedAt, style: typo.caption),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.cardBorder),
                  ),
                  child: item.contentHtml != null
                      ? HtmlWidget(
                          item.contentHtml!,
                          textStyle: typo.body.copyWith(height: 1.6),
                        )
                      : Text(
                          item.body,
                          style: typo.body.copyWith(height: 1.6),
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
                l10n.settingsNoticesLoadError('$error'),
                textAlign: TextAlign.center,
                style: typo.bodySecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
