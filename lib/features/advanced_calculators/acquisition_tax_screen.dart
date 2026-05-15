import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/calculation_pdf_exporter.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/models/calculation_history.dart';
import '../../domain/calculators/acquisition_tax_calculator.dart';
import '../../domain/entities/acquisition_tax_input.dart';
import '../../providers/calculation_history_provider.dart';
import '../../shared/widgets/disclaimer_box.dart';
import '../../shared/widgets/money_input_field.dart';
import '../../shared/widgets/primary_button.dart';

class AcquisitionTaxScreen extends ConsumerStatefulWidget {
  const AcquisitionTaxScreen({super.key});

  @override
  ConsumerState<AcquisitionTaxScreen> createState() =>
      _AcquisitionTaxScreenState();
}

class _AcquisitionTaxScreenState extends ConsumerState<AcquisitionTaxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _price = TextEditingController();
  String _houseCount = 'one';
  bool _regulatedArea = false;
  int? _tax;
  double? _rate;

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

    await CalculationPdfExporter.share(
      context,
      title: '취득세 계산 결과',
      summary: '예상 취득세 ${MoneyFormatter.formatWithWon(tax)}',
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
                validator: Validators.requiredAmount,
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
                _ResultCard(rows: {
                  '적용 세율': '${(_rate! * 100).toStringAsFixed(2)}%',
                  '예상 취득세': MoneyFormatter.formatWithWon(_tax!),
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportPdf,
                        icon:
                            const Icon(Icons.picture_as_pdf_outlined, size: 18),
                        label: const Text('PDF'),
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
