import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/local/calculation_history_store.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/loan_interest_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import 'loan_interest_controller.dart';

class LoanInterestScreen extends ConsumerStatefulWidget {
  const LoanInterestScreen({super.key});

  @override
  ConsumerState<LoanInterestScreen> createState() => _LoanInterestScreenState();
}

class _LoanInterestScreenState extends ConsumerState<LoanInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmount = TextEditingController();
  final _interestRate = TextEditingController();
  final _months = TextEditingController();

  @override
  void dispose() {
    _loanAmount.dispose();
    _interestRate.dispose();
    _months.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final input = LoanInterestInput(
      loanAmount: MoneyFormatter.parse(_loanAmount.text),
      interestRate: double.parse(_interestRate.text),
      months: int.parse(_months.text),
    );

    ref.read(loanInterestControllerProvider.notifier).calculate(input);
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(loanInterestControllerProvider);
    if (result == null) return;

    final store = CalculationHistoryStore();
    await store.init();

    final history = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      typeIndex: CalculationType.loanInterest.index,
      title: '대출이자 계산',
      summary: '월 이자 ${MoneyFormatter.formatWithWon(result.monthlyInterest)}',
      input: {
        'loanAmount': result.loanAmount,
        'interestRate': double.tryParse(_interestRate.text) ?? 0,
        'months': result.months,
      },
      result: {
        'monthlyInterest': result.monthlyInterest,
        'totalInterest': result.totalInterest,
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
    final result = ref.read(loanInterestControllerProvider);
    if (result == null) return;

    final text = '''[집돈계산기] 대출이자 계산 결과

대출금: ${MoneyFormatter.formatWithWon(result.loanAmount)}
월 이자: ${MoneyFormatter.formatWithWon(result.monthlyInterest)}
${result.months}개월 총 이자: ${MoneyFormatter.formatWithWon(result.totalInterest)}

※ 본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.''';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(loanInterestControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('대출이자 계산')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  MoneyInputField(
                    label: '대출금',
                    controller: _loanAmount,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  PercentInputField(
                    label: '연이율',
                    controller: _interestRate,
                    validator: Validators.interestRate,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _months,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: Validators.months,
                    decoration: const InputDecoration(
                      labelText: '대출 기간',
                      hintText: '예: 24',
                      suffixText: '개월',
                    ),
                  ),
                ],
              ),
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
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 16),
                    _ResultRow(
                      label: '월 이자',
                      value: MoneyFormatter.formatWithWon(result.monthlyInterest),
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 10),
                    _ResultRow(
                      label: '${result.months}개월 총 이자',
                      value: MoneyFormatter.formatWithWon(result.totalInterest),
                      isBold: true,
                      valueColor: AppColors.danger,
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
