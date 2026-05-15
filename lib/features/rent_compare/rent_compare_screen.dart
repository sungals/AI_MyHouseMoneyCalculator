import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/share_helper.dart';
import '../../core/utils/validators.dart';
import '../../providers/calculation_history_provider.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/entities/rent_compare_input.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/help_icon.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/slider_rate_field.dart';
import 'rent_compare_controller.dart';
import 'widgets/rent_compare_result_card.dart';

class RentCompareScreen extends ConsumerStatefulWidget {
  const RentCompareScreen({super.key});

  @override
  ConsumerState<RentCompareScreen> createState() => _RentCompareScreenState();
}

class _RentCompareScreenState extends ConsumerState<RentCompareScreen> {
  final _formKey = GlobalKey<FormState>();
  final _screenshotController = ScreenshotController();

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

  double _depositInterestRate = 3.5;

  @override
  void dispose() {
    for (final c in [
      _jeonseDeposit,
      _jeonseLoan,
      _interestRate,
      _rentDeposit,
      _monthlyRent,
      _maintenance,
      _months,
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
      depositInterestRate: _depositInterestRate,
    );

    ref.read(rentCompareControllerProvider.notifier).calculate(input);
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final result = ref.read(rentCompareControllerProvider);
    if (result == null) return;

    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();

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

    await repo.save(history);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('계산 결과가 저장되었습니다.')),
      );
    }
  }

  Future<void> _shareImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final Uint8List? imageBytes =
        await _screenshotController.capture(pixelRatio: 3.0);
    if (imageBytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/rent_compare_result.png');
    await file.writeAsBytes(imageBytes);
    if (!mounted) return;

    await ShareHelper.shareFiles(
      context,
      files: [
        XFile(
          file.path,
          mimeType: 'image/png',
          name: 'rent_compare_result.png',
        ),
      ],
      text: '전세 vs 월세 비교 결과',
      title: '전세 vs 월세 비교 결과',
    );
  }

  Future<void> _exportPdf() async {
    final result = ref.read(rentCompareControllerProvider);
    if (result == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 80));
    final imageBytes = await _screenshotController.capture(pixelRatio: 3.0);
    if (!mounted) return;

    await CalculationPdfExporter.share(
      context,
      title: '전세 vs 월세 비교 결과',
      summary: result.recommendationText,
      resultImageBytes: imageBytes,
      input: {
        '전세 보증금': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_jeonseDeposit.text)),
        '전세대출 금액': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_jeonseLoan.text)),
        '전세대출 연이율': '${_interestRate.text}%',
        '월세 보증금': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_rentDeposit.text)),
        '월세': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_monthlyRent.text)),
        '관리비': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_maintenance.text)),
        '거주 기간': '${_months.text}개월',
        '기회비용 예금이율': '${_depositInterestRate.toStringAsFixed(1)}%',
      },
      result: {
        '전세 월 비용': MoneyFormatter.formatWithWon(result.jeonseMonthlyCost),
        '월세 + 관리비': MoneyFormatter.formatWithWon(result.rentMonthlyCost),
        '실질 월세 월 비용':
            MoneyFormatter.formatWithWon(result.adjustedRentMonthlyCost),
        '월 차이': MoneyFormatter.formatWithWon(result.monthlyDifference.abs()),
        '전체 기간 차이': MoneyFormatter.formatWithWon(result.totalDifference.abs()),
      },
    );
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
                  const _SectionTitle(
                    '전세 조건',
                    helpTitle: '전세란?',
                    helpBody: '전세는 보증금을 집주인에게 맡기고 월세 없이 거주하는 방식입니다.\n\n'
                        '• 전세 보증금: 집주인에게 맡기는 총 금액 (계약 만료 시 반환)\n'
                        '• 전세대출 금액: 보증금 중 은행에서 빌린 금액\n'
                        '• 전세대출 연이율: 대출에 적용되는 연간 이자율\n\n'
                        '실제 월 비용 = 대출 이자 + 자기 자본의 기회비용(예금이율)으로 계산됩니다.',
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전세 보증금',
                    controller: _jeonseDeposit,
                    focusNode: _fn1,
                    nextFocusNode: _fn2,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전세대출 금액',
                    controller: _jeonseLoan,
                    focusNode: _fn2,
                    nextFocusNode: _fn3,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 12),
                  PercentInputField(
                    label: '전세대출 연이율',
                    controller: _interestRate,
                    focusNode: _fn3,
                    nextFocusNode: _fn4,
                    validator: Validators.interestRate,
                  ),
                  const SizedBox(height: 20),
                  SliderRateField(
                    label: '기회비용 예금이율',
                    value: _depositInterestRate,
                    min: 1.0,
                    max: 6.0,
                    divisions: 50,
                    onChanged: (v) => setState(() => _depositInterestRate = v),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    '월세 조건',
                    helpTitle: '월세란?',
                    helpBody: '월세는 보증금을 일부 맡기고 매월 임대료를 납부하는 방식입니다.\n\n'
                        '• 월세 보증금: 계약 시 집주인에게 맡기는 금액\n'
                        '• 월세: 매달 납부하는 임대료\n'
                        '• 관리비: 건물 유지·공용 시설 이용 월 비용\n\n'
                        '실제 월 비용 = 월세 + 관리비 + 보증금의 기회비용으로 계산됩니다.',
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세 보증금',
                    controller: _rentDeposit,
                    focusNode: _fn4,
                    nextFocusNode: _fn5,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 500000000,
                    sliderDivisions: 100,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세',
                    controller: _monthlyRent,
                    focusNode: _fn5,
                    nextFocusNode: _fn6,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 3000000,
                    sliderDivisions: 60,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '관리비',
                    controller: _maintenance,
                    focusNode: _fn6,
                    nextFocusNode: _fn7,
                    validator: Validators.requiredAmount,
                    sliderMax: 1000000,
                    sliderDivisions: 100,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    '거주 기간',
                    helpTitle: '거주 기간이란?',
                    helpBody: '비교할 실제 거주 예정 기간(개월)을 입력합니다.\n\n'
                        '거주 기간에 따라 총 비용 차이가 달라지므로,\n'
                        '실제 계약 기간과 동일하게 입력하세요.\n\n'
                        '예: 2년 계약 → 24개월',
                  ),
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
              Screenshot(
                controller: _screenshotController,
                child: RentCompareResultCard(
                  result: result,
                  showActions: false,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareImage,
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text('이미지 공유'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('저장'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('PDF 내보내기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
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
