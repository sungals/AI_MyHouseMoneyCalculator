import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/pdf_export_labels_ko.dart';
import '../../core/utils/share_helper.dart';
import '../../core/utils/validators.dart';
import '../../providers/calculation_history_provider.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/loan_interest_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/help_icon.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';
import 'loan_interest_controller.dart';

class LoanInterestScreen extends ConsumerStatefulWidget {
  const LoanInterestScreen({super.key});

  @override
  ConsumerState<LoanInterestScreen> createState() => _LoanInterestScreenState();
}

class _LoanInterestScreenState extends ConsumerState<LoanInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();
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

    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();

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

    await repo.save(history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계산 결과가 저장되었습니다.')),
      );
    }
  }

  void _share() {
    final result = ref.read(loanInterestControllerProvider);
    if (result == null) return;

    final text = '''[어떤비용] 대출이자 계산 결과

대출금: ${MoneyFormatter.formatWithWon(result.loanAmount)}
월 이자: ${MoneyFormatter.formatWithWon(result.monthlyInterest)}
${result.months}개월 총 이자: ${MoneyFormatter.formatWithWon(result.totalInterest)}

※ 본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.''';

    ShareHelper.shareText(
      context,
      text: text,
      subject: '대출이자 계산 결과',
      title: '대출이자 계산 결과',
    );
  }

  Future<void> _exportPdf() async {
    final result = ref.read(loanInterestControllerProvider);
    if (result == null) return;

    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: '대출이자 계산 결과',
      summary: '월 이자 ${MoneyFormatter.formatWithWon(result.monthlyInterest)}',
      resultImageBytes: imageBytes,
      input: {
        '대출금': MoneyFormatter.formatWithWon(result.loanAmount),
        '연이율': '${_interestRate.text}%',
        '대출 기간': '${result.months}개월',
      },
      result: {
        '월 이자': MoneyFormatter.formatWithWon(result.monthlyInterest),
        '${result.months}개월 총 이자':
            MoneyFormatter.formatWithWon(result.totalInterest),
      },
    );
  }

  Future<Uint8List?> _captureResultImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _resultScreenshotController.capture(pixelRatio: 3.0);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    '대출 조건',
                    helpTitle: '대출이자 계산이란?',
                    helpBody: '단리(이자만 납부) 방식으로 월 이자와 총 이자를 계산합니다.\n\n'
                        '• 대출금: 은행에서 빌리는 원금\n'
                        '• 연이율: 연간 적용 이자율 (예: 4.5%)\n'
                        '• 대출 기간: 이자를 납부할 기간 (개월)\n\n'
                        '월 이자 = 대출금 × 연이율 ÷ 12\n'
                        '총 이자 = 월 이자 × 대출 기간\n\n'
                        '원리금 균등 상환(원금도 함께 갚는 방식)과는\n'
                        '계산 방법이 다릅니다.',
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '대출금',
                    controller: _loanAmount,
                    validator: Validators.requiredAmount,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
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
              Screenshot(
                controller: _resultScreenshotController,
                child: Container(
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
                        value: MoneyFormatter.formatWithWon(
                            result.monthlyInterest),
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      _ResultRow(
                        label: '${result.months}개월 총 이자',
                        value:
                            MoneyFormatter.formatWithWon(result.totalInterest),
                        isBold: true,
                        valueColor: AppColors.danger,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const DisclaimerBox(),
              const SizedBox(height: 16),
              ResultActionButtons(
                onShare: _share,
                onSave: _save,
                onExportPdf: _exportPdf,
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
            style:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
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
