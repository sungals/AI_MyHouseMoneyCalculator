import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculators/contract_renewal_calculator.dart';
import '../../domain/entities/contract_renewal_input.dart';
import '../../domain/entities/contract_renewal_result.dart';

final contractRenewalControllerProvider =
    StateNotifierProvider<ContractRenewalController, ContractRenewalResult?>(
  (ref) => ContractRenewalController(),
);

class ContractRenewalController extends StateNotifier<ContractRenewalResult?> {
  final _calculator = ContractRenewalCalculator();

  ContractRenewalController() : super(null);

  void calculate(ContractRenewalInput input) {
    state = _calculator.calculate(input);
  }

  void reset() => state = null;
}
