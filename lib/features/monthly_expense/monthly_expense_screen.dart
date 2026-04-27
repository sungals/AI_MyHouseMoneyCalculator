import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../data/local/calculation_history_store.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/monthly_expense_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import 'monthly_expense_controller.dart';

class MonthlyExpenseScreen extends ConsumerStatefulWidget {
  const MonthlyExpenseScreen({super.key});

  @override
  ConsumerState<MonthlyExpenseScreen> createState() =>
      _MonthlyExpenseScreenState();
}

class _MonthlyExpenseScreenState extends ConsumerState<MonthlyExpenseScreen> {
  final _housing = TextEditingController();
  final _maintenance = TextEditingController();
  final _communication = TextEditingController();
  final _transportation = TextEditingController();
  final _insurance = TextEditingController();
  final _subscription = TextEditingController();
  final _food = TextEditingController();
  final _other = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _housing, _maintenance, _communication, _transportation,
      _insurance, _subscription, _food, _other,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int _parse(TextEditingController c) => MoneyFormatter.parse(c.text);

  void _calculate() {
    final input = MonthlyExpenseInput(
      housing: _parse(_housing),
      maintenance: _parse(_maintenance),
      communication: _parse(_communication),
      transportation: _parse(_transportation),
      insurance: _parse(_insurance),
      subscription: _parse(_subscription),
      food: _parse(_food),
      other: _parse(_other),
    );

    ref.read(monthlyExpenseControllerProvider.notifier).calculate(input);
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(monthlyExpenseControllerProvider);
    if (result == null) return;

    final store = CalculationHistoryStore();
    await store.init();

    final history = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      typeIndex: CalculationType.monthlyExpense.index,
      title: '월 고정비 계산',
      summary: '월 합계 ${MoneyFormatter.formatWithWon(result.totalMonthly)}',
      input: Map.fromEntries(
        result.breakdown.entries.map((e) => MapEntry(e.key, e.value)),
      ),
      result: {
        'totalMonthly': result.totalMonthly,
        'totalAnnual': result.totalAnnual,
      },
      createdAt: DateTime.now(),
    );

    await store.save(history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계산 결과가 저장되었습니다.')),
      );
    }
  }

  void _share() {
    final result = ref.read(monthlyExpenseControllerProvider);
    if (result == null) return;

    final breakdown = result.breakdown.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key}: ${MoneyFormatter.formatWithWon(e.value)}')
        .join('\n');

    final text = '''[집돈계산기] 월 고정비 계산 결과

$breakdown

월 합계: ${MoneyFormatter.formatWithWon(result.totalMonthly)}
연간 합계: ${MoneyFormatter.formatWithWon(result.totalAnnual)}

※ 본 계산 결과는 참고용입니다.''';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(monthlyExpenseControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('월 고정비 계산')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Column(
              children: [
                _ExpenseField(label: '주거비 (월세/이자)', controller: _housing),
                _ExpenseField(label: '관리비', controller: _maintenance),
                _ExpenseField(label: '통신비', controller: _communication),
                _ExpenseField(label: '교통비', controller: _transportation),
                _ExpenseField(label: '보험료', controller: _insurance),
                _ExpenseField(label: '구독료', controller: _subscription),
                _ExpenseField(label: '식비', controller: _food),
                _ExpenseField(
                  label: '기타',
                  controller: _other,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: '계산하기', onPressed: _calculate),
            if (result != null) ...[
              const SizedBox(height: 24),
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
                    const Text('계산 결과',
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ...result.breakdown.entries
                        .where((e) => e.value > 0)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary)),
                                  Text(
                                    MoneyFormatter.formatWithWon(e.value),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('월 합계',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          MoneyFormatter.formatWithWon(result.totalMonthly),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('연간 합계',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary)),
                        Text(
                          MoneyFormatter.formatWithWon(result.totalAnnual),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const DisclaimerBox(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('공유'),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('저장'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 24),
              const DisclaimerBox(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ExpenseField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputAction textInputAction;

  const _ExpenseField({
    required this.label,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MoneyInputField(
        label: label,
        controller: controller,
        textInputAction: textInputAction,
      ),
    );
  }
}
