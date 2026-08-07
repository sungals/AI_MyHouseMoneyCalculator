import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/pdf_export_labels_ko.dart';
import '../../core/utils/share_helper.dart';
import '../../core/utils/validators.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/contract_renewal_input.dart';
import '../../domain/entities/contract_renewal_result.dart';
import '../../providers/calculation_history_provider.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/help_icon.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';
import 'contract_renewal_controller.dart';

class ContractRenewalScreen extends ConsumerStatefulWidget {
  const ContractRenewalScreen({super.key});

  @override
  ConsumerState<ContractRenewalScreen> createState() =>
      _ContractRenewalScreenState();
}

class _ContractRenewalScreenState extends ConsumerState<ContractRenewalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();
  final _currentDeposit = TextEditingController();
  final _currentMonthlyRent = TextEditingController();
  final _increaseRate = TextEditingController(text: '5.0');

  @override
  void dispose() {
    _currentDeposit.dispose();
    _currentMonthlyRent.dispose();
    _increaseRate.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(contractRenewalControllerProvider.notifier).calculate(
          ContractRenewalInput(
            currentDeposit: MoneyFormatter.parse(_currentDeposit.text),
            currentMonthlyRent: MoneyFormatter.parse(_currentMonthlyRent.text),
            increaseRate: double.parse(_increaseRate.text),
          ),
        );
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(contractRenewalControllerProvider);
    if (result == null) return;

    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    await repo.save(
      CalculationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        typeIndex: CalculationType.contractRenewal.index,
        title: '계약 갱신 계산',
        summary: _summaryText(result),
        input: {
          'currentDeposit': result.currentDeposit,
          'currentMonthlyRent': result.currentMonthlyRent,
          'increaseRate': result.increaseRate,
        },
        result: {
          'maxDeposit': result.maxDeposit,
          'maxMonthlyRent': result.maxMonthlyRent,
          'depositIncrease': result.depositIncrease,
          'monthlyRentIncrease': result.monthlyRentIncrease,
        },
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('계산 결과가 저장되었습니다.')),
    );
  }

  void _share() {
    final result = ref.read(contractRenewalControllerProvider);
    if (result == null) return;

    final text = '''[어떤비용] 계약 갱신 계산 결과

${_summaryText(result)}

현재 보증금: ${MoneyFormatter.formatWithWon(result.currentDeposit)}
갱신 보증금 상한: ${MoneyFormatter.formatWithWon(result.maxDeposit)}
현재 월세: ${MoneyFormatter.formatWithWon(result.currentMonthlyRent)}
갱신 월세 상한: ${MoneyFormatter.formatWithWon(result.maxMonthlyRent)}

※ 본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.''';

    ShareHelper.shareText(
      context,
      text: text,
      subject: '계약 갱신 계산 결과',
      title: '계약 갱신 계산 결과',
    );
  }

  Future<void> _exportPdf() async {
    final result = ref.read(contractRenewalControllerProvider);
    if (result == null) return;

    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: '계약 갱신 계산 결과',
      summary: _summaryText(result),
      resultImageBytes: imageBytes,
      input: {
        '현재 보증금': MoneyFormatter.formatWithWon(result.currentDeposit),
        '현재 월세': MoneyFormatter.formatWithWon(result.currentMonthlyRent),
        '증액 상한율': '${result.increaseRate.toStringAsFixed(1)}%',
      },
      result: {
        '갱신 보증금 상한': MoneyFormatter.formatWithWon(result.maxDeposit),
        '보증금 증액분': MoneyFormatter.formatWithWon(result.depositIncrease),
        '갱신 월세 상한': MoneyFormatter.formatWithWon(result.maxMonthlyRent),
        '월세 증액분': MoneyFormatter.formatWithWon(result.monthlyRentIncrease),
      },
    );
  }

  Future<Uint8List?> _captureResultImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _resultScreenshotController.capture(pixelRatio: 3.0);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(contractRenewalControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('계약 갱신 계산')),
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
                    '현재 계약 조건',
                    helpTitle: '계약갱신청구권 5% 상한',
                    helpBody:
                        '계약갱신청구권 행사 시 임대료 증액은 통상 기존 임대료의 5% 범위 안에서 계산합니다.\n\n'
                        '지역 조례나 계약 형태에 따라 세부 판단이 달라질 수 있으므로 실제 계약 전 확인이 필요합니다.',
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '현재 보증금',
                    controller: _currentDeposit,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '현재 월세',
                    controller: _currentMonthlyRent,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 5000000,
                    sliderDivisions: 100,
                  ),
                  const SizedBox(height: 12),
                  PercentInputField(
                    label: '증액 상한율',
                    controller: _increaseRate,
                    validator: Validators.interestRate,
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
                child: _ResultCard(
                  result: result,
                  onShare: _share,
                  onSave: _save,
                  onExportPdf: _exportPdf,
                  showActions: false,
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
        Text(text, style: AppTextStyles.label),
        if (helpTitle != null) ...[
          const SizedBox(width: 4),
          HelpIcon(title: helpTitle!, body: helpBody!),
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final dynamic result;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onExportPdf;
  final bool showActions;

  const _ResultCard({
    required this.result,
    required this.onShare,
    required this.onSave,
    required this.onExportPdf,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(_summaryText(result), style: AppTextStyles.heading3),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _Row(
                label: '보증금 상한',
                value: MoneyFormatter.formatWithWon(result.maxDeposit as int),
                subValue:
                    '+${MoneyFormatter.formatWithWon(result.depositIncrease as int)}',
              ),
              const SizedBox(height: 12),
              _Row(
                label: '월세 상한',
                value:
                    MoneyFormatter.formatWithWon(result.maxMonthlyRent as int),
                subValue:
                    '+${MoneyFormatter.formatWithWon(result.monthlyRentIncrease as int)}',
              ),
            ],
          ),
        ),
        if (showActions) ...[
          const SizedBox(height: 12),
          const DisclaimerBox(),
          const SizedBox(height: 16),
          ResultActionButtons(
            onShare: onShare,
            onSave: onSave,
            onExportPdf: onExportPdf,
          ),
        ],
      ],
    );
  }
}

String _summaryText(ContractRenewalResult result) {
  switch (result.summaryText) {
    case ContractRenewalSummary.renewalClaimIncreaseLimitApplied:
      return '갱신청구권 행사 시 ${result.increaseRate.toStringAsFixed(1)}% 상한 기준으로 '
          '보증금은 최대 ${MoneyFormatter.formatWithWon(result.maxDeposit)}, '
          '월세는 최대 ${MoneyFormatter.formatWithWon(result.maxMonthlyRent)}까지 계산됩니다.';
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;

  const _Row({
    required this.label,
    required this.value,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(subValue, style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}
