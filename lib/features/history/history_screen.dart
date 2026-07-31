import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/calculation_history.dart';
import '../../providers/calculation_history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<CalculationHistory> _items = [];
  bool _isLoading = true;
  String _query = '';
  CalculationType? _selectedType;
  bool _favoritesOnly = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    if (mounted) {
      setState(() {
        _items = repo.getAll();
        _isLoading = false;
      });
    }
  }

  Future<void> _delete(String id) async {
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    await repo.delete(id);
    if (mounted) {
      setState(() => _items = repo.getAll());
    }
  }

  Future<void> _toggleFavorite(String id) async {
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    await repo.toggleFavorite(id);
    if (mounted) {
      setState(() => _items = repo.getAll());
    }
  }

  Future<void> _retrySync() async {
    setState(() => _isSyncing = true);
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.syncWithRemote();
    if (!mounted) return;
    setState(() {
      _items = repo.getAll();
      _isSyncing = false;
    });
  }

  List<CalculationHistory> get _filteredItems {
    final normalizedQuery = _query.trim().toLowerCase();
    return _items.where((item) {
      if (_selectedType != null && item.type != _selectedType) return false;
      if (_favoritesOnly && !item.isFavorite) return false;
      if (normalizedQuery.isEmpty) return true;
      final haystack = [
        item.title,
        item.summary,
        item.memo,
        item.type.label,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(calculationHistorySyncStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('최근계산')),
      body: Column(
        children: [
          if (syncStatus.state == HistorySyncState.failed)
            Material(
              color: AppColors.warning.withOpacity(0.12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '서버 동기화가 지연되고 있습니다. 로컬 저장은 완료되었습니다.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                    TextButton(
                      onPressed: _isSyncing ? null : _retrySync,
                      child: _isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark_outline,
                                size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('저장된 계산이 없어요.',
                                style: AppTextStyles.bodySecondary),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppConstants.horizontalPadding,
                              8,
                              AppConstants.horizontalPadding,
                              10,
                            ),
                            child: TextField(
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: '제목, 요약, 메모 검색',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.horizontalPadding,
                              ),
                              children: [
                                FilterChip(
                                  label: const Text('즐겨찾기'),
                                  selected: _favoritesOnly,
                                  onSelected: (selected) =>
                                      setState(() => _favoritesOnly = selected),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('전체'),
                                  selected: _selectedType == null,
                                  onSelected: (_) =>
                                      setState(() => _selectedType = null),
                                ),
                                const SizedBox(width: 8),
                                ...CalculationType.values.map(
                                  (type) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(type.label),
                                      selected: _selectedType == type,
                                      onSelected: (_) =>
                                          setState(() => _selectedType = type),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _filteredItems.isEmpty
                                ? Center(
                                    child: Text(
                                      '조건에 맞는 저장 기록이 없습니다.',
                                      style: AppTextStyles.bodySecondary,
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(
                                      AppConstants.horizontalPadding,
                                    ),
                                    itemCount: _filteredItems.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = _filteredItems[index];
                                      return _HistoryCard(
                                        item: item,
                                        onTap: () async {
                                          await context
                                              .push('/history/${item.id}');
                                          _load();
                                        },
                                        onDelete: () => _delete(item.id),
                                        onToggleFavorite: () =>
                                            _toggleFavorite(item.id),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CalculationHistory item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _HistoryCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final date = item.createdAt;
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child:
                              Text(item.title, style: AppTextStyles.heading3),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.type.label,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.summary,
                        style: AppTextStyles.bodySecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (item.memo.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.memo,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(dateStr, style: AppTextStyles.caption),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.star : Icons.star_border,
                  color: item.isFavorite
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
                onPressed: onToggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.textSecondary),
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('이 계산 결과를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
