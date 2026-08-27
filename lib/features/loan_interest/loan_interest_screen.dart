import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/pdf_export_labels_ko.dart';
import '../../core/utils/share_helper.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/validation_error_l10n.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/calculation_history_provider.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/loan_interest_input.dart';
import '../../domain/entities/loan_interest_result.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/help_icon.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';
import 'loan_interest_controller.dart';

class LoanInterestScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialInput;

  const LoanInterestScreen({super.key, this.initialInput});

  @override
  ConsumerState<LoanInterestScreen> createState() => _LoanInterestScreenState();
}

class _LoanInterestScreenState extends ConsumerState<LoanInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();
  final _loanAmount = TextEditingController();
  final _interestRate = TextEditingController();
  final _months = TextEditingController();
  LoanInterestRepaymentMethod _repaymentMethod =
      LoanInterestRepaymentMethod.interestOnly;

  @override
  void initState() {
    super.initState();
    _applyInitialInput(widget.initialInput);
  }

  void _applyInitialInput(Map<String, dynamic>? input) {
    if (input == null) return;
    _setMoney(_loanAmount, input['loanAmount']);
    _setText(_interestRate, input['interestRate']);
    _setText(_months, input['months']);
    _repaymentMethod = _methodFromInput(input['repaymentMethod']);
  }

  void _setMoney(TextEditingController controller, Object? value) {
    final amount = _intValue(value);
    if (amount == null || amount <= 0) return;
    controller.text = MoneyFormatter.format(amount);
  }

  void _setText(TextEditingController controller, Object? value) {
    if (value == null) return;
    controller.text = value.toString();
  }

  int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.replaceAll(',', ''));
    return null;
  }

  LoanInterestRepaymentMethod _methodFromInput(Object? value) {
    if (value is LoanInterestRepaymentMethod) return value;
    if (value is String) {
      for (final method in LoanInterestRepaymentMethod.values) {
        if (method.name == value) return method;
      }
    }
    return LoanInterestRepaymentMethod.interestOnly;
  }

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
      repaymentMethod: _repaymentMethod,
    );

    ref.read(loanInterestControllerProvider.notifier).calculate(input);
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(loanInterestControllerProvider);
    if (result == null) return;

    final l10n = AppLocalizations.of(context);
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();

    final history = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      typeIndex: CalculationType.loanInterest.index,
      // 계약서 §10: 저장 값은 지역화하지 않는다. 이력 화면이 title/summary를 그대로
      // 표시하므로 로케일과 무관하게 한국어 표기를 유지한다.
      title: CalculationType.loanInterest.label,
      summary: '$_koMonthlyInterestLabel '
          '${MoneyFormatter.formatWithWon(result.monthlyPayment)}',
      input: {
        'loanAmount': result.loanAmount,
        'interestRate': double.tryParse(_interestRate.text) ?? 0,
        'months': result.months,
        'repaymentMethod': result.repaymentMethod.name,
      },
      result: {
        'monthlyInterest': result.monthlyInterest,
        'monthlyPayment': result.monthlyPayment,
        'firstMonthPayment': result.firstMonthPayment,
        'lastMonthPayment': result.lastMonthPayment,
        'totalInterest': result.totalInterest,
        'totalPayment': result.totalPayment,
      },
      createdAt: DateTime.now(),
    );

    await repo.save(history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loanInterestSaved)),
      );
    }
  }

  void _share() {
    final result = ref.read(loanInterestControllerProvider);
    if (result == null) return;

    final l10n = AppLocalizations.of(context);
    final lines = <String>[
      l10n.loanInterestShareHeader(l10n.appTitle),
      '',
      l10n.loanInterestShareLoanAmount(
        MoneyFormatter.formatWithWon(result.loanAmount),
      ),
      l10n.loanInterestShareRepaymentMethod(
        _repaymentMethodLabel(l10n, result.repaymentMethod),
      ),
      l10n.loanInterestShareMonthlyPayment(
        MoneyFormatter.formatWithWon(result.monthlyPayment),
      ),
      if (result.repaymentMethod == LoanInterestRepaymentMethod.equalPrincipal)
        l10n.loanInterestShareLastMonthPayment(
          MoneyFormatter.formatWithWon(result.lastMonthPayment),
        ),
      l10n.loanInterestShareMonthlyInterest(
        MoneyFormatter.formatWithWon(result.monthlyInterest),
      ),
      l10n.loanInterestShareTotalInterest(
        result.months,
        MoneyFormatter.formatWithWon(result.totalInterest),
      ),
      '',
      l10n.loanInterestShareDisclaimer,
    ];

    ShareHelper.shareText(
      context,
      text: lines.join('\n'),
      subject: l10n.loanInterestShareSubject,
      title: l10n.loanInterestShareSubject,
    );
  }

  Future<void> _exportPdf() async {
    final result = ref.read(loanInterestControllerProvider);
    if (result == null) return;

    final l10n = AppLocalizations.of(context);
    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    // 계약서 §7: 문서 틀(kKoreanPdfExportLabels)은 pdf* 키가 S10에 있어 Phase 2까지
    // 한국어 고정이다. 본문 항목은 이 슬라이스 소유이므로 지역화한다.
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: l10n.loanInterestShareSubject,
      summary: l10n.loanInterestShareMonthlyInterest(
        MoneyFormatter.formatWithWon(result.monthlyInterest),
      ),
      resultImageBytes: imageBytes,
      input: {
        l10n.loanInterestAmountLabel:
            MoneyFormatter.formatWithWon(result.loanAmount),
        l10n.loanInterestRateLabel: '${_interestRate.text}%',
        l10n.loanInterestMonthsLabel:
            l10n.loanInterestMonthsValue(result.months),
        l10n.loanInterestRepaymentMethodLabel:
            _repaymentMethodLabel(l10n, result.repaymentMethod),
      },
      result: {
        _monthlyPaymentLabel(l10n, result):
            MoneyFormatter.formatWithWon(result.monthlyPayment),
        if (result.repaymentMethod ==
            LoanInterestRepaymentMethod.equalPrincipal)
          l10n.loanInterestLastMonthPaymentLabel:
              MoneyFormatter.formatWithWon(result.lastMonthPayment),
        l10n.loanInterestMonthlyInterestLabel:
            MoneyFormatter.formatWithWon(result.monthlyInterest),
        l10n.loanInterestTotalInterestLabel(result.months):
            MoneyFormatter.formatWithWon(result.totalInterest),
        l10n.loanInterestTotalPaymentLabel:
            MoneyFormatter.formatWithWon(result.totalPayment),
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
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.loanInterestTitle)),
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
                  _SectionTitle(
                    l10n.loanInterestSectionTitle,
                    helpTitle: l10n.loanInterestHelpTitle,
                    helpBody: l10n.loanInterestHelpBody,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: l10n.loanInterestAmountLabel,
                    controller: _loanAmount,
                    validator: (v) => Validators.requiredAmountCode(v)?.localize(context),
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 12),
                  PercentInputField(
                    label: l10n.loanInterestRateLabel,
                    controller: _interestRate,
                    validator: (v) => Validators.interestRateCode(v)?.localize(context),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<LoanInterestRepaymentMethod>(
                    value: _repaymentMethod,
                    decoration: InputDecoration(
                      labelText: l10n.loanInterestRepaymentMethodLabel,
                    ),
                    items: LoanInterestRepaymentMethod.values
                        .map(
                          (method) => DropdownMenuItem(
                            value: method,
                            child: Text(_repaymentMethodLabel(l10n, method)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _repaymentMethod = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _months,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.monthsCode(v)?.localize(context),
                    decoration: InputDecoration(
                      labelText: l10n.loanInterestMonthsLabel,
                      hintText: l10n.loanInterestMonthsHint,
                      suffixText: l10n.loanInterestMonthsSuffix,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
                label: l10n.loanInterestCalculate, onPressed: _calculate),
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
                      Text(l10n.loanInterestResultTitle,
                          style: typography.bodySecondary),
                      const SizedBox(height: 16),
                      _ResultRow(
                        label: l10n.loanInterestRepaymentMethodLabel,
                        value: _repaymentMethodLabel(
                          l10n,
                          result.repaymentMethod,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ResultRow(
                        label: _monthlyPaymentLabel(l10n, result),
                        value: MoneyFormatter.formatWithWon(
                          result.monthlyPayment,
                        ),
                        isBold: true,
                        valueColor: palette.primary,
                      ),
                      const SizedBox(height: 10),
                      if (result.repaymentMethod ==
                          LoanInterestRepaymentMethod.equalPrincipal) ...[
                        _ResultRow(
                          label: l10n.loanInterestLastMonthPaymentLabel,
                          value: MoneyFormatter.formatWithWon(
                            result.lastMonthPayment,
                          ),
                          isBold: true,
                          valueColor: palette.primary,
                        ),
                        const SizedBox(height: 10),
                      ],
                      _ResultRow(
                        label: l10n.loanInterestMonthlyInterestLabel,
                        value: MoneyFormatter.formatWithWon(
                          result.monthlyInterest,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ResultRow(
                        label:
                            l10n.loanInterestTotalInterestLabel(result.months),
                        value:
                            MoneyFormatter.formatWithWon(result.totalInterest),
                        isBold: true,
                        valueColor: palette.danger,
                      ),
                      const SizedBox(height: 10),
                      _ResultRow(
                        label: l10n.loanInterestTotalPaymentLabel,
                        value:
                            MoneyFormatter.formatWithWon(result.totalPayment),
                        isBold: true,
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

/// 이력 요약에 저장되는 한국어 라벨. 계약서 §10에 따라 지역화하지 않는다.
const String _koMonthlyInterestLabel = '월 이자';

String _repaymentMethodLabel(
  AppLocalizations l10n,
  LoanInterestRepaymentMethod method,
) {
  return switch (method) {
    LoanInterestRepaymentMethod.interestOnly =>
      l10n.loanInterestMethodInterestOnly,
    LoanInterestRepaymentMethod.equalPrincipalAndInterest =>
      l10n.loanInterestMethodEqualPrincipalAndInterest,
    LoanInterestRepaymentMethod.equalPrincipal =>
      l10n.loanInterestMethodEqualPrincipal,
  };
}

String _monthlyPaymentLabel(
  AppLocalizations l10n,
  LoanInterestResult result,
) {
  return switch (result.repaymentMethod) {
    LoanInterestRepaymentMethod.interestOnly =>
      l10n.loanInterestMonthlyInterestLabel,
    LoanInterestRepaymentMethod.equalPrincipalAndInterest =>
      l10n.loanInterestMonthlyPaymentLabel,
    LoanInterestRepaymentMethod.equalPrincipal =>
      l10n.loanInterestFirstMonthPaymentLabel,
  };
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
          style: context.typography.label.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
    final palette = context.palette;
    final typography = context.typography;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: typography.bodySecondary),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: typography.body.copyWith(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
