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
import '../../core/utils/validation_error_l10n.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/calculators/acquisition_tax_calculator.dart';
import '../../domain/entities/acquisition_tax_input.dart';
import '../../providers/calculation_history_provider.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/result_action_buttons.dart';

class AcquisitionTaxScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialInput;

  const AcquisitionTaxScreen({super.key, this.initialInput});

  @override
  ConsumerState<AcquisitionTaxScreen> createState() =>
      _AcquisitionTaxScreenState();
}

class _AcquisitionTaxScreenState extends ConsumerState<AcquisitionTaxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resultScreenshotController = ScreenshotController();
  final _price = TextEditingController();
  String _houseCount = 'one';
  bool _regulatedArea = false;
  int? _tax;
  double? _rate;

  @override
  void initState() {
    super.initState();
    _applyInitialInput(widget.initialInput);
  }

  void _applyInitialInput(Map<String, dynamic>? input) {
    if (input == null) return;
    _setMoney(_price, input['price']);
    final houseCount = input['houseCount']?.toString();
    if (houseCount == 'one' ||
        houseCount == 'two' ||
        houseCount == 'threePlus') {
      _houseCount = houseCount!;
    }
    _regulatedArea = _boolValue(input['regulatedArea']) ?? _regulatedArea;
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
    _price.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final price = MoneyFormatter.parse(_price.text);
    final result = AcquisitionTaxCalculator().calculate(
      AcquisitionTaxInput(
        price: price,
        houseCount: _houseCountType,
        regulatedArea: _regulatedArea,
      ),
    );
    setState(() {
      _rate = result.rate;
      _tax = result.tax;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final tax = _tax;
    final rate = _rate;
    if (tax == null || rate == null) return;
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    await repo.save(
      CalculationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        typeIndex: CalculationType.acquisitionTax.index,
        title: '취득세 계산',
        summary: '예상 취득세 ${MoneyFormatter.formatWithWon(tax)}',
        input: {
          'price': MoneyFormatter.parse(_price.text),
          'houseCount': _houseCount,
          'regulatedArea': _regulatedArea,
        },
        result: {
          'acquisitionTax': tax,
          'ratePercent': rate * 100,
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
    final tax = _tax;
    final rate = _rate;
    if (tax == null || rate == null) return;

    final imageBytes = await _captureResultImage();
    if (!mounted) return;
    await CalculationPdfExporter.share(
      context,
      labels: kKoreanPdfExportLabels,
      title: '취득세 계산 결과',
      summary: '예상 취득세 ${MoneyFormatter.formatWithWon(tax)}',
      resultImageBytes: imageBytes,
      input: {
        '주택 취득가액':
            MoneyFormatter.formatWithWon(MoneyFormatter.parse(_price.text)),
        '보유 주택 수': switch (_houseCount) {
          'two' => '2주택',
          'threePlus' => '3주택 이상',
          _ => '1주택',
        },
        '조정대상지역': _regulatedArea ? '예' : '아니오',
      },
      result: {
        '적용 세율': '${(rate * 100).toStringAsFixed(2)}%',
        '예상 취득세': MoneyFormatter.formatWithWon(tax),
      },
    );
  }

  Future<Uint8List?> _captureResultImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _resultScreenshotController.capture(pixelRatio: 3.0);
  }

  HouseCountType get _houseCountType {
    switch (_houseCount) {
      case 'two':
        return HouseCountType.two;
      case 'threePlus':
        return HouseCountType.threePlus;
      case 'one':
      default:
        return HouseCountType.one;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('취득세 계산')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              MoneyInputField(
                label: '주택 취득가액',
                controller: _price,
                validator: (v) => Validators.requiredAmountCode(v)?.localize(context),
                sliderMax: 3000000000,
                sliderDivisions: 300,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _houseCount,
                decoration: const InputDecoration(labelText: '취득 후 보유 주택 수'),
                items: const [
                  DropdownMenuItem(value: 'one', child: Text('1주택')),
                  DropdownMenuItem(value: 'two', child: Text('2주택')),
                  DropdownMenuItem(value: 'threePlus', child: Text('3주택 이상')),
                ],
                onChanged: (value) =>
                    setState(() => _houseCount = value ?? 'one'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _regulatedArea,
                onChanged: (value) => setState(() => _regulatedArea = value),
                title: const Text('조정대상지역'),
                subtitle: const Text('다주택 중과 간이 계산에 반영합니다'),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: '계산하기', onPressed: _calculate),
              if (_tax != null && _rate != null) ...[
                const SizedBox(height: 24),
                Screenshot(
                  controller: _resultScreenshotController,
                  child: _ResultCard(rows: {
                    '적용 세율': '${(_rate! * 100).toStringAsFixed(2)}%',
                    '예상 취득세': MoneyFormatter.formatWithWon(_tax!),
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
                    Text(
                      entry.value,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
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
