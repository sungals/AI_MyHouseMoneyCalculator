import '../../domain/entities/jeonse_risk_codes.dart';
import '../../domain/entities/jeonse_risk_result.dart';

/// Temporary Korean localizations for jeonse risk enums.
/// Phase 1 will move these to ARB files for proper i18n.
class JeonseRiskLocalizations {
  static String warningText(JeonseRiskWarning warning) {
    return switch (warning) {
      JeonseRiskWarning.jeonseRatioOver90 =>
        '전세가율이 90% 이상입니다. 보증보험 가입이 어려울 수 있어요.',
      JeonseRiskWarning.jeonseRatioOver80 =>
        '전세가율이 80% 이상입니다. 시세와 보증보험 가능 여부를 재확인하세요.',
      JeonseRiskWarning.seniorDebtOver50 =>
        '선순위채권/근저당 비율이 50% 이상입니다.',
      JeonseRiskWarning.seniorDebtOver30 =>
        '선순위채권/근저당 비율이 30% 이상입니다.',
      JeonseRiskWarning.combinedOver90 =>
        '보증금과 선순위채권 합계가 주택가액의 90% 이상입니다.',
      JeonseRiskWarning.combinedOver80 =>
        '보증금과 선순위채권 합계가 주택가액의 80% 이상입니다.',
      JeonseRiskWarning.registryUnchecked => '등기부등본 확인이 필요합니다.',
      JeonseRiskWarning.ownerMismatch =>
        '계약 상대방과 등기상 소유자 일치 여부를 확인해야 합니다.',
      JeonseRiskWarning.guaranteeInsuranceUncertain =>
        '전세보증금 반환보증 가입 가능 여부가 불확실합니다.',
      JeonseRiskWarning.moveInNotPlanned =>
        '전입신고 예정이 아니면 대항력 확보가 어려울 수 있습니다.',
      JeonseRiskWarning.fixedDateNotPlanned =>
        '확정일자 예정이 아니면 우선변제권 확보가 어려울 수 있습니다.',
    };
  }

  static String checkText(JeonseRiskCheck check) {
    return switch (check) {
      JeonseRiskCheck.jeonseRatioOver70 =>
        '전세가율이 70% 이상입니다. 주변 실거래가를 추가로 확인하세요.',
      JeonseRiskCheck.seniorDebtExists =>
        '선순위채권이 있습니다. 말소 조건을 계약서에 명확히 남기세요.',
      JeonseRiskCheck.combinedOver70 =>
        '보증금과 선순위채권 합계가 70% 이상입니다.',
      JeonseRiskCheck.taxArrearsUnchecked =>
        '임대인 국세/지방세 체납 여부를 확인하세요.',
      JeonseRiskCheck.noMajorRisk =>
        '현재 입력값 기준 큰 위험 신호는 낮습니다. 잔금일 등기부 재확인은 필요합니다.',
    };
  }

  static String actionText(JeonseRiskAction action) {
    return switch (action) {
      JeonseRiskAction.lowerDepositOrCheckInsurance =>
        '보증금을 낮추거나 보증보험 가능 여부를 먼저 확인한 뒤 계약하세요.',
      JeonseRiskAction.checkNearbyPricesAndInsuranceLimit =>
        '동일 단지/인근 실거래가와 보증보험 한도를 추가 확인하세요.',
      JeonseRiskAction.clearSeniorDebtBeforeBalance =>
        '잔금 전 근저당 말소 조건을 특약으로 넣고 증빙을 확인하세요.',
      JeonseRiskAction.verifySeniorDebtMaxAndClearance =>
        '선순위채권의 채권최고액과 실제 말소 가능 여부를 확인하세요.',
      JeonseRiskAction.holdOrRenegotiate =>
        '깡통전세 가능성이 높으므로 계약 보류 또는 조건 재협상을 권장합니다.',
      JeonseRiskAction.checkInsuranceAmountAndClearance =>
        '보증보험 가입 가능 금액과 선순위채권 말소 여부를 확인하세요.',
      JeonseRiskAction.verifyRightsInRegistry =>
        '소유권, 근저당, 가압류, 신탁 등 권리관계를 등기부에서 확인하세요.',
      JeonseRiskAction.verifyProxyDocuments =>
        '대리 계약이면 위임장, 인감증명서, 신분증을 대조하세요.',
      JeonseRiskAction.requestTaxCertificate =>
        '임대인 납세증명서 또는 체납 열람 동의를 요청하세요.',
      JeonseRiskAction.checkGuaranteeEligibility =>
        'HUG/SGI/HF 반환보증 가입 가능 여부를 계약 전 확인하세요.',
      JeonseRiskAction.reconsiderIfNoMoveIn =>
        '전입신고가 어려운 계약은 보증금 보호가 약해질 수 있어 재검토하세요.',
      JeonseRiskAction.reconsiderIfNoFixedDate =>
        '확정일자를 받을 수 없는 계약 조건은 재검토하세요.',
      JeonseRiskAction.finalCheckBeforeContract =>
        '계약 전 등기부, 세금 체납, 보증보험 가능 여부를 최종 확인하세요.',
    };
  }

  static String protectionStepText(JeonseProtectionStep step) {
    return switch (step) {
      JeonseProtectionStep.recheckRegistryOnClosing =>
        '계약 당일과 잔금일 등기부등본을 다시 발급받아 변동 사항을 확인하세요.',
      JeonseProtectionStep.reportMoveInAndFixedDate =>
        '전입신고와 확정일자는 잔금 지급 직후 처리하세요.',
      JeonseProtectionStep.addSpecialTerms =>
        '특약에 선순위채권 말소, 보증보험 가입 협조, 체납 확인 협조를 명시하세요.',
    };
  }

  static String levelLabel(JeonseRiskLevel level) {
    return switch (level) {
      JeonseRiskLevel.low => '낮음',
      JeonseRiskLevel.caution => '주의',
      JeonseRiskLevel.high => '높음',
    };
  }

  static String levelDescription(JeonseRiskLevel level) {
    return switch (level) {
      JeonseRiskLevel.low =>
        '입력값 기준 위험 신호는 낮지만, 잔금 직전 권리관계 재확인은 필요합니다.',
      JeonseRiskLevel.caution =>
        '계약 전 추가 확인이 필요한 항목이 있습니다. 특약과 보증보험 가능성을 점검하세요.',
      JeonseRiskLevel.high =>
        '보증금 회수 위험이 클 수 있습니다. 계약 보류 또는 전문가 검토를 권장합니다.',
    };
  }

  static String summaryText(JeonseRiskResult result) {
    return '전세사기 위험도 ${levelLabel(result.level)} · ${result.score}점';
  }
}
