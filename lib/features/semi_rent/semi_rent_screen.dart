import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/local/calculation_history_store.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/semi_rent_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import 'semi_rent_controller.dart';

class SemiRentScreen extends ConsumerStatefulWidget {
  const SemiRentScreen({super.key});

  @override
  ConsumerState<SemiRentScreen> createState() => _SemiRentScreenState();
}

class _SemiRentScreenState extends ConsumerState<SemiRentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _baseDeposit = TextEditingController();
  final _convertedDeposit = TextEditingController();
  final _monthlyRent = TextEditingController();
  final _conversionRate = TextEditingController();
  final _maintenance = TextEditingController();
  final _months = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conversionRate.text = '5.0';
  }

  @override
  void dispose() {
    for (final c in [
      _baseDeposit, _convertedDeposit, _monthlyRent,
      _conversionRate, _maintenance, _months,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final input = SemiRentInput(
      baseJeonseDeposit: MoneyFormatter.parse(_baseDeposit.text),
      convertedDeposit: MoneyFormatter.parse(_convertedDeposit.text),
      monthlyRent: MoneyFormatter.parse(_monthlyRent.text),
      conversionRate: double.parse(_conversionRate.text),
      maintenanceFee: MoneyFormatter.parse(_maintenance.text),
      months: int.parse(_months.text),
    );

    ref.read(semiRentControllerProvider.notifier).calculate(input);
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(semiRentControllerProvider);
    if (result == null) return;

    final store = CalculationHistoryStore();
    await store.init();

    final history = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      typeIndex: CalculationType.semiRent.index,
      title: '반전세 계산',
      summary: result.summaryText,
      input: {
        'baseDeposit': MoneyFormatter.parse(_baseDeposit.text),
        'convertedDeposit': MoneyFormatter.parse(_convertedDeposit.text),
        'monthlyRent': MoneyFormatter.parse(_monthlyRent.text),
        'conversionRate': double.tryParse(_conversionRate.text) ?? 0,
        'months': int.tryParse(_months.text) ?? 0,
      },
      result: {
        'fairMonthlyRent': result.fairMonthlyRent,
        'actualMonthlyRent': result.actualMonthlyRent,
        'monthlyDifference': result.monthlyDifference,
        'totalDifference': result.totalDifference,
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
    final result = ref.read(semiRentControllerProvider);
    if (result == null) return;

    final text = '''[집돈계산기] 반전세 계산 결과

${result.summaryText}

전환율 기준 적정 월세: ${MoneyFormatter.formatWithWon(result.fairMonthlyRent)}
실제 월세: ${MoneyFormatter.formatWithWon(result.actualMonthlyRent)}

※ 본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.''';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(semiRentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('반전세 계산')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  MoneyInputField(
                    label: '기준 전세 보증금',
                    controller: _baseDeposit,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전환 후 보증금',
                    controller: _convertedDeposit,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세',
                    controller: _monthlyRent,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  PercentInputField(
                    label: '전월세 전환율',
                    controller: _conversionRate,
                    validator: Validators.interestRate,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '관리비',
                    controller: _maintenance,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _months,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: Validators.months,
                    decoration: const InputDecoration(
                      labelText: '거주 기간',
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
              _ResultCard(result: result, onSave: _save, onShare: _share),
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

class _ResultCard extends StatelessWidget {
  final dynamic result;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const _ResultCard({
    required this.result,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isOverpriced = result.isOverpriced as bool;
    final color = isOverpriced ? AppColors.danger : AppColors.positive;

    return Column(
      children: [
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
              Text(
                result.summaryText as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _Row(
                label: '전환율 기준 적정 월세',
                value: MoneyFormatter.formatWithWon(result.fairMonthlyRent as int),
              ),
              const SizedBox(height: 10),
              _Row(
                label: '실제 월세',
                value: MoneyFormatter.formatWithWon(result.actualMonthlyRent as int),
                valueColor: color,
                isBold: true,
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
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('공유'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('저장'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _Row({
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
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
