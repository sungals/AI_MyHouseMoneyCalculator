import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/number_format_extension.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/pdf_export_labels_ko.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/tax_deduction_input.dart';
import '../../domain/entities/tax_deduction_result.dart';
import '../../l10n/gen/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context);
    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    // 계약서 §7: 문서 틀(kKoreanPdfExportLabels)은 pdf* 키가 S10에 있어 Phase 2까지
    // 한국어 고정이다. 본문 항목은 이 슬라이스 소유이므로 지역화한다.
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: l10n.taxDeductionPdfTitle,
      summary: _messageText(result, l10n),
      resultImageBytes: imageBytes,
      input: {
        l10n.taxDeductionAnnualSalaryLabel: MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_annualSalary.text)),
        l10n.taxDeductionIncomeTaxRateLabel:
            '${_incomeTaxRate.toStringAsFixed(0)}%',
        l10n.taxDeductionMonthlyRentLabel: MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_monthlyRent.text)),
        l10n.taxDeductionAnnualRepaymentLabel: MoneyFormatter.formatWithWon(
          MoneyFormatter.parse(_annualLoanRepayment.text),
        ),
      },
      result: {
        // 공제율이 0%면 공제 대상 연 월세가 계산은 되지만 실제로 공제되는 금액이
        // 아니다. 결과 카드와 같은 조건으로 걸러 오해를 막는다.
        if (result.rentTaxCredit > 0) ...{
          l10n.taxDeductionPdfRentRate: '${result.rentDeductionRate}%',
          l10n.taxDeductionEligibleAnnualRentLabel:
              result.eligibleAnnualRent.wonFormat,
          l10n.taxDeductionPdfRentTaxCredit: result.rentTaxCredit.wonFormat,
        },
        if (result.loanTaxSaving > 0) ...{
          l10n.taxDeductionEligibleRepaymentLabel:
              result.eligibleRepayment.wonFormat,
          l10n.taxDeductionIncomeDeductionLabel:
              result.incomeDeductionAmount.wonFormat,
          l10n.taxDeductionPdfLoanTaxSaving: result.loanTaxSaving.wonFormat,
        },
        l10n.taxDeductionTotalBenefitLabel: result.totalTaxBenefit.wonFormat,
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
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.taxDeductionTitle)),
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
                  _SectionTitle(l10n.taxDeductionIncomeSection),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: l10n.taxDeductionAnnualSalaryLabel,
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
                    label: l10n.taxDeductionIncomeTaxRateLabel,
                    value: _incomeTaxRate,
                    min: 6.0,
                    max: 45.0,
                    divisions: 39,
                    onChanged: (v) => setState(() => _incomeTaxRate = v),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(l10n.taxDeductionRentSection),
                  const SizedBox(height: 4),
                  Text(
                    l10n.taxDeductionRentRateGuide,
                    style: typography.caption,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: l10n.taxDeductionMonthlyRentLabel,
                    controller: _monthlyRent,
                    focusNode: _fn2,
                    nextFocusNode: _fn3,
                    showQuickButtons: true,
                    sliderMax: 3000000,
                    sliderDivisions: 60,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(l10n.taxDeductionLoanSection),
                  const SizedBox(height: 4),
                  Text(
                    l10n.taxDeductionLoanGuide,
                    style: typography.caption,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: l10n.taxDeductionAnnualRepaymentLabel,
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
            PrimaryButton(
                label: l10n.taxDeductionCalculate, onPressed: _calculate),
            if (result != null) ...[
              const SizedBox(height: 24),
              Screenshot(
                controller: _resultScreenshotController,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _messageText(result, l10n),
                        style: typography.heading3.copyWith(
                          color: result.totalTaxBenefit > 0
                              ? palette.positive
                              : palette.textSecondary,
                        ),
                      ),
                      if (result.rentTaxCredit > 0) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        _ResultSectionTitle(l10n.taxDeductionRentSection),
                        const SizedBox(height: 10),
                        _Row(
                          label: l10n.taxDeductionRentRateRowLabel,
                          value: '${result.rentDeductionRate}%',
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: l10n.taxDeductionEligibleAnnualRentLabel,
                          value: result.eligibleAnnualRent.wonFormat,
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: l10n.taxDeductionRentTaxCreditLabel,
                          value: result.rentTaxCredit.wonFormat,
                          valueColor: palette.positive,
                          isBold: true,
                        ),
                      ],
                      if (result.loanTaxSaving > 0) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        _ResultSectionTitle(l10n.taxDeductionLoanResultSection),
                        const SizedBox(height: 10),
                        _Row(
                          label: l10n.taxDeductionEligibleRepaymentLabel,
                          value: result.eligibleRepayment.wonFormat,
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: l10n.taxDeductionIncomeDeductionLabel,
                          value: result.incomeDeductionAmount.wonFormat,
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          label: l10n.taxDeductionLoanTaxSavingLabel(
                              _incomeTaxRate.toStringAsFixed(0)),
                          value: result.loanTaxSaving.wonFormat,
                          valueColor: palette.positive,
                          isBold: true,
                        ),
                      ],
                      if (result.totalTaxBenefit > 0) ...[
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        _Row(
                          label: l10n.taxDeductionTotalBenefitLabel,
                          value: result.totalTaxBenefit.wonFormat,
                          valueColor: palette.primary,
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

String _messageText(TaxDeductionResult result, AppLocalizations l10n) {
  switch (result.message) {
    case TaxDeductionMessage.incomeTooHighForRentTaxCredit:
      // 계산기는 "월세 공제 대상 아님"만 알려준다. 전세대출 절세액이 있으면
      // 그 문구만 보여줄 경우 아래 결과 행과 앞뒤가 맞지 않으므로 함께 말한다.
      if (result.loanTaxSaving > 0) {
        return l10n.taxDeductionMessageIncomeTooHighWithLoan(
          MoneyFormatter.formatWithWon(result.loanTaxSaving),
        );
      }
      return l10n.taxDeductionMessageIncomeTooHigh;
    case TaxDeductionMessage.hasTaxBenefit:
      return l10n.taxDeductionMessageHasBenefit(
        MoneyFormatter.formatWithWon(result.totalTaxBenefit),
      );
    case TaxDeductionMessage.noDeductionInput:
      return l10n.taxDeductionMessageNoInput;
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.label.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
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
      style: context.typography.label.copyWith(fontWeight: FontWeight.w600),
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
    final palette = context.palette;
    final typography = context.typography;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: typography.bodySecondary),
        Text(
          value,
          style: isBold
              ? typography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? palette.textPrimary,
                )
              : typography.body.copyWith(
                  color: valueColor ?? palette.textPrimary,
                ),
        ),
      ],
    );
  }
}
