import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculators/tax_deduction_calculator.dart';
import '../../domain/entities/tax_deduction_input.dart';
import '../../domain/entities/tax_deduction_result.dart';

final taxDeductionControllerProvider =
    StateNotifierProvider<TaxDeductionController, TaxDeductionResult?>(
  (ref) => TaxDeductionController(),
);

class TaxDeductionController extends StateNotifier<TaxDeductionResult?> {
  TaxDeductionController() : super(null);

  final _calculator = TaxDeductionCalculator();

  void calculate(TaxDeductionInput input) {
    state = _calculator.calculate(input);
  }
}
