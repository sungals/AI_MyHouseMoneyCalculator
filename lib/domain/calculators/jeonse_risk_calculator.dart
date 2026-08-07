import '../entities/jeonse_risk_codes.dart';
import '../entities/jeonse_risk_input.dart';
import '../entities/jeonse_risk_result.dart';

class JeonseRiskCalculator {
  JeonseRiskResult calculate(JeonseRiskInput input) {
    final jeonseRatio = _ratio(input.deposit, input.marketPrice);
    final seniorDebtRatio = _ratio(input.seniorDebt, input.marketPrice);
    final combinedDebtRatio =
        _ratio(input.deposit + input.seniorDebt, input.marketPrice);
    final warnings = <JeonseRiskWarning>[];
    final checklist = <JeonseRiskCheck>[];
    final actionItems = <JeonseRiskAction>[];
    const protectionChecklist = <JeonseProtectionStep>[
      JeonseProtectionStep.recheckRegistryOnClosing,
      JeonseProtectionStep.reportMoveInAndFixedDate,
      JeonseProtectionStep.addSpecialTerms,
    ];
    var score = 0;

    if (jeonseRatio >= 90) {
      score += 30;
      warnings.add(JeonseRiskWarning.jeonseRatioOver90);
      actionItems.add(JeonseRiskAction.lowerDepositOrCheckInsurance);
    } else if (jeonseRatio >= 80) {
      score += 20;
      warnings.add(JeonseRiskWarning.jeonseRatioOver80);
      actionItems.add(JeonseRiskAction.checkNearbyPricesAndInsuranceLimit);
    } else if (jeonseRatio >= 70) {
      score += 10;
      checklist.add(JeonseRiskCheck.jeonseRatioOver70);
    }

    if (seniorDebtRatio >= 50) {
      score += 25;
      warnings.add(JeonseRiskWarning.seniorDebtOver50);
      actionItems.add(JeonseRiskAction.clearSeniorDebtBeforeBalance);
    } else if (seniorDebtRatio >= 30) {
      score += 15;
      warnings.add(JeonseRiskWarning.seniorDebtOver30);
      actionItems.add(JeonseRiskAction.verifySeniorDebtMaxAndClearance);
    } else if (seniorDebtRatio > 0) {
      score += 8;
      checklist.add(JeonseRiskCheck.seniorDebtExists);
    }

    if (combinedDebtRatio >= 90) {
      score += 25;
      warnings.add(JeonseRiskWarning.combinedOver90);
      actionItems.add(JeonseRiskAction.holdOrRenegotiate);
    } else if (combinedDebtRatio >= 80) {
      score += 15;
      warnings.add(JeonseRiskWarning.combinedOver80);
      actionItems.add(JeonseRiskAction.checkInsuranceAmountAndClearance);
    } else if (combinedDebtRatio >= 70) {
      score += 8;
      checklist.add(JeonseRiskCheck.combinedOver70);
    }

    if (!input.checkedRegistry) {
      score += 10;
      warnings.add(JeonseRiskWarning.registryUnchecked);
      actionItems.add(JeonseRiskAction.verifyRightsInRegistry);
    }
    if (!input.ownerMatched) {
      score += 15;
      warnings.add(JeonseRiskWarning.ownerMismatch);
      actionItems.add(JeonseRiskAction.verifyProxyDocuments);
    }
    if (!input.checkedTaxArrears) {
      score += 10;
      checklist.add(JeonseRiskCheck.taxArrearsUnchecked);
      actionItems.add(JeonseRiskAction.requestTaxCertificate);
    }
    if (!input.canJoinGuaranteeInsurance) {
      score += 15;
      warnings.add(JeonseRiskWarning.guaranteeInsuranceUncertain);
      actionItems.add(JeonseRiskAction.checkGuaranteeEligibility);
    }
    if (!input.willReportMoveIn) {
      score += 10;
      warnings.add(JeonseRiskWarning.moveInNotPlanned);
      actionItems.add(JeonseRiskAction.reconsiderIfNoMoveIn);
    }
    if (!input.willGetFixedDate) {
      score += 10;
      warnings.add(JeonseRiskWarning.fixedDateNotPlanned);
      actionItems.add(JeonseRiskAction.reconsiderIfNoFixedDate);
    }

    score = score.clamp(0, 100);
    final level = score >= 60
        ? JeonseRiskLevel.high
        : score >= 30
            ? JeonseRiskLevel.caution
            : JeonseRiskLevel.low;

    if (warnings.isEmpty) {
      checklist.add(JeonseRiskCheck.noMajorRisk);
    }
    if (actionItems.isEmpty) {
      actionItems.add(JeonseRiskAction.finalCheckBeforeContract);
    }

    return JeonseRiskResult(
      jeonseRatio: jeonseRatio,
      seniorDebtRatio: seniorDebtRatio,
      combinedDebtRatio: combinedDebtRatio,
      score: score,
      level: level,
      warnings: warnings,
      checklist: checklist,
      actionItems: actionItems.toSet().toList(),
      protectionChecklist: protectionChecklist,
    );
  }

  double _ratio(int numerator, int denominator) {
    if (denominator <= 0) return 0;
    return numerator / denominator * 100;
  }
}
