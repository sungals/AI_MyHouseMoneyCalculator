import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/jeonse_risk_calculator.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_codes.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_input.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_result.dart';

JeonseRiskInput buildInput({
  int marketPrice = 200000000,
  int deposit = 100000000,
  int seniorDebt = 0,
  bool checkedRegistry = true,
  bool ownerMatched = true,
  bool checkedTaxArrears = true,
  bool canJoinGuaranteeInsurance = true,
  bool willReportMoveIn = true,
  bool willGetFixedDate = true,
}) {
  return JeonseRiskInput(
    marketPrice: marketPrice,
    deposit: deposit,
    seniorDebt: seniorDebt,
    checkedRegistry: checkedRegistry,
    ownerMatched: ownerMatched,
    checkedTaxArrears: checkedTaxArrears,
    canJoinGuaranteeInsurance: canJoinGuaranteeInsurance,
    willReportMoveIn: willReportMoveIn,
    willGetFixedDate: willGetFixedDate,
  );
}

void main() {
  final calculator = JeonseRiskCalculator();

  test('결과가 문자열이 아닌 코드 리스트를 담는다', () {
    final result = calculator.calculate(buildInput());
    expect(result.warnings, isA<List<JeonseRiskWarning>>());
    expect(result.checklist, isA<List<JeonseRiskCheck>>());
    expect(result.actionItems, isA<List<JeonseRiskAction>>());
    expect(result.protectionChecklist, isA<List<JeonseProtectionStep>>());
  });

  test('전세가율 90% 이상이면 해당 경고와 조치가 나온다', () {
    final result = calculator.calculate(buildInput(deposit: 190000000));
    expect(result.warnings, contains(JeonseRiskWarning.jeonseRatioOver90));
    expect(result.actionItems,
        contains(JeonseRiskAction.lowerDepositOrCheckInsurance));
  });

  test('전세가율 80%대면 80 경고만 나온다', () {
    final result = calculator.calculate(buildInput(deposit: 170000000));
    expect(result.warnings, contains(JeonseRiskWarning.jeonseRatioOver80));
    expect(result.warnings, isNot(contains(JeonseRiskWarning.jeonseRatioOver90)));
  });

  test('전세가율 70%대는 경고가 아니라 체크 항목이다', () {
    final result = calculator.calculate(buildInput(deposit: 150000000));
    expect(result.checklist, contains(JeonseRiskCheck.jeonseRatioOver70));
  });

  test('등기부 미확인이면 경고와 조치가 나온다', () {
    final result = calculator.calculate(buildInput(checkedRegistry: false));
    expect(result.warnings, contains(JeonseRiskWarning.registryUnchecked));
    expect(result.actionItems, contains(JeonseRiskAction.verifyRightsInRegistry));
  });

  test('보호 절차 체크리스트는 항상 3개다', () {
    expect(calculator.calculate(buildInput()).protectionChecklist, hasLength(3));
  });

  test('경고가 없으면 noMajorRisk 체크가 추가된다', () {
    final result = calculator.calculate(buildInput());
    expect(result.warnings, isEmpty);
    expect(result.checklist, contains(JeonseRiskCheck.noMajorRisk));
  });

  test('조치가 비면 최종 확인 조치가 들어간다', () {
    final result = calculator.calculate(buildInput());
    expect(result.actionItems, contains(JeonseRiskAction.finalCheckBeforeContract));
  });

  test('점수는 0~100이고 최악 조건은 high다', () {
    final worst = calculator.calculate(buildInput(
      deposit: 200000000,
      seniorDebt: 150000000,
      checkedRegistry: false,
      ownerMatched: false,
      checkedTaxArrears: false,
      canJoinGuaranteeInsurance: false,
      willReportMoveIn: false,
      willGetFixedDate: false,
    ));
    expect(worst.score, inInclusiveRange(0, 100));
    expect(worst.level, JeonseRiskLevel.high);
  });

  test('조치 목록에 중복이 없다', () {
    final result = calculator.calculate(
      buildInput(deposit: 190000000, seniorDebt: 100000000),
    );
    expect(result.actionItems.toSet().length, result.actionItems.length);
  });

  test('시세가 0이면 비율이 0이다', () {
    final result = calculator.calculate(buildInput(marketPrice: 0));
    expect(result.jeonseRatio, 0);
    expect(result.seniorDebtRatio, 0);
    expect(result.combinedDebtRatio, 0);
  });

  // Comprehensive enum member isolation tests
  // Ensures every enum member's condition is mapped correctly

  group('JeonseRiskWarning isolation', () {
    test('seniorDebtOver50: 선순위채권 비율 50% 이상이면 나온다', () {
      final result = calculator.calculate(buildInput(seniorDebt: 100000000));
      expect(result.warnings, contains(JeonseRiskWarning.seniorDebtOver50));
      expect(result.warnings,
          isNot(contains(JeonseRiskWarning.seniorDebtOver30)));
    });

    test('seniorDebtOver30: 선순위채권 비율 30% 이상 50% 미만이면 나온다', () {
      final result = calculator.calculate(buildInput(seniorDebt: 60000000));
      expect(result.warnings, contains(JeonseRiskWarning.seniorDebtOver30));
      expect(result.warnings,
          isNot(contains(JeonseRiskWarning.seniorDebtOver50)));
    });

    test('combinedOver90: 보증금+선순위채권 비율 90% 이상이면 나온다', () {
      final result = calculator.calculate(
          buildInput(deposit: 180000000, seniorDebt: 0));
      expect(result.warnings, contains(JeonseRiskWarning.combinedOver90));
      expect(result.warnings,
          isNot(contains(JeonseRiskWarning.combinedOver80)));
    });

    test('combinedOver80: 보증금+선순위채권 비율 80% 이상 90% 미만이면 나온다',
        () {
      final result =
          calculator.calculate(buildInput(deposit: 160000000, seniorDebt: 0));
      expect(result.warnings, contains(JeonseRiskWarning.combinedOver80));
      expect(result.warnings,
          isNot(contains(JeonseRiskWarning.combinedOver90)));
    });

    test('ownerMismatch: 소유자 미일치이면 나온다', () {
      final result = calculator.calculate(buildInput(ownerMatched: false));
      expect(result.warnings, contains(JeonseRiskWarning.ownerMismatch));
    });

    test('guaranteeInsuranceUncertain: 보증보험 불가능이면 나온다', () {
      final result =
          calculator.calculate(buildInput(canJoinGuaranteeInsurance: false));
      expect(result.warnings,
          contains(JeonseRiskWarning.guaranteeInsuranceUncertain));
    });

    test('moveInNotPlanned: 전입신고 미예정이면 나온다', () {
      final result =
          calculator.calculate(buildInput(willReportMoveIn: false));
      expect(result.warnings, contains(JeonseRiskWarning.moveInNotPlanned));
    });

    test('fixedDateNotPlanned: 확정일자 미예정이면 나온다', () {
      final result =
          calculator.calculate(buildInput(willGetFixedDate: false));
      expect(result.warnings, contains(JeonseRiskWarning.fixedDateNotPlanned));
    });
  });

  group('JeonseRiskCheck isolation', () {
    test('seniorDebtExists: 선순위채권 존재 (0% 초과 30% 미만)하면 나온다', () {
      final result = calculator.calculate(buildInput(seniorDebt: 30000000));
      expect(result.checklist, contains(JeonseRiskCheck.seniorDebtExists));
    });

    test('combinedOver70: 보증금+선순위채권 비율 70% 이상 80% 미만이면 나온다',
        () {
      final result =
          calculator.calculate(buildInput(deposit: 140000000, seniorDebt: 0));
      expect(result.checklist, contains(JeonseRiskCheck.combinedOver70));
    });

    test('taxArrearsUnchecked: 세금 체납 확인 미완료이면 나온다', () {
      final result = calculator.calculate(buildInput(checkedTaxArrears: false));
      expect(result.checklist, contains(JeonseRiskCheck.taxArrearsUnchecked));
    });
  });

  group('JeonseRiskAction isolation', () {
    test(
        'checkNearbyPricesAndInsuranceLimit: 전세가율 80%대에서 나온다',
        () {
      final result = calculator.calculate(buildInput(deposit: 170000000));
      expect(result.actionItems,
          contains(JeonseRiskAction.checkNearbyPricesAndInsuranceLimit));
      expect(result.actionItems,
          isNot(contains(JeonseRiskAction.lowerDepositOrCheckInsurance)));
    });

    test(
        'clearSeniorDebtBeforeBalance: 선순위채권 비율 50% 이상이면 나온다',
        () {
      final result = calculator.calculate(buildInput(seniorDebt: 100000000));
      expect(result.actionItems,
          contains(JeonseRiskAction.clearSeniorDebtBeforeBalance));
    });

    test(
        'verifySeniorDebtMaxAndClearance: 선순위채권 비율 30~50% 미만이면 나온다',
        () {
      final result = calculator.calculate(buildInput(seniorDebt: 60000000));
      expect(result.actionItems,
          contains(JeonseRiskAction.verifySeniorDebtMaxAndClearance));
      expect(result.actionItems,
          isNot(contains(JeonseRiskAction.clearSeniorDebtBeforeBalance)));
    });

    test(
        'holdOrRenegotiate: 보증금+선순위채권 비율 90% 이상이면 나온다',
        () {
      final result = calculator.calculate(
          buildInput(deposit: 180000000, seniorDebt: 0));
      expect(result.actionItems, contains(JeonseRiskAction.holdOrRenegotiate));
    });

    test(
        'checkInsuranceAmountAndClearance: 보증금+선순위채권 비율 80~90% 미만이면 나온다',
        () {
      final result = calculator.calculate(
          buildInput(deposit: 160000000, seniorDebt: 0));
      expect(result.actionItems,
          contains(JeonseRiskAction.checkInsuranceAmountAndClearance));
      expect(result.actionItems,
          isNot(contains(JeonseRiskAction.holdOrRenegotiate)));
    });

    test('verifyProxyDocuments: 소유자 미일치이면 나온다', () {
      final result = calculator.calculate(buildInput(ownerMatched: false));
      expect(result.actionItems, contains(JeonseRiskAction.verifyProxyDocuments));
    });

    test('requestTaxCertificate: 세금 체납 확인 미완료이면 나온다', () {
      final result = calculator.calculate(buildInput(checkedTaxArrears: false));
      expect(result.actionItems, contains(JeonseRiskAction.requestTaxCertificate));
    });

    test('checkGuaranteeEligibility: 보증보험 불가능이면 나온다', () {
      final result =
          calculator.calculate(buildInput(canJoinGuaranteeInsurance: false));
      expect(result.actionItems,
          contains(JeonseRiskAction.checkGuaranteeEligibility));
    });

    test('reconsiderIfNoMoveIn: 전입신고 미예정이면 나온다', () {
      final result =
          calculator.calculate(buildInput(willReportMoveIn: false));
      expect(result.actionItems,
          contains(JeonseRiskAction.reconsiderIfNoMoveIn));
    });

    test('reconsiderIfNoFixedDate: 확정일자 미예정이면 나온다', () {
      final result =
          calculator.calculate(buildInput(willGetFixedDate: false));
      expect(result.actionItems,
          contains(JeonseRiskAction.reconsiderIfNoFixedDate));
    });
  });

  group('JeonseProtectionStep (always present)', () {
    test('recheckRegistryOnClosing: 항상 보호 절차에 포함된다', () {
      final result = calculator.calculate(buildInput());
      expect(result.protectionChecklist,
          contains(JeonseProtectionStep.recheckRegistryOnClosing));
    });

    test('reportMoveInAndFixedDate: 항상 보호 절차에 포함된다', () {
      final result = calculator.calculate(buildInput());
      expect(result.protectionChecklist,
          contains(JeonseProtectionStep.reportMoveInAndFixedDate));
    });

    test('addSpecialTerms: 항상 보호 절차에 포함된다', () {
      final result = calculator.calculate(buildInput());
      expect(result.protectionChecklist,
          contains(JeonseProtectionStep.addSpecialTerms));
    });
  });
}
