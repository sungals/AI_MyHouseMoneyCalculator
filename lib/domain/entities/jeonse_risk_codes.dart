/// 전세사기 위험도 결과의 표시 항목 코드.
/// 도메인은 코드만 만들고 문장은 표현 계층이 지역화한다.
library house_money_calculator.domain.entities.jeonse_risk_codes;

enum JeonseRiskWarning {
  jeonseRatioOver90,
  jeonseRatioOver80,
  seniorDebtOver50,
  seniorDebtOver30,
  combinedOver90,
  combinedOver80,
  registryUnchecked,
  ownerMismatch,
  guaranteeInsuranceUncertain,
  moveInNotPlanned,
  fixedDateNotPlanned,
}

enum JeonseRiskCheck {
  jeonseRatioOver70,
  seniorDebtExists,
  combinedOver70,
  taxArrearsUnchecked,
  noMajorRisk,
}

enum JeonseRiskAction {
  lowerDepositOrCheckInsurance,
  checkNearbyPricesAndInsuranceLimit,
  clearSeniorDebtBeforeBalance,
  verifySeniorDebtMaxAndClearance,
  holdOrRenegotiate,
  checkInsuranceAmountAndClearance,
  verifyRightsInRegistry,
  verifyProxyDocuments,
  requestTaxCertificate,
  checkGuaranteeEligibility,
  reconsiderIfNoMoveIn,
  reconsiderIfNoFixedDate,
  finalCheckBeforeContract,
}

enum JeonseProtectionStep {
  recheckRegistryOnClosing,
  reportMoveInAndFixedDate,
  addSpecialTerms,
}
