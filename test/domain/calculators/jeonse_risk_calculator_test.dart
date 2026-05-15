import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/jeonse_risk_calculator.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_input.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_result.dart';

void main() {
  group('JeonseRiskCalculator', () {
    test('낮은 전세가율과 체크 완료 상태는 낮은 위험으로 평가한다', () {
      final result = JeonseRiskCalculator().calculate(
        const JeonseRiskInput(
          marketPrice: 500000000,
          deposit: 250000000,
          seniorDebt: 0,
          checkedRegistry: true,
          ownerMatched: true,
          checkedTaxArrears: true,
          canJoinGuaranteeInsurance: true,
          willReportMoveIn: true,
          willGetFixedDate: true,
        ),
      );

      expect(result.level, JeonseRiskLevel.low);
      expect(result.jeonseRatio, 50);
      expect(result.score, lessThan(30));
    });

    test('높은 전세가율과 체크 누락은 높은 위험으로 평가한다', () {
      final result = JeonseRiskCalculator().calculate(
        const JeonseRiskInput(
          marketPrice: 300000000,
          deposit: 280000000,
          seniorDebt: 70000000,
          checkedRegistry: false,
          ownerMatched: false,
          checkedTaxArrears: false,
          canJoinGuaranteeInsurance: false,
          willReportMoveIn: false,
          willGetFixedDate: false,
        ),
      );

      expect(result.level, JeonseRiskLevel.high);
      expect(result.score, 100);
      expect(result.warnings, isNotEmpty);
    });
  });
}
