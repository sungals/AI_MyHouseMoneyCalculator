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

class BrokerageFeeScreen extends ConsumerStatefulWidget {
  const BrokerageFeeScreen({super.key});

  @override
  ConsumerState<BrokerageFeeScreen> createState() => _BrokerageFeeScreenState();
}

class _BrokerageFeeScreenState extends ConsumerState<BrokerageFeeScreen> {
  final _formKey = GlobalKey<FormState>();
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
    final bracket =
        _type == 'sale' ? _saleBracket(amount) : _leaseBracket(amount);
    final rawFee = (amount * bracket.rate).round();
    setState(() {
      _rate = bracket.rate;
      _cap = bracket.cap;
      _fee = bracket.cap == null ? rawFee : rawFee.clamp(0, bracket.cap!);
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

  _FeeBracket _saleBracket(int amount) {
    if (amount < 50000000) return const _FeeBracket(0.006, 250000);
    if (amount < 200000000) return const _FeeBracket(0.005, 800000);
    if (amount < 900000000) return const _FeeBracket(0.004, null);
    if (amount < 1200000000) return const _FeeBracket(0.005, null);
    if (amount < 1500000000) return const _FeeBracket(0.006, null);
    return const _FeeBracket(0.007, null);
  }

  _FeeBracket _leaseBracket(int amount) {
    if (amount < 50000000) return const _FeeBracket(0.005, 200000);
    if (amount < 100000000) return const _FeeBracket(0.004, 300000);
    if (amount < 600000000) return const _FeeBracket(0.003, null);
    if (amount < 1200000000) return const _FeeBracket(0.004, null);
    if (amount < 1500000000) return const _FeeBracket(0.005, null);
    return const _FeeBracket(0.006, null);
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
                _ResultCard(rows: {
                  '상한 요율': '${(_rate! * 100).toStringAsFixed(2)}%',
                  '한도액':
                      _cap == null ? '없음' : MoneyFormatter.formatWithWon(_cap!),
                  '예상 중개보수': MoneyFormatter.formatWithWon(_fee!),
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

class _FeeBracket {
  final double rate;
  final int? cap;

  const _FeeBracket(this.rate, this.cap);
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
