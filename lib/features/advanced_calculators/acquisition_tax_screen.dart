import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/models/calculation_history.dart';
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
    final rate = _taxRate(price);
    setState(() {
      _rate = rate;
      _tax = (price * rate).round();
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

  double _taxRate(int price) {
    if (_houseCount == 'threePlus') return 0.12;
    if (_houseCount == 'two' && _regulatedArea) return 0.08;
    if (price <= 600000000) return 0.01;
    if (price <= 900000000) {
      final hundredMillion = price / 100000000;
      return ((hundredMillion * 2 / 3) - 3) / 100;
    }
    return 0.03;
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
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('저장'),
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
