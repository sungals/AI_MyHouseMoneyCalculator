import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/money_formatter.dart';
import '../../data/local/calculation_history_store.dart';
import '../../data/models/calculation_history.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String id;

  const HistoryDetailScreen({super.key, required this.id});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final _store = CalculationHistoryStore();
  CalculationHistory? _item;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _store.init();
    setState(() => _item = _store.getById(widget.id));
  }

  void _share() {
    final item = _item;
    if (item == null) return;

    final resultEntries = item.result.entries
        .map((e) => '${e.key}: ${_formatValue(e.value)}')
        .join('\n');

    final text = '[집돈계산기] ${item.title}\n\n'
        '${item.summary}\n\n'
        '$resultEntries\n\n'
        '※ 본 계산 결과는 참고용입니다.';

    Share.share(text);
  }

  String _formatValue(dynamic value) {
    if (value is int) return MoneyFormatter.formatWithWon(value);
    if (value is double) return '$value%';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('계산 결과를 찾을 수 없습니다.')),
      );
    }

    final date = item.createdAt;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(dateStr, style: AppTextStyles.caption),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('결과 요약', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Text(item.summary, style: AppTextStyles.body),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('계산 결과', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  ...item.result.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: AppTextStyles.bodySecondary),
                            Text(_formatValue(e.value),
                                style: AppTextStyles.body),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
