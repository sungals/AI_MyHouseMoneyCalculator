import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '어떤비용';

  @override
  String get commonCancel => '취소';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonClose => '닫기';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonError => '오류가 발생했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get settingsThemeLabel => '테마';

  @override
  String get settingsThemeSystem => '시스템 설정 따름';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsLanguageLabel => '언어';

  @override
  String get settingsLanguageSystem => '시스템 설정 따름';

  @override
  String get settingsLanguageKorean => '한국어';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get guideTitle => '앱 설명 및 사용법';

  @override
  String get guideIntroTagline => '계산부터 저장, 공유까지 한 흐름으로 사용하는 생활금융 계산 앱입니다.';

  @override
  String get guideFlowStep1Title => '1. 계산기 선택';

  @override
  String get guideFlowStep1Body => '홈에서 필요한 주거 비용 계산기를 고릅니다.';

  @override
  String get guideFlowStep2Title => '2. 금액과 조건 입력';

  @override
  String get guideFlowStep2Body => '입력 금액은 3억2천만원처럼 한글 금액으로 함께 표시됩니다.';

  @override
  String get guideFlowStep3Title => '3. 결과 저장과 공유';

  @override
  String get guideFlowStep3Body => '계산 결과를 저장하고 최근계산 탭에서 PDF/CSV로 내보냅니다.';

  @override
  String get guideCategoryLeaseTitle => '임대차 계산';

  @override
  String get guideCategoryLeaseSubtitle => '전월세 비용 비교와 반전세 적정가를 확인합니다.';

  @override
  String get guideCategoryFinanceTitle => '대출 · 금융';

  @override
  String get guideCategoryFinanceSubtitle => '대출 이자, 상환 한도, 월 지출을 계산합니다.';

  @override
  String get guideCategoryTaxTitle => '세금 · 비용';

  @override
  String get guideCategoryTaxSubtitle => '주거 관련 세금과 비용을 간이 계산합니다.';

  @override
  String get guideJeonseRentTitle => '전세 vs 월세 비교';

  @override
  String get guideJeonseRentSummary => '전세 대출이자와 월세를 같은 기간 기준으로 비교합니다.';

  @override
  String get guideJeonseRentStep1 => '전세 보증금, 대출금, 금리 입력';

  @override
  String get guideJeonseRentStep2 => '월세 보증금과 월세 입력';

  @override
  String get guideJeonseRentStep3 => '월 비용과 총 비용 차이 확인';

  @override
  String get guideSemiRentTitle => '반전세 계산';

  @override
  String get guideSemiRentSummary => '보증금 차액을 월세로 바꿨을 때 적정한지 확인합니다.';

  @override
  String get guideSemiRentStep1 => '기존 보증금과 변경 보증금 입력';

  @override
  String get guideSemiRentStep2 => '월세와 전월세 전환율 입력';

  @override
  String get guideSemiRentStep3 => '과하거나 유리한 월세인지 확인';

  @override
  String get guideLoanInterestTitle => '대출이자 계산';

  @override
  String get guideLoanInterestSummary => '대출금, 금리, 기간으로 월 이자와 총 이자를 계산합니다.';

  @override
  String get guideLoanInterestStep1 => '대출금 입력';

  @override
  String get guideLoanInterestStep2 => '연 금리와 개월 수 입력';

  @override
  String get guideLoanInterestStep3 => '월 이자와 기간 총 이자 확인';

  @override
  String get guideDsrDtiTitle => 'DSR/DTI 계산';

  @override
  String get guideDsrDtiSummary => '연소득 대비 대출 상환 부담을 비율로 확인합니다.';

  @override
  String get guideDsrDtiStep1 => '연소득 입력';

  @override
  String get guideDsrDtiStep2 => '주택담보대출과 기타 대출 입력';

  @override
  String get guideDsrDtiStep3 => 'DSR/DTI 비율 확인';

  @override
  String get guideMonthlyExpenseTitle => '월 고정비 계산';

  @override
  String get guideMonthlyExpenseSummary => '주거비와 생활비를 합산해 월 지출 구조를 봅니다.';

  @override
  String get guideMonthlyExpenseStep1 => '월세, 관리비, 통신비 등 항목 입력';

  @override
  String get guideMonthlyExpenseStep2 => '월 합계와 연간 합계 확인';

  @override
  String get guideMonthlyExpenseStep3 => '저장 후 반복 지출 비교';

  @override
  String get guideTaxDeductionTitle => '연말정산 세액공제';

  @override
  String get guideTaxDeductionSummary => '월세와 전세대출 관련 공제 가능 금액을 간이 계산합니다.';

  @override
  String get guideTaxDeductionStep1 => '소득과 주거 유형 선택';

  @override
  String get guideTaxDeductionStep2 => '월세 또는 전세대출 조건 입력';

  @override
  String get guideTaxDeductionStep3 => '예상 공제액 확인';

  @override
  String get guideBrokerageFeeTitle => '중개보수 계산';

  @override
  String get guideBrokerageFeeSummary => '매매와 임대차 중개보수 상한을 빠르게 확인합니다.';

  @override
  String get guideBrokerageFeeStep1 => '거래 유형 선택';

  @override
  String get guideBrokerageFeeStep2 => '거래 금액 입력';

  @override
  String get guideBrokerageFeeStep3 => '상한 요율과 예상 보수 확인';

  @override
  String get guideAcquisitionTaxTitle => '취득세 계산';

  @override
  String get guideAcquisitionTaxSummary => '취득가액, 보유 주택 수, 지역 조건으로 간이 계산합니다.';

  @override
  String get guideAcquisitionTaxStep1 => '취득가액 입력';

  @override
  String get guideAcquisitionTaxStep2 => '보유 주택 수와 조정지역 여부 선택';

  @override
  String get guideAcquisitionTaxStep3 => '세율과 예상 세액 확인';

  @override
  String get guidePreviewJeonseMonthlyLabel => '전세 월비용';

  @override
  String get guidePreviewJeonseItem1 => '대출이자';

  @override
  String get guidePreviewJeonseItem2 => '+ 자기자본 기회비용';

  @override
  String get guidePreviewJeonseAmount => '월 116만원';

  @override
  String get guidePreviewRentMonthlyLabel => '월세 월비용';

  @override
  String get guidePreviewRentItem1 => '월세 + 관리비';

  @override
  String get guidePreviewRentItem2 => '+ 보증금 기회비용';

  @override
  String get guidePreviewRentAmount => '월 145만원';

  @override
  String get guidePreviewOpportunityCostFormula => '기회비용 = 보증금 × 시중금리 ÷ 12';

  @override
  String get guidePreviewSemiRentFormula => '적정월세 = (전세금 − 보증금) × 전환율 ÷ 12';

  @override
  String get guidePreviewConversionCapLabel => '전환율 법정 상한';

  @override
  String get guidePreviewConversionCapValue => '기준금리 + 2%p';

  @override
  String get guidePreviewConversionExampleLabel => '현재 전환율 예시';

  @override
  String get guidePreviewConversionExampleValue => '약 4.5%';

  @override
  String get guidePreviewLoanFormula => '월 이자 = 대출금 × 연이율 ÷ 12\n총 이자 = 월 이자 × 기간(개월)';

  @override
  String get guidePreviewLoanExample => '예시: 3억2천 × 4.0% ÷ 12';

  @override
  String get guidePreviewLoanInterestType => '단리(거치식)';

  @override
  String get guidePreviewLoanMonthlyLabel => '월 이자';

  @override
  String get guidePreviewLoanMonthlyValue => '1,066,667원';

  @override
  String get guidePreviewExpenseHousing => '주거비';

  @override
  String get guidePreviewExpenseMaintenance => '관리비';

  @override
  String get guidePreviewExpenseCommunication => '통신비';

  @override
  String get guidePreviewExpenseTransport => '교통비';

  @override
  String get guidePreviewExpenseInsurance => '보험료';

  @override
  String get guidePreviewExpenseSubscription => '구독료';

  @override
  String get guidePreviewMonthlyToYearly => '월 합계 → 연간 합계';

  @override
  String get guidePreviewTimesTwelve => '× 12개월 자동 계산';

  @override
  String get guidePreviewRentTaxCreditHeader => '월세 세액공제';

  @override
  String get guidePreviewSalaryUnder55 => '총급여 5,500만원 이하';

  @override
  String get guidePreviewSalary55To80 => '5,500 ~ 8,000만원';

  @override
  String get guidePreviewSalaryOver80 => '8,000만원 초과';

  @override
  String get guidePreviewNotDeductible => '공제 불가';

  @override
  String get guidePreviewJeonseLoanDeductionHeader => '전세대출 소득공제';

  @override
  String get guidePreviewPrincipalAndInterest => '원리금 상환액 × 40%';

  @override
  String get guidePreviewDeductionLimit => '한도 300만원';

  @override
  String get guidePreviewDsrDtiFormula => 'DSR = 모든대출 연간 원리금 ÷ 연소득 × 100%\nDTI = (주담대 원리금 + 기타 이자) ÷ 연소득 × 100%';

  @override
  String get guidePreviewBandSafe => '안전';

  @override
  String get guidePreviewBandCaution => '주의';

  @override
  String get guidePreviewBandRisk => '위험';

  @override
  String get guidePreviewDealTypeAmount => '거래 유형 / 금액';

  @override
  String get guidePreviewMaxRate => '상한 요율';

  @override
  String get guidePreviewSaleUnder500M => '매매 · 5억 미만';

  @override
  String get guidePreviewSaleOver500M => '매매 · 5억 이상';

  @override
  String get guidePreviewLeaseUnder100M => '임대차 · 1억 미만';

  @override
  String get guidePreviewLeaseOver100M => '임대차 · 1억 이상';

  @override
  String get guidePreviewVatSeparate => '부가세 10% 별도';

  @override
  String get guidePreviewHomesAndCondition => '보유 주택 수 / 조건';

  @override
  String get guidePreviewTaxRate => '세율';

  @override
  String get guidePreviewOneHomeUnder600M => '1주택 · 6억 이하';

  @override
  String get guidePreviewOneHome600To900M => '1주택 · 6~9억';

  @override
  String get guidePreviewOneHomeOver900M => '1주택 · 9억 초과';

  @override
  String get guidePreviewTwoHomesRegulated => '2주택 (조정지역)';

  @override
  String get guidePreviewThreeOrMoreHomes => '3주택 이상';

  @override
  String get guidePreviewRateBand1To3 => '1~3% 구간';

  @override
  String get guidePreviewSurtaxNote => '농특세·교육세 포함 시 추가';

  @override
  String get guideSavedTitle => '저장한 계산 활용';

  @override
  String get guideSaveResultTitle => '결과 저장';

  @override
  String get guideSaveResultBody => '계산 결과 화면에서 저장하면 최근계산 탭에 기록됩니다.';

  @override
  String get guideFavoriteMemoTitle => '즐겨찾기와 메모';

  @override
  String get guideFavoriteMemoBody => '자주 보는 계산은 즐겨찾기하고, 상세 화면에서 메모를 남길 수 있습니다.';

  @override
  String get guideExportShareTitle => 'PDF/CSV 공유';

  @override
  String get guideExportShareBody => '상세 화면에서 PDF와 CSV로 내보내거나 공유합니다.';

  @override
  String get guideAccountSyncTitle => '계정, 동기화, 공지';

  @override
  String get guideSyncHeader => '로그인하면 기록이 동기화됩니다';

  @override
  String get guideSyncBody => '오프라인 상태에서는 로컬에 먼저 저장되고, 네트워크가 가능할 때 서버와 맞춰집니다.';

  @override
  String get guideSyncNodeApp => '앱';

  @override
  String get guideSyncNodeServer => '서버';

  @override
  String get guidePinBiometricHeader => 'PIN과 생체인증으로 앱 재진입 보호';

  @override
  String get guideNoticePushHeader => '공지와 푸시 알림';

  @override
  String get guideNoticePushBody => '공지사항은 설정에서 확인할 수 있고, 로그인 상태에서 푸시 알림을 켜면 새 공지 등록 시 알림을 받을 수 있습니다.';

  @override
  String get guideDisclaimer => '앱의 계산 결과는 입력값을 기준으로 한 참고용 간이 계산입니다. 실제 대출, 세금, 중개보수, 계약 조건은 지역, 시점, 개인 상황, 관련 법령에 따라 달라질 수 있으므로 최종 결정 전 전문가 또는 공식 기관을 통해 확인해야 합니다.';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionAccount => '계정';

  @override
  String get settingsSignedIn => '로그인됨';

  @override
  String get settingsAccountManage => '계정 관리';

  @override
  String get settingsSignIn => '로그인';

  @override
  String get settingsSectionSecurity => '보안';

  @override
  String get settingsQuickLoginEnabled => '간편로그인 사용 중';

  @override
  String get settingsQuickLoginSetup => '간편로그인 설정';

  @override
  String get settingsQuickLoginDisable => '해제';

  @override
  String get settingsPinChange => 'PIN 변경';

  @override
  String get settingsBiometricReset => '생체인증 재설정';

  @override
  String get settingsRequireAuthOnLaunch => '앱 재진입 시 인증';

  @override
  String get settingsSectionNotification => '알림';

  @override
  String get settingsNoticePush => '공지 알림';

  @override
  String get settingsSectionThemeLanguage => '테마·언어';

  @override
  String get settingsSectionAppInfo => '앱 정보';

  @override
  String get settingsAppGuide => '앱 사용법';

  @override
  String get settingsNotices => '공지사항';

  @override
  String get settingsVersion => '버전';

  @override
  String get settingsSectionLegal => '약관';

  @override
  String get settingsTermsOfService => '이용약관';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get settingsOpenSourceLicenses => '오픈소스 라이선스';

  @override
  String get settingsSignOut => '로그아웃';

  @override
  String get settingsSectionAdmin => '관리자';

  @override
  String get settingsManageNotices => '공지사항 관리';

  @override
  String get settingsDangerZone => '위험 구역';

  @override
  String get settingsDeleteAccount => '회원탈퇴';

  @override
  String get settingsDeleteAccountCaption => '탈퇴하면 계정과 저장된 모든 계산 기록이 삭제되며 되돌릴 수 없습니다.';

  @override
  String get settingsDeleteAccountConfirm => '탈퇴하면 계정과 저장된 모든 계산 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get settingsDeleteAccountAction => '탈퇴하기';

  @override
  String settingsErrorWithMessage(String message) {
    return '오류: $message';
  }

  @override
  String get settingsNoticesEmpty => '등록된 공지사항이 없습니다';

  @override
  String settingsNoticesLoadError(String error) {
    return '공지사항을 불러오지 못했습니다\n$error';
  }

  @override
  String get settingsNoticeNotFound => '공지사항을 찾을 수 없습니다';

  @override
  String get monthlyExpenseTitle => '월 고정비 계산';

  @override
  String get monthlyExpenseSectionTitle => '월 고정 지출';

  @override
  String get monthlyExpenseHelpTitle => '월 고정비란?';

  @override
  String get monthlyExpenseHelpBody => '매달 일정하게 나가는 생활 고정 지출 항목입니다.\n\n• 주거비: 월세 또는 전세 대출 월 이자\n• 관리비: 건물 관리·공용 시설 이용 비용\n• 통신비: 핸드폰·인터넷 요금\n• 교통비: 교통카드·주유비 등\n• 보험료: 생명보험·실손보험 등 월 납부 보험\n• 구독료: 넷플릭스·스포티파이 등 구독 서비스\n• 식비: 외식비·식재료비\n• 기타: 그 외 고정 지출\n\n0원인 항목은 결과에서 제외됩니다.';

  @override
  String get monthlyExpenseHousingFieldLabel => '주거비 (월세/이자)';

  @override
  String get monthlyExpenseCategoryHousing => '주거비';

  @override
  String get monthlyExpenseCategoryMaintenance => '관리비';

  @override
  String get monthlyExpenseCategoryCommunication => '통신비';

  @override
  String get monthlyExpenseCategoryTransportation => '교통비';

  @override
  String get monthlyExpenseCategoryInsurance => '보험료';

  @override
  String get monthlyExpenseCategorySubscription => '구독료';

  @override
  String get monthlyExpenseCategoryFood => '식비';

  @override
  String get monthlyExpenseCategoryOther => '기타';

  @override
  String get monthlyExpenseCalculate => '계산하기';

  @override
  String get monthlyExpenseResultTitle => '계산 결과';

  @override
  String get monthlyExpenseMonthlyTotalLabel => '월 합계';

  @override
  String get monthlyExpenseAnnualTotalLabel => '연간 합계';

  @override
  String get monthlyExpenseSaved => '계산 결과가 저장되었습니다.';

  @override
  String get monthlyExpenseShareSubject => '월 고정비 계산 결과';

  @override
  String monthlyExpenseShareHeader(String appName) {
    return '[$appName] 월 고정비 계산 결과';
  }

  @override
  String monthlyExpenseShareLine(String label, String amount) {
    return '$label: $amount';
  }

  @override
  String monthlyExpenseShareMonthlyTotal(String amount) {
    return '월 합계: $amount';
  }

  @override
  String monthlyExpenseShareAnnualTotal(String amount) {
    return '연간 합계: $amount';
  }

  @override
  String get monthlyExpenseShareDisclaimer => '※ 본 계산 결과는 참고용입니다.';

  @override
  String get loanInterestTitle => '대출이자 계산';

  @override
  String get loanInterestSectionTitle => '대출 조건';

  @override
  String get loanInterestHelpTitle => '대출이자 계산이란?';

  @override
  String get loanInterestHelpBody => '단리(이자만 납부) 방식으로 월 이자와 총 이자를 계산합니다.\n\n• 대출금: 은행에서 빌리는 원금\n• 연이율: 연간 적용 이자율 (예: 4.5%)\n• 대출 기간: 이자를 납부할 기간 (개월)\n\n월 이자 = 대출금 × 연이율 ÷ 12\n총 이자 = 월 이자 × 대출 기간\n\n원리금 균등 상환(원금도 함께 갚는 방식)과는\n계산 방법이 다릅니다.';

  @override
  String get loanInterestAmountLabel => '대출금';

  @override
  String get loanInterestRateLabel => '연이율';

  @override
  String get loanInterestMonthsLabel => '대출 기간';

  @override
  String get loanInterestMonthsHint => '예: 24';

  @override
  String get loanInterestMonthsSuffix => '개월';

  @override
  String loanInterestMonthsValue(int months) {
    return '$months개월';
  }

  @override
  String get loanInterestCalculate => '계산하기';

  @override
  String get loanInterestResultTitle => '계산 결과';

  @override
  String get loanInterestMonthlyInterestLabel => '월 이자';

  @override
  String loanInterestTotalInterestLabel(int months) {
    return '$months개월 총 이자';
  }

  @override
  String get loanInterestSaved => '계산 결과가 저장되었습니다.';

  @override
  String get loanInterestShareSubject => '대출이자 계산 결과';

  @override
  String loanInterestShareHeader(String appName) {
    return '[$appName] 대출이자 계산 결과';
  }

  @override
  String loanInterestShareLoanAmount(String amount) {
    return '대출금: $amount';
  }

  @override
  String loanInterestShareMonthlyInterest(String amount) {
    return '월 이자: $amount';
  }

  @override
  String loanInterestShareTotalInterest(int months, String amount) {
    return '$months개월 총 이자: $amount';
  }

  @override
  String get loanInterestShareDisclaimer => '※ 본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.';

  @override
  String get taxDeductionTitle => '연말정산 세액공제';

  @override
  String get taxDeductionPdfTitle => '연말정산 세액공제 결과';

  @override
  String get taxDeductionPdfRentRate => '월세 공제율';

  @override
  String get taxDeductionPdfRentTaxCredit => '월세 세액공제';

  @override
  String get taxDeductionPdfLoanTaxSaving => '전세대출 절세액';

  @override
  String get taxDeductionIncomeSection => '소득 정보';

  @override
  String get taxDeductionAnnualSalaryLabel => '연간 총급여';

  @override
  String get taxDeductionIncomeTaxRateLabel => '소득세율 (과세표준 기준)';

  @override
  String get taxDeductionRentSection => '월세 세액공제';

  @override
  String get taxDeductionRentRateGuide => '총급여 5,500만원 이하 17% / 7,000만원 이하 15% / 초과 0%';

  @override
  String get taxDeductionMonthlyRentLabel => '월세 (월)';

  @override
  String get taxDeductionLoanSection => '전세대출 원리금 소득공제';

  @override
  String get taxDeductionLoanGuide => '연 상환액의 40% 소득공제, 연 400만원 한도';

  @override
  String get taxDeductionAnnualRepaymentLabel => '연간 원리금 상환액';

  @override
  String get taxDeductionCalculate => '계산하기';

  @override
  String get taxDeductionRentRateRowLabel => '공제율';

  @override
  String get taxDeductionEligibleAnnualRentLabel => '공제 대상 연 월세';

  @override
  String get taxDeductionRentTaxCreditLabel => '세액공제액';

  @override
  String get taxDeductionLoanResultSection => '전세대출 소득공제';

  @override
  String get taxDeductionEligibleRepaymentLabel => '공제 대상 상환액';

  @override
  String get taxDeductionIncomeDeductionLabel => '소득공제액 (40%)';

  @override
  String taxDeductionLoanTaxSavingLabel(String rate) {
    return '절세액 (세율 $rate%)';
  }

  @override
  String get taxDeductionTotalBenefitLabel => '연간 총 절세 혜택';

  @override
  String get taxDeductionMessageIncomeTooHigh => '총급여 7천만원 초과로 월세 세액공제 대상이 아닙니다.';

  @override
  String taxDeductionMessageIncomeTooHighWithLoan(String amount) {
    return '총급여 7천만원 초과로 월세 세액공제는 받을 수 없지만, 전세대출 소득공제로 연간 최대 $amount 아낄 수 있어요.';
  }

  @override
  String taxDeductionMessageHasBenefit(String amount) {
    return '연간 최대 $amount 세금을 아낄 수 있어요!';
  }

  @override
  String get taxDeductionMessageNoInput => '해당하는 공제 항목을 입력해 주세요.';

  @override
  String get sharedHomeTab => '홈';

  @override
  String get sharedHousingTab => '주거';

  @override
  String get sharedHousingHeadline => '계약과 임대료를\n비교하세요';

  @override
  String get sharedHousingDescription => '전세, 월세, 반전세, 계약 갱신처럼 집 계약에 직접 연결되는 계산입니다.';

  @override
  String get sharedFinanceTab => '금융';

  @override
  String get sharedFinanceHeadline => '대출과 세금을\n따져보세요';

  @override
  String get sharedFinanceDescription => '대출 부담, 월 고정비, 세액공제, 거래 비용을 한곳에 모았습니다.';

  @override
  String get sharedRecentTab => '최근계산';

  @override
  String get sharedSettingsTab => '설정';

  @override
  String get sharedResetAmount => '초기화';

  @override
  String get sharedPercentHint => '예: 3.5';

  @override
  String get sharedShareAction => '공유';

  @override
  String get sharedExportPdfAction => 'PDF 내보내기';

  @override
  String get sharedDisclaimerMain => '본 앱은 전세, 월세, 대출 이자, 월 고정비 등을 단순 계산하기 위한 참고용 도구입니다.\n실제 대출 가능 여부, 금리, 세금, 보증금 반환 가능성, 계약 위험도는 금융기관, 세무사, 공인중개사 등 전문가에게 반드시 확인하시기 바랍니다.\n본 앱의 계산 결과는 법적·금융적 판단의 근거로 사용할 수 없습니다.';

  @override
  String get sharedDisclaimerShort => '본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.';

  @override
  String get sharedAdLabel => '광고';

  @override
  String get sharedOfflineBanner => '오프라인 상태입니다';

  @override
  String get notificationNoticeChannelName => '공지사항';

  @override
  String get notificationNoticeChannelDescription => '새 공지사항 알림';

  @override
  String get notificationNoticeFallbackTitle => '공지사항';
}
