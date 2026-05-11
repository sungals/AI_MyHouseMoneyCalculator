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

class DsrDtiScreen extends ConsumerStatefulWidget {
  const DsrDtiScreen({super.key});

  @override
  ConsumerState<DsrDtiScreen> createState() => _DsrDtiScreenState();
}

class _DsrDtiScreenState extends ConsumerState<DsrDtiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _annualIncome = TextEditingController();
  final _housingDebt = TextEditingController();
  final _otherDebt = TextEditingController();

  double? _dsr;
  double? _dti;

  @override
  void dispose() {
    _annualIncome.dispose();
    _housingDebt.dispose();
    _otherDebt.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final income = MoneyFormatter.parse(_annualIncome.text);
    final housing = MoneyFormatter.parse(_housingDebt.text);
    final other = MoneyFormatter.parse(_otherDebt.text);
    setState(() {
      _dti = income == 0 ? 0 : housing / income * 100;
      _dsr = income == 0 ? 0 : (housing + other) / income * 100;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _save() async {
    final dsr = _dsr;
    final dti = _dti;
    if (dsr == null || dti == null) return;
    final repo = ref.read(calculationHistoryRepositoryProvider);
    await repo.init();
    await repo.save(
      CalculationHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        typeIndex: CalculationType.dsrDti.index,
        title: 'DSR/DTI 계산',
        summary:
            'DSR ${dsr.toStringAsFixed(1)}%, DTI ${dti.toStringAsFixed(1)}%',
        input: {
          'annualIncome': MoneyFormatter.parse(_annualIncome.text),
          'housingDebt': MoneyFormatter.parse(_housingDebt.text),
          'otherDebt': MoneyFormatter.parse(_otherDebt.text),
        },
        result: {'DSR': dsr, 'DTI': dti},
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('계산 결과가 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('DSR/DTI 계산')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              MoneyInputField(
                label: '연소득',
                controller: _annualIncome,
                validator: Validators.requiredAmount,
                sliderMax: 500000000,
                sliderDivisions: 100,
              ),
              const SizedBox(height: 12),
              MoneyInputField(
                label: '주택담보대출 연간 원리금',
                controller: _housingDebt,
                validator: Validators.requiredAmount,
                sliderMax: 200000000,
                sliderDivisions: 100,
              ),
              const SizedBox(height: 12),
              MoneyInputField(
                label: '기타대출 연간 원리금',
                controller: _otherDebt,
                validator: Validators.requiredAmount,
                sliderMax: 200000000,
                sliderDivisions: 100,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: '계산하기', onPressed: _calculate),
              if (_dsr != null && _dti != null) ...[
                const SizedBox(height: 24),
                _ResultCard(rows: {
                  'DSR': '${_dsr!.toStringAsFixed(1)}%',
                  'DTI': '${_dti!.toStringAsFixed(1)}%',
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
