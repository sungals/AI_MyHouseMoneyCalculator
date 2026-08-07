import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/pdf_export_labels_ko.dart';
import '../../core/utils/share_helper.dart';
import '../../core/utils/validators.dart';
import '../../domain/calculators/rent_compare_calculator.dart';
import '../../domain/entities/rent_compare_input.dart';
import '../../domain/entities/rent_compare_result.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/percent_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';
import '../../shared/widgets/slider_rate_field.dart';
import '../rent_compare/rent_compare_localizations.dart';

class ScenarioCompareScreen extends StatefulWidget {
  const ScenarioCompareScreen({super.key});

  @override
  State<ScenarioCompareScreen> createState() => _ScenarioCompareScreenState();
}

class _ScenarioCompareScreenState extends State<ScenarioCompareScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();
  final _jeonseDeposit = TextEditingController();
  final _jeonseLoan = TextEditingController();
  final _rentDeposit = TextEditingController();
  final _monthlyRent = TextEditingController();
  final _maintenance = TextEditingController();
  final _months = TextEditingController(text: '24');
  final _rateA = TextEditingController(text: '3.5');
  final _rateB = TextEditingController(text: '4.0');
  final _rateC = TextEditingController(text: '4.5');

  double _depositInterestRate = 3.5;
  List<_ScenarioResult> _results = [];

  @override
  void dispose() {
    for (final controller in [
      _jeonseDeposit,
      _jeonseLoan,
      _rentDeposit,
      _monthlyRent,
      _maintenance,
      _months,
      _rateA,
      _rateB,
      _rateC,
    ]) {
      controller.dispose();
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

    final calculator = RentCompareCalculator();
    final rates = [
      ('A안', double.parse(_rateA.text)),
      ('B안', double.parse(_rateB.text)),
      ('C안', double.parse(_rateC.text)),
    ];

    setState(() {
      _results = [
        for (final scenario in rates)
          _ScenarioResult(
            label: scenario.$1,
            interestRate: scenario.$2,
            result: calculator.calculate(
              RentCompareInput(
                jeonseDeposit: deposit,
                jeonseLoan: loan,
                interestRate: scenario.$2,
                monthlyRentDeposit: MoneyFormatter.parse(_rentDeposit.text),
                monthlyRent: MoneyFormatter.parse(_monthlyRent.text),
                maintenanceFee: MoneyFormatter.parse(_maintenance.text),
                months: int.parse(_months.text),
                depositInterestRate: _depositInterestRate,
              ),
            ),
          ),
      ];
    });
    FocusScope.of(context).unfocus();
  }

  void _share() {
    if (_results.isEmpty) return;

    final lines = _results.map((scenario) {
      final result = scenario.result;
      return '${scenario.label} (${scenario.interestRate.toStringAsFixed(2)}%): '
          '${rentCompareRecommendationText(result)} / 전세 월 ${MoneyFormatter.formatWithWon(result.jeonseMonthlyCost)} '
          '/ 실질 월세 ${MoneyFormatter.formatWithWon(result.adjustedRentMonthlyCost)}';
    }).join('\n');

    ShareHelper.shareText(
      context,
      text: '[어떤비용] 복수 시나리오 비교 결과\n\n$lines\n\n※ 본 계산 결과는 참고용입니다.',
      subject: '복수 시나리오 비교 결과',
      title: '복수 시나리오 비교 결과',
    );
  }

  Future<void> _exportPdf() async {
    if (_results.isEmpty) return;

    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: '복수 시나리오 비교 결과',
      summary: rentCompareRecommendationText(_results.first.result),
      resultImageBytes: imageBytes,
      input: {
        '전세 보증금': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_jeonseDeposit.text)),
        '전세대출 금액': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_jeonseLoan.text)),
        '월세 보증금': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_rentDeposit.text)),
        '월세': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_monthlyRent.text)),
        '관리비': MoneyFormatter.formatWithWon(
            MoneyFormatter.parse(_maintenance.text)),
        '거주 기간': '${_months.text}개월',
      },
      result: {
        for (final scenario in _results)
          '${scenario.label} ${scenario.interestRate.toStringAsFixed(2)}%':
              '${rentCompareRecommendationText(scenario.result)} / 전세 월 ${MoneyFormatter.formatWithWon(scenario.result.jeonseMonthlyCost)}',
      },
    );
  }

  Future<Uint8List?> _captureResultImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _resultScreenshotController.capture(pixelRatio: 3.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('복수 시나리오 비교')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '전세대출 금리를 A/B/C로 나눠 월 비용을 비교합니다.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('공통 조건', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전세 보증금',
                    controller: _jeonseDeposit,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '전세대출 금액',
                    controller: _jeonseLoan,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 2000000000,
                    sliderDivisions: 200,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세 보증금',
                    controller: _rentDeposit,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 500000000,
                    sliderDivisions: 100,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '월세',
                    controller: _monthlyRent,
                    validator: Validators.requiredAmount,
                    showQuickButtons: true,
                    sliderMax: 3000000,
                    sliderDivisions: 60,
                  ),
                  const SizedBox(height: 12),
                  MoneyInputField(
                    label: '관리비',
                    controller: _maintenance,
                    validator: Validators.requiredAmount,
                    sliderMax: 1000000,
                    sliderDivisions: 100,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _months,
                    keyboardType: TextInputType.number,
                    validator: Validators.months,
                    decoration: const InputDecoration(
                      labelText: '거주 기간',
                      suffixText: '개월',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderRateField(
                    label: '기회비용 예금이율',
                    value: _depositInterestRate,
                    min: 1.0,
                    max: 6.0,
                    divisions: 50,
                    onChanged: (value) =>
                        setState(() => _depositInterestRate = value),
                  ),
                  const SizedBox(height: 24),
                  Text('비교할 전세대출 금리', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PercentInputField(
                          label: 'A안',
                          controller: _rateA,
                          validator: Validators.interestRate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PercentInputField(
                          label: 'B안',
                          controller: _rateB,
                          validator: Validators.interestRate,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PercentInputField(
                          label: 'C안',
                          controller: _rateC,
                          validator: Validators.interestRate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: '시나리오 비교하기', onPressed: _calculate),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 24),
              Screenshot(
                controller: _resultScreenshotController,
                child: _ScenarioResultTable(results: _results),
              ),
              const SizedBox(height: 12),
              const DisclaimerBox(),
              const SizedBox(height: 16),
              ResultActionButtons(
                onShare: _share,
                onExportPdf: _exportPdf,
                shareLabel: '결과 공유',
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

class _ScenarioResult {
  final String label;
  final double interestRate;
  final RentCompareResult result;

  const _ScenarioResult({
    required this.label,
    required this.interestRate,
    required this.result,
  });
}

class _ScenarioResultTable extends StatelessWidget {
  final List<_ScenarioResult> results;

  const _ScenarioResultTable({required this.results});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final scenario in results) ...[
            SizedBox(
              width: 220,
              child: _ScenarioCard(scenario: scenario),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final _ScenarioResult scenario;

  const _ScenarioCard({required this.scenario});

  @override
  Widget build(BuildContext context) {
    final result = scenario.result;
    final color =
        result.isJeonseAdvantageous ? AppColors.positive : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${scenario.label} ${scenario.interestRate.toStringAsFixed(2)}%',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 10),
          Text(
            rentCompareRecommendationText(result),
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _Row(
            label: '전세 월 비용',
            value: MoneyFormatter.formatWithWon(result.jeonseMonthlyCost),
          ),
          const SizedBox(height: 8),
          _Row(
            label: '실질 월세',
            value: MoneyFormatter.formatWithWon(result.adjustedRentMonthlyCost),
          ),
          const SizedBox(height: 8),
          _Row(
            label: '전체 차이',
            value: MoneyFormatter.formatWithWon(result.totalDifference.abs()),
            valueColor: color,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: AppTextStyles.caption)),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
