import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/pdf_export_labels_ko.dart';
import '../../core/utils/validators.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/calculators/brokerage_fee_calculator.dart';
import '../../domain/entities/brokerage_fee_input.dart';
import '../../providers/calculation_history_provider.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';

class BrokerageFeeScreen extends ConsumerStatefulWidget {
  const BrokerageFeeScreen({super.key});

  @override
  ConsumerState<BrokerageFeeScreen> createState() => _BrokerageFeeScreenState();
}

class _BrokerageFeeScreenState extends ConsumerState<BrokerageFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();
  final _price = TextEditingController();
  String _type = 'sale';
  int? _fee;
  double? _rate;
  int? _cap;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final amount = MoneyFormatter.parse(_price.text);
    final result = BrokerageFeeCalculator().calculate(
      BrokerageFeeInput(
        transactionType: _type == 'sale'
            ? BrokerageTransactionType.sale
            : BrokerageTransactionType.lease,
        transactionAmount: amount,
      ),
    );
    setState(() {
      _rate = result.rate;
      _cap = result.cap;
      _fee = result.fee;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final fee = _fee;
    if (fee == null || _rate == null) return;
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    await repo.save(
      CalculationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        typeIndex: CalculationType.brokerageFee.index,
        title: '중개보수 계산',
        summary: '예상 중개보수 ${MoneyFormatter.formatWithWon(fee)}',
        input: {
          'transactionType': _type == 'sale' ? '매매' : '임대차',
          'transactionAmount': MoneyFormatter.parse(_price.text),
        },
        result: {
          'brokerageFee': fee,
          'ratePercent': _rate! * 100,
          'cap': _cap,
        },
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('계산 결과가 저장되었습니다.')),
    );
  }

  Future<void> _exportPdf() async {
    final fee = _fee;
    final rate = _rate;
    if (fee == null || rate == null) return;

    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: '중개보수 계산 결과',
      summary: '예상 중개보수 ${MoneyFormatter.formatWithWon(fee)}',
      resultImageBytes: imageBytes,
      input: {
        '거래 유형': _type == 'sale' ? '매매' : '임대차',
        '거래 금액':
            MoneyFormatter.formatWithWon(MoneyFormatter.parse(_price.text)),
      },
      result: {
        '상한 요율': '${(rate * 100).toStringAsFixed(2)}%',
        '한도액': _cap == null ? '없음' : MoneyFormatter.formatWithWon(_cap!),
        '예상 중개보수': MoneyFormatter.formatWithWon(fee),
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
      appBar: AppBar(title: const Text('중개보수 계산')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'sale', label: Text('매매')),
                  ButtonSegment(value: 'lease', label: Text('임대차')),
                ],
                selected: {_type},
                onSelectionChanged: (values) =>
                    setState(() => _type = values.first),
              ),
              const SizedBox(height: 12),
              MoneyInputField(
                label: _type == 'sale' ? '매매가' : '거래금액',
                controller: _price,
                validator: Validators.requiredAmount,
                sliderMax: 3000000000,
                sliderDivisions: 300,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: '계산하기', onPressed: _calculate),
              if (_fee != null && _rate != null) ...[
                const SizedBox(height: 24),
                Screenshot(
                  controller: _resultScreenshotController,
                  child: _ResultCard(rows: {
                    '상한 요율': '${(_rate! * 100).toStringAsFixed(2)}%',
                    '한도액': _cap == null
                        ? '없음'
                        : MoneyFormatter.formatWithWon(_cap!),
                    '예상 중개보수': MoneyFormatter.formatWithWon(_fee!),
                  }),
                ),
                const SizedBox(height: 12),
                ResultActionButtons(
                  onSave: _save,
                  onExportPdf: _exportPdf,
                  pdfLabel: 'PDF',
                ),
              ],
              const SizedBox(height: 12),
              const DisclaimerBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, String> rows;

  const _ResultCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: rows.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Flexible(
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
