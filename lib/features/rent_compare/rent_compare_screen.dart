import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/local/calculation_history_store.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/rent_compare_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import 'rent_compare_controller.dart';
import 'widgets/rent_compare_result_card.dart';

class RentCompareScreen extends ConsumerStatefulWidget {
  const RentCompareScreen({super.key});

  @override
  ConsumerState<RentCompareScreen> createState() => _RentCompareScreenState();
}

class _RentCompareScreenState extends ConsumerState<RentCompareScreen> {
  final _formKey = GlobalKey<FormState>();

  final _jeonseDeposit = TextEditingController();
  final _jeonseLoan = TextEditingController();
  final _interestRate = TextEditingController();
  final _rentDeposit = TextEditingController();
  final _monthlyRent = TextEditingController();
  final _maintenance = TextEditingController();
  final _months = TextEditingController();

  final _fn1 = FocusNode();
  final _fn2 = FocusNode();
  final _fn3 = FocusNode();
  final _fn4 = FocusNode();
  final _fn5 = FocusNode();
  final _fn6 = FocusNode();
  final _fn7 = FocusNode();

  @override
  void dispose() {
    for (final c in [
      _jeonseDeposit, _jeonseLoan, _interestRate, _rentDeposit,
      _monthlyRent, _maintenance, _months,
    ]) {
      c.dispose();
    }
    for (final f in [_fn1, _fn2, _fn3, _fn4, _fn5, _fn6, _fn7]) {
      f.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final deposit = MoneyFormatter.parse(_jeonseDeposit.text);
    final loan = MoneyFormatter.parse(_jeonseLoan.text);

    final loanError = Validators.loanNotExceedDeposit(loan, deposit);
    if (loanError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loanError), backgroundColor: AppColors.danger),
      );
      return;
    }

    final input = RentCompareInput(
      jeonseDeposit: deposit,
      jeonseLoan: loan,
      interestRate: double.parse(_interestRate.text),
      monthlyRentDeposit: MoneyFormatter.parse(_rentDeposit.text),
      monthlyRent: MoneyFormatter.parse(_monthlyRent.text),
      maintenanceFee: MoneyFormatter.parse(_maintenance.text),
      months: int.parse(_months.text),
    );

    ref.read(rentCompareControllerProvider.notifier).calculate(input);
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(rentCompareControllerProvider);
    if (result == null) return;

    final store = CalculationHistoryStore();
    await store.init();

    final history = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      typeIndex: CalculationType.rentCompare.index,
      title: '전세 vs 월세 비교',
      summary: result.recommendationText,
      input: {
        'jeonseDeposit': MoneyFormatter.parse(_jeonseDeposit.text),
        'jeonseLoan': MoneyFormatter.parse(_jeonseLoan.text),
        'interestRate': double.tryParse(_interestRate.text) ?? 0,
        'monthlyRent': MoneyFormatter.parse(_monthlyRent.text),
        'maintenanceFee': MoneyFormatter.parse(_maintenance.text),
        'months': int.tryParse(_months.text) ?? 0,
      },
      result: {
        'jeonseMonthlyCost': result.jeonseMonthlyCost,
        'rentMonthlyCost': result.rentMonthlyCost,
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
    final result = ref.read(rentCompareControllerProvider);
    if (result == null) return;

    final text = '''[집돈계산기] 전세 vs 월세 비교 결과

${result.recommendationText}

전세 월 비용: ${MoneyFormatter.formatWithWon(result.jeonseMonthlyCost)}
월세 월 비용: ${MoneyFormatter.formatWithWon(result.rentMonthlyCost)}
월 차이: ${MoneyFormatter.formatWithWon(result.monthlyDifference.abs())}
${_months.text}개월 총 차이: ${MoneyFormatter.formatWithWon(result.totalDifference.abs())}

※ 본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.''';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(rentCompareControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('전세 vs 월세 비교')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('전세 조건'),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전세 보증금',
                    controller: _jeonseDeposit,
                    focusNode: _fn1,
                    nextFocusNode: _fn2,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전세대출 금액',
                    controller: _jeonseLoan,
                    focusNode: _fn2,
                    nextFocusNode: _fn3,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  PercentInputField(
                    label: '전세대출 연이율',
                    controller: _interestRate,
                    focusNode: _fn3,
                    nextFocusNode: _fn4,
                    validator: Validators.interestRate,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('월세 조건'),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세 보증금',
                    controller: _rentDeposit,
                    focusNode: _fn4,
                    nextFocusNode: _fn5,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세',
                    controller: _monthlyRent,
                    focusNode: _fn5,
                    nextFocusNode: _fn6,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '관리비',
                    controller: _maintenance,
                    focusNode: _fn6,
                    nextFocusNode: _fn7,
                    validator: Validators.requiredAmount,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('거주 기간'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _months,
                    focusNode: _fn7,
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
              RentCompareResultCard(
                result: result,
                onSave: _save,
                onShare: _share,
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
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
