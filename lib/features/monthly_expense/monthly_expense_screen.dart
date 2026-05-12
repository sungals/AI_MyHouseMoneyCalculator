import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/share_helper.dart';
import '../../providers/calculation_history_provider.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/monthly_expense_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/help_icon.dart';
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
      _housing,
      _maintenance,
      _communication,
      _transportation,
      _insurance,
      _subscription,
      _food,
      _other,
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

    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();

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

    await repo.save(history);

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

    final text = '''[어떤비용] 월 고정비 계산 결과

$breakdown

월 합계: ${MoneyFormatter.formatWithWon(result.totalMonthly)}
연간 합계: ${MoneyFormatter.formatWithWon(result.totalAnnual)}

※ 본 계산 결과는 참고용입니다.''';

    ShareHelper.shareText(
      context,
      text: text,
      subject: '월 고정비 계산 결과',
      title: '월 고정비 계산 결과',
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const _SectionTitle(
              '월 고정 지출',
              helpTitle: '월 고정비란?',
              helpBody: '매달 일정하게 나가는 생활 고정 지출 항목입니다.\n\n'
                  '• 주거비: 월세 또는 전세 대출 월 이자\n'
                  '• 관리비: 건물 관리·공용 시설 이용 비용\n'
                  '• 통신비: 핸드폰·인터넷 요금\n'
                  '• 교통비: 교통카드·주유비 등\n'
                  '• 보험료: 생명보험·실손보험 등 월 납부 보험\n'
                  '• 구독료: 넷플릭스·스포티파이 등 구독 서비스\n'
                  '• 식비: 외식비·식재료비\n'
                  '• 기타: 그 외 고정 지출\n\n'
                  '0원인 항목은 결과에서 제외됩니다.',
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _ExpenseField(
                    label: '주거비 (월세/이자)',
                    controller: _housing,
                    sliderMax: 3000000,
                    sliderDivisions: 60),
                _ExpenseField(
                    label: '관리비',
                    controller: _maintenance,
                    sliderMax: 500000,
                    sliderDivisions: 50),
                _ExpenseField(
                    label: '통신비',
                    controller: _communication,
                    sliderMax: 300000,
                    sliderDivisions: 60),
                _ExpenseField(
                    label: '교통비',
                    controller: _transportation,
                    sliderMax: 500000,
                    sliderDivisions: 50),
                _ExpenseField(
                    label: '보험료',
                    controller: _insurance,
                    sliderMax: 1000000,
                    sliderDivisions: 100),
                _ExpenseField(
                    label: '구독료',
                    controller: _subscription,
                    sliderMax: 200000,
                    sliderDivisions: 40),
                _ExpenseField(
                    label: '식비',
                    controller: _food,
                    sliderMax: 2000000,
                    sliderDivisions: 40),
                _ExpenseField(
                  label: '기타',
                  controller: _other,
                  textInputAction: TextInputAction.done,
                  sliderMax: 1000000,
                  sliderDivisions: 100,
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
                                fontSize: 14, color: AppColors.textSecondary)),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  final String? helpTitle;
  final String? helpBody;

  const _SectionTitle(this.text, {this.helpTitle, this.helpBody});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (helpTitle != null) ...[
          const SizedBox(width: 4),
          HelpIcon(title: helpTitle!, body: helpBody!),
        ],
      ],
    );
  }
}

class _ExpenseField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final double? sliderMax;
  final int sliderDivisions;

  const _ExpenseField({
    required this.label,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.sliderMax,
    this.sliderDivisions = 100,
  });

  static const _quickAmounts = [1000000, 100000, 10000];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MoneyInputField(
        label: label,
        controller: controller,
        textInputAction: textInputAction,
        quickButtonAmounts: _quickAmounts,
        sliderMax: sliderMax,
        sliderDivisions: sliderDivisions,
      ),
    );
  }
}
