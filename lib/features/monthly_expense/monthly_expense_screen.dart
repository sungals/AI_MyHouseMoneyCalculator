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
import '../../l10n/gen/app_localizations.dart';
import '../../providers/calculation_history_provider.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/monthly_expense_input.dart';
import '../../domain/entities/monthly_expense_result.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/help_icon.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';
import 'monthly_expense_controller.dart';

class MonthlyExpenseScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialInput;

  const MonthlyExpenseScreen({super.key, this.initialInput});

  @override
  ConsumerState<MonthlyExpenseScreen> createState() =>
      _MonthlyExpenseScreenState();
}

class _MonthlyExpenseScreenState extends ConsumerState<MonthlyExpenseScreen> {
  final _resultScreenshotController = ScreenshotController();
  final _housing = TextEditingController();
  final _maintenance = TextEditingController();
  final _communication = TextEditingController();
  final _transportation = TextEditingController();
  final _insurance = TextEditingController();
  final _subscription = TextEditingController();
  final _food = TextEditingController();
  final _other = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyInitialInput(widget.initialInput);
  }

  void _applyInitialInput(Map<String, dynamic>? input) {
    if (input == null) return;
    _setMoney(_housing, input['주거비']);
    _setMoney(_maintenance, input['관리비']);
    _setMoney(_communication, input['통신비']);
    _setMoney(_transportation, input['교통비']);
    _setMoney(_insurance, input['보험료']);
    _setMoney(_subscription, input['구독료']);
    _setMoney(_food, input['식비']);
    _setMoney(_other, input['기타']);
  }

  void _setMoney(TextEditingController controller, Object? value) {
    final amount = _intValue(value);
    if (amount == null || amount <= 0) return;
    controller.text = MoneyFormatter.format(amount);
  }

  int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.replaceAll(',', ''));
    return null;
  }

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

    final l10n = AppLocalizations.of(context);
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();

    final history = CalculationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      typeIndex: CalculationType.monthlyExpense.index,
      // 계약서 §10: 저장 값은 지역화하지 않는다. 이력 화면이 title/summary/input을
      // 그대로 표시하므로 로케일과 무관하게 한국어 표기를 유지한다.
      title: CalculationType.monthlyExpense.label,
      summary: '$_koMonthlyTotalLabel '
          '${MoneyFormatter.formatWithWon(result.totalMonthly)}',
      input: Map.fromEntries(
        result.breakdown.entries
            .map((e) => MapEntry(e.key.storageLabel, e.value)),
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
        SnackBar(content: Text(l10n.monthlyExpenseSaved)),
      );
    }
  }

  void _share() {
    final result = ref.read(monthlyExpenseControllerProvider);
    if (result == null) return;

    final l10n = AppLocalizations.of(context);
    final lines = <String>[
      l10n.monthlyExpenseShareHeader(l10n.appTitle),
      '',
      for (final e in result.breakdown.entries)
        if (e.value > 0)
          l10n.monthlyExpenseShareLine(
            e.key.displayLabel(l10n),
            MoneyFormatter.formatWithWon(e.value),
          ),
      '',
      l10n.monthlyExpenseShareMonthlyTotal(
        MoneyFormatter.formatWithWon(result.totalMonthly),
      ),
      l10n.monthlyExpenseShareAnnualTotal(
        MoneyFormatter.formatWithWon(result.totalAnnual),
      ),
      '',
      l10n.monthlyExpenseShareDisclaimer,
    ];

    ShareHelper.shareText(
      context,
      text: lines.join('\n'),
      subject: l10n.monthlyExpenseShareSubject,
      title: l10n.monthlyExpenseShareSubject,
    );
  }

  Future<void> _exportPdf() async {
    final result = ref.read(monthlyExpenseControllerProvider);
    if (result == null) return;

    final l10n = AppLocalizations.of(context);
    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    // 계약서 §7: 문서 틀(kKoreanPdfExportLabels)은 pdf* 키가 S10에 있어 Phase 2까지
    // 한국어 고정이다. 본문 항목은 이 슬라이스 소유이므로 지역화한다.
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: l10n.monthlyExpenseShareSubject,
      summary: l10n.monthlyExpenseShareMonthlyTotal(
        MoneyFormatter.formatWithWon(result.totalMonthly),
      ),
      resultImageBytes: imageBytes,
      input: {
        for (final entry in result.breakdown.entries)
          if (entry.value > 0)
            entry.key.displayLabel(l10n):
                MoneyFormatter.formatWithWon(entry.value),
      },
      result: {
        l10n.monthlyExpenseMonthlyTotalLabel:
            MoneyFormatter.formatWithWon(result.totalMonthly),
        l10n.monthlyExpenseAnnualTotalLabel:
            MoneyFormatter.formatWithWon(result.totalAnnual),
      },
    );
  }

  Future<Uint8List?> _captureResultImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _resultScreenshotController.capture(pixelRatio: 3.0);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(monthlyExpenseControllerProvider);
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.monthlyExpenseTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _SectionTitle(
              l10n.monthlyExpenseSectionTitle,
              helpTitle: l10n.monthlyExpenseHelpTitle,
              helpBody: l10n.monthlyExpenseHelpBody,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _ExpenseField(
                    label: l10n.monthlyExpenseHousingFieldLabel,
                    controller: _housing,
                    sliderMax: 3000000,
                    sliderDivisions: 60),
                _ExpenseField(
                    label: l10n.monthlyExpenseCategoryMaintenance,
                    controller: _maintenance,
                    sliderMax: 500000,
                    sliderDivisions: 50),
                _ExpenseField(
                    label: l10n.monthlyExpenseCategoryCommunication,
                    controller: _communication,
                    sliderMax: 300000,
                    sliderDivisions: 60),
                _ExpenseField(
                    label: l10n.monthlyExpenseCategoryTransportation,
                    controller: _transportation,
                    sliderMax: 500000,
                    sliderDivisions: 50),
                _ExpenseField(
                    label: l10n.monthlyExpenseCategoryInsurance,
                    controller: _insurance,
                    sliderMax: 1000000,
                    sliderDivisions: 100),
                _ExpenseField(
                    label: l10n.monthlyExpenseCategorySubscription,
                    controller: _subscription,
                    sliderMax: 200000,
                    sliderDivisions: 40),
                _ExpenseField(
                    label: l10n.monthlyExpenseCategoryFood,
                    controller: _food,
                    sliderMax: 2000000,
                    sliderDivisions: 40),
                _ExpenseField(
                  label: l10n.monthlyExpenseCategoryOther,
                  controller: _other,
                  textInputAction: TextInputAction.done,
                  sliderMax: 1000000,
                  sliderDivisions: 100,
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
                label: l10n.monthlyExpenseCalculate, onPressed: _calculate),
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
                      Text(l10n.monthlyExpenseResultTitle,
                          style: typography.bodySecondary),
                      const SizedBox(height: 16),
                      ...result.breakdown.entries
                          .where((e) => e.value > 0)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key.displayLabel(l10n),
                                        style: typography.bodySecondary),
                                    Text(
                                      MoneyFormatter.formatWithWon(e.value),
                                      style: typography.body
                                          .copyWith(fontSize: 14),
                                    ),
                                  ],
                                ),
                              )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.monthlyExpenseMonthlyTotalLabel,
                              style: typography.body
                                  .copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            MoneyFormatter.formatWithWon(result.totalMonthly),
                            style: typography.body.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: palette.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.monthlyExpenseAnnualTotalLabel,
                              style: typography.bodySecondary),
                          Text(
                            MoneyFormatter.formatWithWon(result.totalAnnual),
                            style: typography.body
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
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
const String _koMonthlyTotalLabel = '월 합계';

extension _MonthlyExpenseCategoryLabel on MonthlyExpenseCategory {
  /// 화면·공유 문구에 쓰는 지역화 라벨.
  String displayLabel(AppLocalizations l10n) {
    switch (this) {
      case MonthlyExpenseCategory.housing:
        return l10n.monthlyExpenseCategoryHousing;
      case MonthlyExpenseCategory.maintenance:
        return l10n.monthlyExpenseCategoryMaintenance;
      case MonthlyExpenseCategory.communication:
        return l10n.monthlyExpenseCategoryCommunication;
      case MonthlyExpenseCategory.transportation:
        return l10n.monthlyExpenseCategoryTransportation;
      case MonthlyExpenseCategory.insurance:
        return l10n.monthlyExpenseCategoryInsurance;
      case MonthlyExpenseCategory.subscription:
        return l10n.monthlyExpenseCategorySubscription;
      case MonthlyExpenseCategory.food:
        return l10n.monthlyExpenseCategoryFood;
      case MonthlyExpenseCategory.other:
        return l10n.monthlyExpenseCategoryOther;
    }
  }

  /// Hive 이력과 한국어 고정 PDF에 쓰는 키. 계약서 §7·§10에 따라 한국어를 유지한다.
  /// 값을 바꾸면 이미 저장된 이력과 표기가 어긋난다.
  String get storageLabel {
    switch (this) {
      case MonthlyExpenseCategory.housing:
        return '주거비';
      case MonthlyExpenseCategory.maintenance:
        return '관리비';
      case MonthlyExpenseCategory.communication:
        return '통신비';
      case MonthlyExpenseCategory.transportation:
        return '교통비';
      case MonthlyExpenseCategory.insurance:
        return '보험료';
      case MonthlyExpenseCategory.subscription:
        return '구독료';
      case MonthlyExpenseCategory.food:
        return '식비';
      case MonthlyExpenseCategory.other:
        return '기타';
    }
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
