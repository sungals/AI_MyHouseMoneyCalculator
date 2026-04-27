import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculators/rent_compare_calculator.dart';
import '../../domain/entities/rent_compare_input.dart';
import '../../domain/entities/rent_compare_result.dart';

final rentCompareControllerProvider =
    StateNotifierProvider<RentCompareController, RentCompareResult?>(
  (ref) => RentCompareController(),
);

class RentCompareController extends StateNotifier<RentCompareResult?> {
  final _calculator = RentCompareCalculator();

  RentCompareController() : super(null);

  void calculate(RentCompareInput input) {
    state = _calculator.calculate(input);
  }

  void reset() => state = null;
}
