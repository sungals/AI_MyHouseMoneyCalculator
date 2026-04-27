import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculators/semi_rent_calculator.dart';
import '../../domain/entities/semi_rent_input.dart';
import '../../domain/entities/semi_rent_result.dart';

final semiRentControllerProvider =
    StateNotifierProvider<SemiRentController, SemiRentResult?>(
  (ref) => SemiRentController(),
);

class SemiRentController extends StateNotifier<SemiRentResult?> {
  final _calculator = SemiRentCalculator();

  SemiRentController() : super(null);

  void calculate(SemiRentInput input) {
    state = _calculator.calculate(input);
  }

  void reset() => state = null;
}
