import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/number_format_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/tax_deduction_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';
import '../../shared/widgets/slider_rate_field.dart';
import 'tax_deduction_controller.dart';

class TaxDeductionScreen extends ConsumerStatefulWidget {
  const TaxDeductionScreen({super.key});

  @override
  ConsumerState<TaxDeductionScreen> createState() => _TaxDeductionScreenState();
}

class _TaxDeductionScreenState extends ConsumerState<TaxDeductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();

  final _annualSalary = TextEditingController();
  final _monthlyRent = TextEditingController();
  final _annualLoanRepayment = TextEditingController();

  final _fn1 = FocusNode();
  final _fn2 = FocusNode();
  final _fn3 = FocusNode();

  double _incomeTaxRate = 15.0;

  @override
  void dispose() {
    _annualSalary.dispose();
    _monthlyRent.dispose();
    _annualLoanRepayment.dispose();
    _fn1.dispose();
    _fn2.dispose();
    _fn3.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final input = TaxDeductionInput(
      annualSalary: MoneyFormatter.parse(_annualSalary.text),
      monthlyRent: MoneyFormatter.parse(_monthlyRent.text),
      annualLoanRepayment: MoneyFormatter.parse(_annualLoanRepayment.text),
      incomeTaxRate: _incomeTaxRate,
    );

    ref.read(taxDeductionControllerProvider.notifier).calculate(input);
    FocusScope.of(context).unfocus();
  }

  Future<void> _exportPdf() async {
    final result = ref.read(taxDeductionControllerProvider);
    if (result == null) return;

    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    await CalculationPdfExporter.share(
      context,
      title: '연말정산 세액공제 결과',
      summary: result.message,
      resultImageBytes: imageBytes,
      input: {
        '연간 총급여': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_annualSalary.text)),
        '소득세율': '${_incomeTaxRate.toStringAsFixed(0)}%',
        '월세': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_monthlyRent.text)),
        '연간 원리금 상환액': MoneyFormatter.formatWithWon(
          MoneyFormatter.parse(_annualLoanRepayment.text),
        ),
      },
      result: {
        '월세 공제율': '${result.rentDeductionRate}%',
        '공제 대상 연 월세': result.eligibleAnnualRent.wonFormat,
        '월세 세액공제': result.rentTaxCredit.wonFormat,
        '공제 대상 상환액': result.eligibleRepayment.wonFormat,
        '전세대출 절세액': result.loanTaxSaving.wonFormat,
        '연간 총 절세 혜택': result.totalTaxBenefit.wonFormat,
      },
    );
  }

  Future<Uint8List?> _captureResultImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _resultScreenshotController.capture(pixelRatio: 3.0);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(taxDeductionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('연말정산 세액공제')),
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
                  const _SectionTitle('소득 정보'),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '연간 총급여',
                    controller: _annualSalary,
                    focusNode: _fn1,
                    nextFocusNode: _fn2,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 200000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 20),
                  SliderRateField(
                    label: '소득세율 (과세표준 기준)',
                    value: _incomeTaxRate,
                    min: 6.0,
                    max: 45.0,
                    divisions: 39,
                    onChanged: (v) => setState(() => _incomeTaxRate = v),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('월세 세액공제'),
                  const SizedBox(height: 4),
                  const Text(
                    '총급여 5,500만원 이하 17% / 7,000만원 이하 15% / 초과 0%',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세 (월)',
                    controller: _monthlyRent,
                    focusNode: _fn2,
                    nextFocusNode: _fn3,
                    showQuickButtons: true,
                    sliderMax: 3000000,
                    sliderDivisions: 60,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('전세대출 원리금 소득공제'),
                  const SizedBox(height: 4),
                  const Text(
                    '연 상환액의 40% 소득공제, 연 400만원 한도',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '연간 원리금 상환액',
                    controller: _annualLoanRepayment,
                    focusNode: _fn3,
                    textInputAction: TextInputAction.done,
                    showQuickButtons: true,
                    sliderMax: 40000000,
                    sliderDivisions: 80,
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
                      Text(
                        result.message,
                        style: AppTextStyles.heading3.copyWith(
                          color: result.totalTaxBenefit > 0
                              ? AppColors.positive
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (result.rentTaxCredit > 0) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        const _ResultSectionTitle('월세 세액공제'),
                        const SizedBox(height: 10),
                        _Row(
                          label: '공제율',
                          value: '${result.rentDeductionRate}%',
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: '공제 대상 연 월세',
                          value: result.eligibleAnnualRent.wonFormat,
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: '세액공제액',
                          value: result.rentTaxCredit.wonFormat,
                          valueColor: AppColors.positive,
                          isBold: true,
                        ),
                      ],
                      if (result.loanTaxSaving > 0) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        const _ResultSectionTitle('전세대출 소득공제'),
                        const SizedBox(height: 10),
                        _Row(
                          label: '공제 대상 상환액',
                          value: result.eligibleRepayment.wonFormat,
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: '소득공제액 (40%)',
                          value: result.incomeDeductionAmount.wonFormat,
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label:
                              '절세액 (세율 ${_incomeTaxRate.toStringAsFixed(0)}%)',
                          value: result.loanTaxSaving.wonFormat,
                          valueColor: AppColors.positive,
                          isBold: true,
                        ),
                      ],
                      if (result.totalTaxBenefit > 0) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        _Row(
                          label: '연간 총 절세 혜택',
                          value: result.totalTaxBenefit.wonFormat,
                          valueColor: AppColors.primary,
                          isBold: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ResultActionButtons(
                onExportPdf: _exportPdf,
              ),
            ],
            const SizedBox(height: 16),
            const DisclaimerBox(),
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

class _ResultSectionTitle extends StatelessWidget {
  final String text;
  const _ResultSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
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
        Text(label, style: AppTextStyles.bodySecondary),
        Text(
          value,
          style: isBold
              ? AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                )
              : AppTextStyles.body.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
