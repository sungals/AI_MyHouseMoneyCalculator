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
import '../../domain/entities/jeonse_risk_input.dart';
import '../../domain/entities/jeonse_risk_result.dart';
import '../../providers/calculation_history_provider.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/help_icon.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';
import 'jeonse_risk_controller.dart';
import 'jeonse_risk_localizations.dart';

class JeonseRiskScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialInput;

  const JeonseRiskScreen({super.key, this.initialInput});

  @override
  ConsumerState<JeonseRiskScreen> createState() => _JeonseRiskScreenState();
}

class _JeonseRiskScreenState extends ConsumerState<JeonseRiskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();
  final _marketPrice = TextEditingController();
  final _deposit = TextEditingController();
  final _seniorDebt = TextEditingController();

  bool _checkedRegistry = false;
  bool _ownerMatched = false;
  bool _checkedTaxArrears = false;
  bool _canJoinGuaranteeInsurance = false;
  bool _willReportMoveIn = true;
  bool _willGetFixedDate = true;

  @override
  void initState() {
    super.initState();
    _applyInitialInput(widget.initialInput);
  }

  void _applyInitialInput(Map<String, dynamic>? input) {
    if (input == null) return;
    _setMoney(_marketPrice, input['marketPrice']);
    _setMoney(_deposit, input['deposit']);
    _setMoney(_seniorDebt, input['seniorDebt']);
    _checkedRegistry = _boolValue(input['checkedRegistry']) ?? _checkedRegistry;
    _ownerMatched = _boolValue(input['ownerMatched']) ?? _ownerMatched;
    _checkedTaxArrears =
        _boolValue(input['checkedTaxArrears']) ?? _checkedTaxArrears;
    _canJoinGuaranteeInsurance =
        _boolValue(input['canJoinGuaranteeInsurance']) ??
            _canJoinGuaranteeInsurance;
    _willReportMoveIn =
        _boolValue(input['willReportMoveIn']) ?? _willReportMoveIn;
    _willGetFixedDate =
        _boolValue(input['willGetFixedDate']) ?? _willGetFixedDate;
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

  bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }

  @override
  void dispose() {
    _marketPrice.dispose();
    _deposit.dispose();
    _seniorDebt.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(jeonseRiskControllerProvider.notifier).calculate(
          JeonseRiskInput(
            marketPrice: MoneyFormatter.parse(_marketPrice.text),
            deposit: MoneyFormatter.parse(_deposit.text),
            seniorDebt: MoneyFormatter.parse(_seniorDebt.text),
            checkedRegistry: _checkedRegistry,
            ownerMatched: _ownerMatched,
            checkedTaxArrears: _checkedTaxArrears,
            canJoinGuaranteeInsurance: _canJoinGuaranteeInsurance,
            willReportMoveIn: _willReportMoveIn,
            willGetFixedDate: _willGetFixedDate,
          ),
        );
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(jeonseRiskControllerProvider);
    if (result == null) return;

    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    await repo.save(
      CalculationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        typeIndex: CalculationType.jeonseRisk.index,
        title: '전세사기 위험도 체크',
        summary: JeonseRiskLocalizations.summaryText(result),
        input: _inputForHistory(),
        result: {
          'riskScore': result.score,
          'riskLevel': JeonseRiskLocalizations.levelLabel(result.level),
          'jeonseRatio': result.jeonseRatio,
          'seniorDebtRatio': result.seniorDebtRatio,
          'combinedDebtRatio': result.combinedDebtRatio,
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
    final result = ref.read(jeonseRiskControllerProvider);
    if (result == null) return;

    final warnings = result.warnings.isEmpty
        ? '큰 위험 신호 없음'
        : result.warnings
            .map((item) => '- ${JeonseRiskLocalizations.warningText(item)}')
            .join('\n');
    final text = '''[어떤비용] 전세사기 위험도 체크 결과

${JeonseRiskLocalizations.summaryText(result)}
전세가율: ${result.jeonseRatio.toStringAsFixed(1)}%
선순위채권 비율: ${result.seniorDebtRatio.toStringAsFixed(1)}%
보증금+선순위채권 비율: ${result.combinedDebtRatio.toStringAsFixed(1)}%

$warnings

권장 조치
${result.actionItems.map((item) => '- ${JeonseRiskLocalizations.actionText(item)}').join('\n')}

※ 본 체크는 참고용입니다. 계약 전 등기부, 세금 체납, 보증보험, 전문가 확인이 필요합니다.''';

    ShareHelper.shareText(
      context,
      text: text,
      subject: '전세사기 위험도 체크 결과',
      title: '전세사기 위험도 체크 결과',
    );
  }

  Future<void> _exportPdf() async {
    final result = ref.read(jeonseRiskControllerProvider);
    if (result == null) return;

    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: '전세사기 위험도 체크 결과',
      summary: JeonseRiskLocalizations.summaryText(result),
      resultImageBytes: imageBytes,
      input: {
        '주택 예상 시세': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_marketPrice.text)),
        '전세 보증금':
            MoneyFormatter.formatWithWon(MoneyFormatter.parse(_deposit.text)),
        '선순위채권/근저당': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_seniorDebt.text)),
        '등기부 확인': _checkedRegistry ? '예' : '아니오',
        '소유자 일치': _ownerMatched ? '예' : '아니오',
        '세금 체납 확인': _checkedTaxArrears ? '예' : '아니오',
        '보증보험 가능': _canJoinGuaranteeInsurance ? '예' : '아니오',
      },
      result: {
        '위험 점수': '${result.score}점',
        '위험 등급': JeonseRiskLocalizations.levelLabel(result.level),
        '전세가율': '${result.jeonseRatio.toStringAsFixed(1)}%',
        '선순위채권 비율': '${result.seniorDebtRatio.toStringAsFixed(1)}%',
        '보증금+선순위채권 비율': '${result.combinedDebtRatio.toStringAsFixed(1)}%',
        '주요 경고': result.warnings.isEmpty
            ? '큰 위험 신호 없음'
            : result.warnings
                .map((w) => JeonseRiskLocalizations.warningText(w))
                .join(' / '),
        '권장 조치': result.actionItems
            .map((a) => JeonseRiskLocalizations.actionText(a))
            .join(' / '),
      },
    );
  }

  Future<Uint8List?> _captureResultImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _resultScreenshotController.capture(pixelRatio: 3.0);
  }

  Map<String, dynamic> _inputForHistory() {
    return {
      'marketPrice': MoneyFormatter.parse(_marketPrice.text),
      'deposit': MoneyFormatter.parse(_deposit.text),
      'seniorDebt': MoneyFormatter.parse(_seniorDebt.text),
      'checkedRegistry': _checkedRegistry,
      'ownerMatched': _ownerMatched,
      'checkedTaxArrears': _checkedTaxArrears,
      'canJoinGuaranteeInsurance': _canJoinGuaranteeInsurance,
      'willReportMoveIn': _willReportMoveIn,
      'willGetFixedDate': _willGetFixedDate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(jeonseRiskControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('전세사기 위험도 체크')),
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
                    '금액 정보',
                    helpTitle: '어떻게 판단하나요?',
                    helpBody:
                        '전세가율, 선순위채권 비율, 보증보험 가능성, 확정일자/전입신고 등 기본 체크 항목을 점수화합니다.\n\n'
                        'HUG 반환보증은 보증금과 선순위채권 합계가 주택가격의 일정 담보인정비율 이내인지 등을 확인하므로, 이 화면은 사전 점검용으로만 사용하세요.',
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '주택 예상 시세',
                    controller: _marketPrice,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 3000000000,
                    sliderDivisions: 300,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전세 보증금',
                    controller: _deposit,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '선순위채권/근저당',
                    controller: _seniorDebt,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('체크리스트'),
                  const SizedBox(height: 8),
                  _CheckTile(
                    title: '등기부등본을 확인했어요',
                    value: _checkedRegistry,
                    onChanged: (value) =>
                        setState(() => _checkedRegistry = value),
                  ),
                  _CheckTile(
                    title: '계약 상대방과 등기상 소유자가 일치해요',
                    value: _ownerMatched,
                    onChanged: (value) => setState(() => _ownerMatched = value),
                  ),
                  _CheckTile(
                    title: '임대인 세금 체납 여부를 확인했어요',
                    value: _checkedTaxArrears,
                    onChanged: (value) =>
                        setState(() => _checkedTaxArrears = value),
                  ),
                  _CheckTile(
                    title: '전세보증금 반환보증 가입이 가능해요',
                    value: _canJoinGuaranteeInsurance,
                    onChanged: (value) =>
                        setState(() => _canJoinGuaranteeInsurance = value),
                  ),
                  _CheckTile(
                    title: '전입신고를 할 예정이에요',
                    value: _willReportMoveIn,
                    onChanged: (value) =>
                        setState(() => _willReportMoveIn = value),
                  ),
                  _CheckTile(
                    title: '확정일자를 받을 예정이에요',
                    value: _willGetFixedDate,
                    onChanged: (value) =>
                        setState(() => _willGetFixedDate = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: '위험도 체크하기', onPressed: _calculate),
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

class _CheckTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: (value) => onChanged(value ?? false),
      title: Text(title, style: AppTextStyles.body),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _ResultCard extends StatelessWidget {
  final JeonseRiskResult result;
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
    final color = switch (result.level) {
      JeonseRiskLevel.low => AppColors.positive,
      JeonseRiskLevel.caution => AppColors.warning,
      JeonseRiskLevel.high => AppColors.danger,
    };

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      JeonseRiskLocalizations.summaryText(result),
                      style: AppTextStyles.heading2.copyWith(color: color),
                    ),
                  ),
                  _ScoreCircle(score: result.score, color: color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                JeonseRiskLocalizations.levelDescription(result.level),
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 20),
              _RatioBar(
                label: '전세가율',
                value: result.jeonseRatio,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _RatioBar(
                label: '선순위채권 비율',
                value: result.seniorDebtRatio,
                color: AppColors.warning,
              ),
              const SizedBox(height: 12),
              _RatioBar(
                label: '보증금+선순위채권 비율',
                value: result.combinedDebtRatio,
                color: color,
              ),
              const SizedBox(height: 20),
              if (result.warnings.isNotEmpty) ...[
                Text('주의 항목', style: AppTextStyles.label),
                const SizedBox(height: 8),
                ...result.warnings.map((item) => _Bullet(
                      JeonseRiskLocalizations.warningText(item),
                      color: color,
                    )),
              ],
              const SizedBox(height: 12),
              Text('권장 조치', style: AppTextStyles.label),
              const SizedBox(height: 8),
              ...result.actionItems.map(
                (item) => _Bullet(
                  JeonseRiskLocalizations.actionText(item),
                  color: AppColors.primary,
                ),
              ),
              if (result.checklist.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('추가 확인', style: AppTextStyles.label),
                const SizedBox(height: 8),
                ...result.checklist.map((item) => _Bullet(
                      JeonseRiskLocalizations.checkText(item),
                      color: AppColors.textSecondary,
                    )),
              ],
              const SizedBox(height: 12),
              Text('보호 절차 체크리스트', style: AppTextStyles.label),
              const SizedBox(height: 8),
              ...result.protectionChecklist.map(
                (item) => _Bullet(
                  JeonseRiskLocalizations.protectionStepText(item),
                  color: AppColors.positive,
                ),
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

class _ScoreCircle extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreCircle({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$score',
        style: AppTextStyles.heading2.copyWith(color: color),
      ),
    );
  }
}

class _RatioBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _RatioBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = (value / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySecondary),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 10,
            color: color,
            backgroundColor: color.withOpacity(0.12),
          ),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color color;

  const _Bullet(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 6, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySecondary)),
        ],
      ),
    );
  }
}
