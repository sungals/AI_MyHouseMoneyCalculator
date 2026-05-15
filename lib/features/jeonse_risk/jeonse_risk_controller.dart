import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calculators/jeonse_risk_calculator.dart';
import '../../domain/entities/jeonse_risk_input.dart';
import '../../domain/entities/jeonse_risk_result.dart';

final jeonseRiskControllerProvider =
    StateNotifierProvider<JeonseRiskController, JeonseRiskResult?>(
  (ref) => JeonseRiskController(),
);

class JeonseRiskController extends StateNotifier<JeonseRiskResult?> {
  final _calculator = JeonseRiskCalculator();

  JeonseRiskController() : super(null);

  void calculate(JeonseRiskInput input) {
    state = _calculator.calculate(input);
  }

  void reset() => state = null;
}
