import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:house_money_calculator/data/local/calculation_history_store.dart';
import 'package:house_money_calculator/data/models/calculation_history.dart';
import 'package:house_money_calculator/data/repositories/calculation_history_repository.dart';
import 'package:house_money_calculator/features/shared/main_shell.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';
import 'package:house_money_calculator/providers/calculation_history_provider.dart';

void main() {
  testWidgets('shows saved calculation on the recent calculations tab',
      (tester) async {
    final store = _InMemoryHistoryStore();
    final repo = CalculationHistoryRepository(localStore: store);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const MainShell()),
        GoRoute(
          path: '/rent-compare',
          builder: (context, state) => const _SaveAndPopScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calculationHistoryRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('자주 쓰는 계산을\n빠르게 시작하세요'), findsOneWidget);
    expect(find.text('방금 저장한 계산'), findsNothing);

    await tester.tap(find.text('전세 vs 월세 비교'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장하고 돌아가기'));
    await tester.pumpAndSettle();

    expect(find.text('방금 저장한 계산'), findsNothing);

    await tester.tap(find.text('최근계산'));
    await tester.pumpAndSettle();

    expect(find.text('방금 저장한 계산'), findsOneWidget);
  });
}

class _SaveAndPopScreen extends ConsumerWidget {
  const _SaveAndPopScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final repo = ref.read(calculationHistoryRepositoryProvider);
            await repo.save(
              CalculationHistory(
                id: 'new-history',
                typeIndex: CalculationType.rentCompare.index,
                title: '방금 저장한 계산',
                summary: '테스트 저장 결과',
                input: const {},
                result: const {},
                createdAt: DateTime(2026, 5, 12, 12),
              ),
            );
            if (context.mounted) {
              context.pop();
            }
          },
          child: const Text('저장하고 돌아가기'),
        ),
      ),
    );
  }
}

class _InMemoryHistoryStore extends CalculationHistoryStore {
  final Map<String, CalculationHistory> _items = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> save(CalculationHistory history) async {
    _items[history.id] = history;
  }

  @override
  List<CalculationHistory> getAll({bool includeDeleted = false}) {
    final items = _items.values
        .where((item) => includeDeleted || !item.isDeleted)
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }
}
