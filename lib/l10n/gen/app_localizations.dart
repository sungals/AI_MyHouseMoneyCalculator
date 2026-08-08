import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// 앱 이름. 태스크 스위처에 표시
  ///
  /// In ko, this message translates to:
  /// **'어떤비용'**
  String get appTitle;

  /// 다이얼로그 취소 버튼
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// 다이얼로그 확인 버튼
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get commonConfirm;

  /// 저장 버튼
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// 삭제 버튼
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// 닫기 버튼
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// 실패 후 재시도 버튼
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get commonRetry;

  /// 일반 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했어요. 잠시 후 다시 시도해 주세요.'**
  String get commonError;

  /// 테마 선택 항목 라벨
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get settingsThemeLabel;

  /// 테마 옵션
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따름'**
  String get settingsThemeSystem;

  /// 테마 옵션
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get settingsThemeLight;

  /// 테마 옵션
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get settingsThemeDark;

  /// 언어 선택 항목 라벨
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguageLabel;

  /// 언어 옵션
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따름'**
  String get settingsLanguageSystem;

  /// 언어 옵션. 두 로케일에서 동일하게 표기
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get settingsLanguageKorean;

  /// 언어 옵션. 두 로케일에서 동일하게 표기
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// 앱 가이드 화면 앱바 제목
  ///
  /// In ko, this message translates to:
  /// **'앱 설명 및 사용법'**
  String get guideTitle;

  /// 첫 페이지 앱 소개 한 줄
  ///
  /// In ko, this message translates to:
  /// **'계산부터 저장, 공유까지 한 흐름으로 사용하는 생활금융 계산 앱입니다.'**
  String get guideIntroTagline;

  /// 사용 흐름 1단계 제목
  ///
  /// In ko, this message translates to:
  /// **'1. 계산기 선택'**
  String get guideFlowStep1Title;

  /// 사용 흐름 1단계 설명
  ///
  /// In ko, this message translates to:
  /// **'홈에서 필요한 주거 비용 계산기를 고릅니다.'**
  String get guideFlowStep1Body;

  /// 사용 흐름 2단계 제목
  ///
  /// In ko, this message translates to:
  /// **'2. 금액과 조건 입력'**
  String get guideFlowStep2Title;

  /// 사용 흐름 2단계 설명. 금액 보조 표기 안내
  ///
  /// In ko, this message translates to:
  /// **'입력 금액은 3억2천만원처럼 한글 금액으로 함께 표시됩니다.'**
  String get guideFlowStep2Body;

  /// 사용 흐름 3단계 제목
  ///
  /// In ko, this message translates to:
  /// **'3. 결과 저장과 공유'**
  String get guideFlowStep3Title;

  /// 사용 흐름 3단계 설명
  ///
  /// In ko, this message translates to:
  /// **'계산 결과를 저장하고 최근계산 탭에서 PDF/CSV로 내보냅니다.'**
  String get guideFlowStep3Body;

  /// 임대차 카테고리 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'임대차 계산'**
  String get guideCategoryLeaseTitle;

  /// 임대차 카테고리 페이지 부제
  ///
  /// In ko, this message translates to:
  /// **'전월세 비용 비교와 반전세 적정가를 확인합니다.'**
  String get guideCategoryLeaseSubtitle;

  /// 대출·금융 카테고리 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'대출 · 금융'**
  String get guideCategoryFinanceTitle;

  /// 대출·금융 카테고리 페이지 부제
  ///
  /// In ko, this message translates to:
  /// **'대출 이자, 상환 한도, 월 지출을 계산합니다.'**
  String get guideCategoryFinanceSubtitle;

  /// 세금·비용 카테고리 페이지 제목
  ///
  /// In ko, this message translates to:
  /// **'세금 · 비용'**
  String get guideCategoryTaxTitle;

  /// 세금·비용 카테고리 페이지 부제
  ///
  /// In ko, this message translates to:
  /// **'주거 관련 세금과 비용을 간이 계산합니다.'**
  String get guideCategoryTaxSubtitle;

  /// 전세·월세 비교 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'전세 vs 월세 비교'**
  String get guideJeonseRentTitle;

  /// 전세·월세 비교 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'전세 대출이자와 월세를 같은 기간 기준으로 비교합니다.'**
  String get guideJeonseRentSummary;

  /// 전세·월세 비교 1단계
  ///
  /// In ko, this message translates to:
  /// **'전세 보증금, 대출금, 금리 입력'**
  String get guideJeonseRentStep1;

  /// 전세·월세 비교 2단계
  ///
  /// In ko, this message translates to:
  /// **'월세 보증금과 월세 입력'**
  String get guideJeonseRentStep2;

  /// 전세·월세 비교 3단계
  ///
  /// In ko, this message translates to:
  /// **'월 비용과 총 비용 차이 확인'**
  String get guideJeonseRentStep3;

  /// 반전세 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'반전세 계산'**
  String get guideSemiRentTitle;

  /// 반전세 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'보증금 차액을 월세로 바꿨을 때 적정한지 확인합니다.'**
  String get guideSemiRentSummary;

  /// 반전세 1단계
  ///
  /// In ko, this message translates to:
  /// **'기존 보증금과 변경 보증금 입력'**
  String get guideSemiRentStep1;

  /// 반전세 2단계
  ///
  /// In ko, this message translates to:
  /// **'월세와 전월세 전환율 입력'**
  String get guideSemiRentStep2;

  /// 반전세 3단계
  ///
  /// In ko, this message translates to:
  /// **'과하거나 유리한 월세인지 확인'**
  String get guideSemiRentStep3;

  /// 대출이자 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'대출이자 계산'**
  String get guideLoanInterestTitle;

  /// 대출이자 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'대출금, 금리, 기간으로 월 이자와 총 이자를 계산합니다.'**
  String get guideLoanInterestSummary;

  /// 대출이자 1단계
  ///
  /// In ko, this message translates to:
  /// **'대출금 입력'**
  String get guideLoanInterestStep1;

  /// 대출이자 2단계
  ///
  /// In ko, this message translates to:
  /// **'연 금리와 개월 수 입력'**
  String get guideLoanInterestStep2;

  /// 대출이자 3단계
  ///
  /// In ko, this message translates to:
  /// **'월 이자와 기간 총 이자 확인'**
  String get guideLoanInterestStep3;

  /// DSR/DTI 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'DSR/DTI 계산'**
  String get guideDsrDtiTitle;

  /// DSR/DTI 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'연소득 대비 대출 상환 부담을 비율로 확인합니다.'**
  String get guideDsrDtiSummary;

  /// DSR/DTI 1단계
  ///
  /// In ko, this message translates to:
  /// **'연소득 입력'**
  String get guideDsrDtiStep1;

  /// DSR/DTI 2단계
  ///
  /// In ko, this message translates to:
  /// **'주택담보대출과 기타 대출 입력'**
  String get guideDsrDtiStep2;

  /// DSR/DTI 3단계
  ///
  /// In ko, this message translates to:
  /// **'DSR/DTI 비율 확인'**
  String get guideDsrDtiStep3;

  /// 월 고정비 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'월 고정비 계산'**
  String get guideMonthlyExpenseTitle;

  /// 월 고정비 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'주거비와 생활비를 합산해 월 지출 구조를 봅니다.'**
  String get guideMonthlyExpenseSummary;

  /// 월 고정비 1단계
  ///
  /// In ko, this message translates to:
  /// **'월세, 관리비, 통신비 등 항목 입력'**
  String get guideMonthlyExpenseStep1;

  /// 월 고정비 2단계
  ///
  /// In ko, this message translates to:
  /// **'월 합계와 연간 합계 확인'**
  String get guideMonthlyExpenseStep2;

  /// 월 고정비 3단계
  ///
  /// In ko, this message translates to:
  /// **'저장 후 반복 지출 비교'**
  String get guideMonthlyExpenseStep3;

  /// 연말정산 세액공제 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'연말정산 세액공제'**
  String get guideTaxDeductionTitle;

  /// 연말정산 세액공제 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'월세와 전세대출 관련 공제 가능 금액을 간이 계산합니다.'**
  String get guideTaxDeductionSummary;

  /// 세액공제 1단계
  ///
  /// In ko, this message translates to:
  /// **'소득과 주거 유형 선택'**
  String get guideTaxDeductionStep1;

  /// 세액공제 2단계
  ///
  /// In ko, this message translates to:
  /// **'월세 또는 전세대출 조건 입력'**
  String get guideTaxDeductionStep2;

  /// 세액공제 3단계
  ///
  /// In ko, this message translates to:
  /// **'예상 공제액 확인'**
  String get guideTaxDeductionStep3;

  /// 중개보수 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'중개보수 계산'**
  String get guideBrokerageFeeTitle;

  /// 중개보수 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'매매와 임대차 중개보수 상한을 빠르게 확인합니다.'**
  String get guideBrokerageFeeSummary;

  /// 중개보수 1단계
  ///
  /// In ko, this message translates to:
  /// **'거래 유형 선택'**
  String get guideBrokerageFeeStep1;

  /// 중개보수 2단계
  ///
  /// In ko, this message translates to:
  /// **'거래 금액 입력'**
  String get guideBrokerageFeeStep2;

  /// 중개보수 3단계
  ///
  /// In ko, this message translates to:
  /// **'상한 요율과 예상 보수 확인'**
  String get guideBrokerageFeeStep3;

  /// 취득세 계산기 가이드 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'취득세 계산'**
  String get guideAcquisitionTaxTitle;

  /// 취득세 계산기 요약
  ///
  /// In ko, this message translates to:
  /// **'취득가액, 보유 주택 수, 지역 조건으로 간이 계산합니다.'**
  String get guideAcquisitionTaxSummary;

  /// 취득세 1단계
  ///
  /// In ko, this message translates to:
  /// **'취득가액 입력'**
  String get guideAcquisitionTaxStep1;

  /// 취득세 2단계
  ///
  /// In ko, this message translates to:
  /// **'보유 주택 수와 조정지역 여부 선택'**
  String get guideAcquisitionTaxStep2;

  /// 취득세 3단계
  ///
  /// In ko, this message translates to:
  /// **'세율과 예상 세액 확인'**
  String get guideAcquisitionTaxStep3;

  /// 전세·월세 비교 미리보기 좌측 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'전세 월비용'**
  String get guidePreviewJeonseMonthlyLabel;

  /// 전세 월비용 구성 항목
  ///
  /// In ko, this message translates to:
  /// **'대출이자'**
  String get guidePreviewJeonseItem1;

  /// 전세 월비용 구성 항목
  ///
  /// In ko, this message translates to:
  /// **'+ 자기자본 기회비용'**
  String get guidePreviewJeonseItem2;

  /// 전세 월비용 예시 금액. 실제 계산값이 아닌 화면 예시
  ///
  /// In ko, this message translates to:
  /// **'월 116만원'**
  String get guidePreviewJeonseAmount;

  /// 전세·월세 비교 미리보기 우측 카드 제목
  ///
  /// In ko, this message translates to:
  /// **'월세 월비용'**
  String get guidePreviewRentMonthlyLabel;

  /// 월세 월비용 구성 항목
  ///
  /// In ko, this message translates to:
  /// **'월세 + 관리비'**
  String get guidePreviewRentItem1;

  /// 월세 월비용 구성 항목
  ///
  /// In ko, this message translates to:
  /// **'+ 보증금 기회비용'**
  String get guidePreviewRentItem2;

  /// 월세 월비용 예시 금액. 실제 계산값이 아닌 화면 예시
  ///
  /// In ko, this message translates to:
  /// **'월 145만원'**
  String get guidePreviewRentAmount;

  /// 기회비용 산식
  ///
  /// In ko, this message translates to:
  /// **'기회비용 = 보증금 × 시중금리 ÷ 12'**
  String get guidePreviewOpportunityCostFormula;

  /// 반전세 적정월세 산식
  ///
  /// In ko, this message translates to:
  /// **'적정월세 = (전세금 − 보증금) × 전환율 ÷ 12'**
  String get guidePreviewSemiRentFormula;

  /// 전월세 전환율 법정 상한 라벨
  ///
  /// In ko, this message translates to:
  /// **'전환율 법정 상한'**
  String get guidePreviewConversionCapLabel;

  /// 전월세 전환율 법정 상한 값
  ///
  /// In ko, this message translates to:
  /// **'기준금리 + 2%p'**
  String get guidePreviewConversionCapValue;

  /// 전월세 전환율 예시 라벨
  ///
  /// In ko, this message translates to:
  /// **'현재 전환율 예시'**
  String get guidePreviewConversionExampleLabel;

  /// 전월세 전환율 예시 값
  ///
  /// In ko, this message translates to:
  /// **'약 4.5%'**
  String get guidePreviewConversionExampleValue;

  /// 대출이자 산식 두 줄
  ///
  /// In ko, this message translates to:
  /// **'월 이자 = 대출금 × 연이율 ÷ 12\n총 이자 = 월 이자 × 기간(개월)'**
  String get guidePreviewLoanFormula;

  /// 대출이자 계산 예시
  ///
  /// In ko, this message translates to:
  /// **'예시: 3억2천 × 4.0% ÷ 12'**
  String get guidePreviewLoanExample;

  /// 대출이자 계산 방식 칩
  ///
  /// In ko, this message translates to:
  /// **'단리(거치식)'**
  String get guidePreviewLoanInterestType;

  /// 대출이자 미리보기 월 이자 라벨
  ///
  /// In ko, this message translates to:
  /// **'월 이자'**
  String get guidePreviewLoanMonthlyLabel;

  /// 대출이자 미리보기 예시 금액
  ///
  /// In ko, this message translates to:
  /// **'1,066,667원'**
  String get guidePreviewLoanMonthlyValue;

  /// 월 고정비 항목
  ///
  /// In ko, this message translates to:
  /// **'주거비'**
  String get guidePreviewExpenseHousing;

  /// 월 고정비 항목
  ///
  /// In ko, this message translates to:
  /// **'관리비'**
  String get guidePreviewExpenseMaintenance;

  /// 월 고정비 항목
  ///
  /// In ko, this message translates to:
  /// **'통신비'**
  String get guidePreviewExpenseCommunication;

  /// 월 고정비 항목
  ///
  /// In ko, this message translates to:
  /// **'교통비'**
  String get guidePreviewExpenseTransport;

  /// 월 고정비 항목
  ///
  /// In ko, this message translates to:
  /// **'보험료'**
  String get guidePreviewExpenseInsurance;

  /// 월 고정비 항목
  ///
  /// In ko, this message translates to:
  /// **'구독료'**
  String get guidePreviewExpenseSubscription;

  /// 월 고정비 합계 안내 좌측
  ///
  /// In ko, this message translates to:
  /// **'월 합계 → 연간 합계'**
  String get guidePreviewMonthlyToYearly;

  /// 월 고정비 합계 안내 우측
  ///
  /// In ko, this message translates to:
  /// **'× 12개월 자동 계산'**
  String get guidePreviewTimesTwelve;

  /// 세액공제 미리보기 첫 표 제목
  ///
  /// In ko, this message translates to:
  /// **'월세 세액공제'**
  String get guidePreviewRentTaxCreditHeader;

  /// 월세 세액공제 소득 구간
  ///
  /// In ko, this message translates to:
  /// **'총급여 5,500만원 이하'**
  String get guidePreviewSalaryUnder55;

  /// 월세 세액공제 소득 구간
  ///
  /// In ko, this message translates to:
  /// **'5,500 ~ 8,000만원'**
  String get guidePreviewSalary55To80;

  /// 월세 세액공제 소득 구간
  ///
  /// In ko, this message translates to:
  /// **'8,000만원 초과'**
  String get guidePreviewSalaryOver80;

  /// 공제 대상이 아님을 나타내는 값
  ///
  /// In ko, this message translates to:
  /// **'공제 불가'**
  String get guidePreviewNotDeductible;

  /// 세액공제 미리보기 두 번째 표 제목
  ///
  /// In ko, this message translates to:
  /// **'전세대출 소득공제'**
  String get guidePreviewJeonseLoanDeductionHeader;

  /// 전세대출 소득공제 계산 기준
  ///
  /// In ko, this message translates to:
  /// **'원리금 상환액 × 40%'**
  String get guidePreviewPrincipalAndInterest;

  /// 전세대출 소득공제 한도
  ///
  /// In ko, this message translates to:
  /// **'한도 300만원'**
  String get guidePreviewDeductionLimit;

  /// DSR/DTI 산식 두 줄
  ///
  /// In ko, this message translates to:
  /// **'DSR = 모든대출 연간 원리금 ÷ 연소득 × 100%\nDTI = (주담대 원리금 + 기타 이자) ÷ 연소득 × 100%'**
  String get guidePreviewDsrDtiFormula;

  /// DSR 구간 라벨
  ///
  /// In ko, this message translates to:
  /// **'안전'**
  String get guidePreviewBandSafe;

  /// DSR 구간 라벨
  ///
  /// In ko, this message translates to:
  /// **'주의'**
  String get guidePreviewBandCaution;

  /// DSR 구간 라벨
  ///
  /// In ko, this message translates to:
  /// **'위험'**
  String get guidePreviewBandRisk;

  /// 중개보수 표 좌측 헤더
  ///
  /// In ko, this message translates to:
  /// **'거래 유형 / 금액'**
  String get guidePreviewDealTypeAmount;

  /// 중개보수 표 우측 헤더
  ///
  /// In ko, this message translates to:
  /// **'상한 요율'**
  String get guidePreviewMaxRate;

  /// 중개보수 요율 구간
  ///
  /// In ko, this message translates to:
  /// **'매매 · 5억 미만'**
  String get guidePreviewSaleUnder500M;

  /// 중개보수 요율 구간
  ///
  /// In ko, this message translates to:
  /// **'매매 · 5억 이상'**
  String get guidePreviewSaleOver500M;

  /// 중개보수 요율 구간
  ///
  /// In ko, this message translates to:
  /// **'임대차 · 1억 미만'**
  String get guidePreviewLeaseUnder100M;

  /// 중개보수 요율 구간
  ///
  /// In ko, this message translates to:
  /// **'임대차 · 1억 이상'**
  String get guidePreviewLeaseOver100M;

  /// 중개보수에 부가세가 별도임을 알리는 칩
  ///
  /// In ko, this message translates to:
  /// **'부가세 10% 별도'**
  String get guidePreviewVatSeparate;

  /// 취득세 표 좌측 헤더
  ///
  /// In ko, this message translates to:
  /// **'보유 주택 수 / 조건'**
  String get guidePreviewHomesAndCondition;

  /// 취득세 표 우측 헤더
  ///
  /// In ko, this message translates to:
  /// **'세율'**
  String get guidePreviewTaxRate;

  /// 취득세 세율 구간
  ///
  /// In ko, this message translates to:
  /// **'1주택 · 6억 이하'**
  String get guidePreviewOneHomeUnder600M;

  /// 취득세 세율 구간
  ///
  /// In ko, this message translates to:
  /// **'1주택 · 6~9억'**
  String get guidePreviewOneHome600To900M;

  /// 취득세 세율 구간
  ///
  /// In ko, this message translates to:
  /// **'1주택 · 9억 초과'**
  String get guidePreviewOneHomeOver900M;

  /// 취득세 세율 구간
  ///
  /// In ko, this message translates to:
  /// **'2주택 (조정지역)'**
  String get guidePreviewTwoHomesRegulated;

  /// 취득세 세율 구간
  ///
  /// In ko, this message translates to:
  /// **'3주택 이상'**
  String get guidePreviewThreeOrMoreHomes;

  /// 취득세 누진 구간 값
  ///
  /// In ko, this message translates to:
  /// **'1~3% 구간'**
  String get guidePreviewRateBand1To3;

  /// 취득세에 부가되는 세목 안내 칩
  ///
  /// In ko, this message translates to:
  /// **'농특세·교육세 포함 시 추가'**
  String get guidePreviewSurtaxNote;

  /// 마지막 페이지 첫 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'저장한 계산 활용'**
  String get guideSavedTitle;

  /// 저장 흐름 1단계 제목
  ///
  /// In ko, this message translates to:
  /// **'결과 저장'**
  String get guideSaveResultTitle;

  /// 저장 흐름 1단계 설명
  ///
  /// In ko, this message translates to:
  /// **'계산 결과 화면에서 저장하면 최근계산 탭에 기록됩니다.'**
  String get guideSaveResultBody;

  /// 저장 흐름 2단계 제목
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기와 메모'**
  String get guideFavoriteMemoTitle;

  /// 저장 흐름 2단계 설명
  ///
  /// In ko, this message translates to:
  /// **'자주 보는 계산은 즐겨찾기하고, 상세 화면에서 메모를 남길 수 있습니다.'**
  String get guideFavoriteMemoBody;

  /// 저장 흐름 3단계 제목
  ///
  /// In ko, this message translates to:
  /// **'PDF/CSV 공유'**
  String get guideExportShareTitle;

  /// 저장 흐름 3단계 설명
  ///
  /// In ko, this message translates to:
  /// **'상세 화면에서 PDF와 CSV로 내보내거나 공유합니다.'**
  String get guideExportShareBody;

  /// 마지막 페이지 두 번째 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'계정, 동기화, 공지'**
  String get guideAccountSyncTitle;

  /// 동기화 안내 헤더
  ///
  /// In ko, this message translates to:
  /// **'로그인하면 기록이 동기화됩니다'**
  String get guideSyncHeader;

  /// 동기화 동작 설명
  ///
  /// In ko, this message translates to:
  /// **'오프라인 상태에서는 로컬에 먼저 저장되고, 네트워크가 가능할 때 서버와 맞춰집니다.'**
  String get guideSyncBody;

  /// 동기화 도식의 앱 쪽 노드
  ///
  /// In ko, this message translates to:
  /// **'앱'**
  String get guideSyncNodeApp;

  /// 동기화 도식의 서버 쪽 노드
  ///
  /// In ko, this message translates to:
  /// **'서버'**
  String get guideSyncNodeServer;

  /// 잠금 안내 헤더
  ///
  /// In ko, this message translates to:
  /// **'PIN과 생체인증으로 앱 재진입 보호'**
  String get guidePinBiometricHeader;

  /// 공지 안내 헤더
  ///
  /// In ko, this message translates to:
  /// **'공지와 푸시 알림'**
  String get guideNoticePushHeader;

  /// 공지·푸시 알림 설명
  ///
  /// In ko, this message translates to:
  /// **'공지사항은 설정에서 확인할 수 있고, 로그인 상태에서 푸시 알림을 켜면 새 공지 등록 시 알림을 받을 수 있습니다.'**
  String get guideNoticePushBody;

  /// 가이드 마지막 면책 문구
  ///
  /// In ko, this message translates to:
  /// **'앱의 계산 결과는 입력값을 기준으로 한 참고용 간이 계산입니다. 실제 대출, 세금, 중개보수, 계약 조건은 지역, 시점, 개인 상황, 관련 법령에 따라 달라질 수 있으므로 최종 결정 전 전문가 또는 공식 기관을 통해 확인해야 합니다.'**
  String get guideDisclaimer;

  /// 설정 화면 앱바 제목
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// 설정 화면 계정 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get settingsSectionAccount;

  /// 이메일을 알 수 없을 때 표시하는 로그인 상태 문구
  ///
  /// In ko, this message translates to:
  /// **'로그인됨'**
  String get settingsSignedIn;

  /// 계정 관리 화면으로 가는 항목이자 그 화면의 제목
  ///
  /// In ko, this message translates to:
  /// **'계정 관리'**
  String get settingsAccountManage;

  /// 로그인 화면으로 가는 항목
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get settingsSignIn;

  /// 설정 화면 보안 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'보안'**
  String get settingsSectionSecurity;

  /// PIN 간편로그인이 켜져 있을 때의 항목 제목
  ///
  /// In ko, this message translates to:
  /// **'간편로그인 사용 중'**
  String get settingsQuickLoginEnabled;

  /// PIN 간편로그인이 꺼져 있을 때의 항목 제목
  ///
  /// In ko, this message translates to:
  /// **'간편로그인 설정'**
  String get settingsQuickLoginSetup;

  /// 간편로그인을 끄는 버튼
  ///
  /// In ko, this message translates to:
  /// **'해제'**
  String get settingsQuickLoginDisable;

  /// PIN 변경 화면으로 가는 항목
  ///
  /// In ko, this message translates to:
  /// **'PIN 변경'**
  String get settingsPinChange;

  /// 생체인증을 지우고 다시 설정하는 항목
  ///
  /// In ko, this message translates to:
  /// **'생체인증 재설정'**
  String get settingsBiometricReset;

  /// 앱을 다시 열 때 인증을 요구할지 정하는 스위치
  ///
  /// In ko, this message translates to:
  /// **'앱 재진입 시 인증'**
  String get settingsRequireAuthOnLaunch;

  /// 설정 화면 알림 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get settingsSectionNotification;

  /// 공지 푸시 알림 수신 스위치
  ///
  /// In ko, this message translates to:
  /// **'공지 알림'**
  String get settingsNoticePush;

  /// 설정 화면 테마·언어 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'테마·언어'**
  String get settingsSectionThemeLanguage;

  /// 설정 화면 앱 정보 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settingsSectionAppInfo;

  /// 앱 가이드 화면으로 가는 항목
  ///
  /// In ko, this message translates to:
  /// **'앱 사용법'**
  String get settingsAppGuide;

  /// 공지사항 목록·상세 화면 제목이자 설정의 진입 항목
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get settingsNotices;

  /// 앱 버전 표시 항목 라벨
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get settingsVersion;

  /// 설정 화면 약관 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'약관'**
  String get settingsSectionLegal;

  /// 이용약관 화면으로 가는 항목
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get settingsTermsOfService;

  /// 개인정보 처리방침 화면으로 가는 항목
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get settingsPrivacyPolicy;

  /// 오픈소스 라이선스 목록을 여는 항목
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get settingsOpenSourceLicenses;

  /// 로그아웃 항목
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get settingsSignOut;

  /// 관리자 계정에만 보이는 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'관리자'**
  String get settingsSectionAdmin;

  /// 관리자용 공지 관리 화면으로 가는 항목
  ///
  /// In ko, this message translates to:
  /// **'공지사항 관리'**
  String get settingsManageNotices;

  /// 계정 관리 화면의 되돌릴 수 없는 작업 섹션 라벨
  ///
  /// In ko, this message translates to:
  /// **'위험 구역'**
  String get settingsDangerZone;

  /// 회원탈퇴 항목이자 확인 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'회원탈퇴'**
  String get settingsDeleteAccount;

  /// 회원탈퇴 항목 아래의 보조 설명
  ///
  /// In ko, this message translates to:
  /// **'탈퇴하면 계정과 저장된 모든 계산 기록이 삭제되며 되돌릴 수 없습니다.'**
  String get settingsDeleteAccountCaption;

  /// 회원탈퇴 확인 다이얼로그 본문
  ///
  /// In ko, this message translates to:
  /// **'탈퇴하면 계정과 저장된 모든 계산 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.'**
  String get settingsDeleteAccountConfirm;

  /// 회원탈퇴 확인 다이얼로그의 실행 버튼
  ///
  /// In ko, this message translates to:
  /// **'탈퇴하기'**
  String get settingsDeleteAccountAction;

  /// 회원탈퇴 실패 스낵바
  ///
  /// In ko, this message translates to:
  /// **'오류: {message}'**
  String settingsErrorWithMessage(String message);

  /// 공지사항 목록이 비었을 때
  ///
  /// In ko, this message translates to:
  /// **'등록된 공지사항이 없습니다'**
  String get settingsNoticesEmpty;

  /// 공지사항 목록·상세를 불러오지 못했을 때
  ///
  /// In ko, this message translates to:
  /// **'공지사항을 불러오지 못했습니다\n{error}'**
  String settingsNoticesLoadError(String error);

  /// 요청한 공지가 삭제되었거나 없을 때
  ///
  /// In ko, this message translates to:
  /// **'공지사항을 찾을 수 없습니다'**
  String get settingsNoticeNotFound;

  /// 월 고정비 계산 화면 앱바 제목
  ///
  /// In ko, this message translates to:
  /// **'월 고정비 계산'**
  String get monthlyExpenseTitle;

  /// 입력 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'월 고정 지출'**
  String get monthlyExpenseSectionTitle;

  /// 입력 섹션 도움말 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'월 고정비란?'**
  String get monthlyExpenseHelpTitle;

  /// 입력 섹션 도움말 본문. 항목별 설명
  ///
  /// In ko, this message translates to:
  /// **'매달 일정하게 나가는 생활 고정 지출 항목입니다.\n\n• 주거비: 월세 또는 전세 대출 월 이자\n• 관리비: 건물 관리·공용 시설 이용 비용\n• 통신비: 핸드폰·인터넷 요금\n• 교통비: 교통카드·주유비 등\n• 보험료: 생명보험·실손보험 등 월 납부 보험\n• 구독료: 넷플릭스·스포티파이 등 구독 서비스\n• 식비: 외식비·식재료비\n• 기타: 그 외 고정 지출\n\n0원인 항목은 결과에서 제외됩니다.'**
  String get monthlyExpenseHelpBody;

  /// 주거비 입력 필드 라벨. 결과 표의 '주거비'보다 설명이 길다
  ///
  /// In ko, this message translates to:
  /// **'주거비 (월세/이자)'**
  String get monthlyExpenseHousingFieldLabel;

  /// 지출 항목 이름 - 주거비
  ///
  /// In ko, this message translates to:
  /// **'주거비'**
  String get monthlyExpenseCategoryHousing;

  /// 지출 항목 이름 - 관리비
  ///
  /// In ko, this message translates to:
  /// **'관리비'**
  String get monthlyExpenseCategoryMaintenance;

  /// 지출 항목 이름 - 통신비
  ///
  /// In ko, this message translates to:
  /// **'통신비'**
  String get monthlyExpenseCategoryCommunication;

  /// 지출 항목 이름 - 교통비
  ///
  /// In ko, this message translates to:
  /// **'교통비'**
  String get monthlyExpenseCategoryTransportation;

  /// 지출 항목 이름 - 보험료
  ///
  /// In ko, this message translates to:
  /// **'보험료'**
  String get monthlyExpenseCategoryInsurance;

  /// 지출 항목 이름 - 구독료
  ///
  /// In ko, this message translates to:
  /// **'구독료'**
  String get monthlyExpenseCategorySubscription;

  /// 지출 항목 이름 - 식비
  ///
  /// In ko, this message translates to:
  /// **'식비'**
  String get monthlyExpenseCategoryFood;

  /// 지출 항목 이름 - 기타
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get monthlyExpenseCategoryOther;

  /// 계산 실행 버튼
  ///
  /// In ko, this message translates to:
  /// **'계산하기'**
  String get monthlyExpenseCalculate;

  /// 결과 카드 상단 라벨
  ///
  /// In ko, this message translates to:
  /// **'계산 결과'**
  String get monthlyExpenseResultTitle;

  /// 결과 카드 월 합계 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'월 합계'**
  String get monthlyExpenseMonthlyTotalLabel;

  /// 결과 카드 연간 합계 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'연간 합계'**
  String get monthlyExpenseAnnualTotalLabel;

  /// 이력 저장 완료 스낵바
  ///
  /// In ko, this message translates to:
  /// **'계산 결과가 저장되었습니다.'**
  String get monthlyExpenseSaved;

  /// 공유 시트 제목과 메일 제목
  ///
  /// In ko, this message translates to:
  /// **'월 고정비 계산 결과'**
  String get monthlyExpenseShareSubject;

  /// 공유 본문 첫 줄
  ///
  /// In ko, this message translates to:
  /// **'[{appName}] 월 고정비 계산 결과'**
  String monthlyExpenseShareHeader(String appName);

  /// 공유 본문의 항목별 줄
  ///
  /// In ko, this message translates to:
  /// **'{label}: {amount}'**
  String monthlyExpenseShareLine(String label, String amount);

  /// 공유 본문 월 합계 줄
  ///
  /// In ko, this message translates to:
  /// **'월 합계: {amount}'**
  String monthlyExpenseShareMonthlyTotal(String amount);

  /// 공유 본문 연간 합계 줄
  ///
  /// In ko, this message translates to:
  /// **'연간 합계: {amount}'**
  String monthlyExpenseShareAnnualTotal(String amount);

  /// 공유 본문 마지막 줄 면책 문구
  ///
  /// In ko, this message translates to:
  /// **'※ 본 계산 결과는 참고용입니다.'**
  String get monthlyExpenseShareDisclaimer;

  /// 대출이자 계산 화면 앱바 제목
  ///
  /// In ko, this message translates to:
  /// **'대출이자 계산'**
  String get loanInterestTitle;

  /// 입력 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'대출 조건'**
  String get loanInterestSectionTitle;

  /// 입력 섹션 도움말 다이얼로그 제목
  ///
  /// In ko, this message translates to:
  /// **'대출이자 계산이란?'**
  String get loanInterestHelpTitle;

  /// 입력 섹션 도움말 본문. 계산식과 한계 설명
  ///
  /// In ko, this message translates to:
  /// **'단리(이자만 납부) 방식으로 월 이자와 총 이자를 계산합니다.\n\n• 대출금: 은행에서 빌리는 원금\n• 연이율: 연간 적용 이자율 (예: 4.5%)\n• 대출 기간: 이자를 납부할 기간 (개월)\n\n월 이자 = 대출금 × 연이율 ÷ 12\n총 이자 = 월 이자 × 대출 기간\n\n원리금 균등 상환(원금도 함께 갚는 방식)과는\n계산 방법이 다릅니다.'**
  String get loanInterestHelpBody;

  /// 대출 원금 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'대출금'**
  String get loanInterestAmountLabel;

  /// 연이율 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'연이율'**
  String get loanInterestRateLabel;

  /// 대출 기간 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'대출 기간'**
  String get loanInterestMonthsLabel;

  /// 대출 기간 입력 힌트
  ///
  /// In ko, this message translates to:
  /// **'예: 24'**
  String get loanInterestMonthsHint;

  /// 대출 기간 입력 필드 접미사 단위
  ///
  /// In ko, this message translates to:
  /// **'개월'**
  String get loanInterestMonthsSuffix;

  /// PDF 입력값 요약의 대출 기간 값
  ///
  /// In ko, this message translates to:
  /// **'{months}개월'**
  String loanInterestMonthsValue(int months);

  /// 계산 실행 버튼
  ///
  /// In ko, this message translates to:
  /// **'계산하기'**
  String get loanInterestCalculate;

  /// 결과 카드 상단 라벨
  ///
  /// In ko, this message translates to:
  /// **'계산 결과'**
  String get loanInterestResultTitle;

  /// 결과 카드 월 이자 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'월 이자'**
  String get loanInterestMonthlyInterestLabel;

  /// 결과 카드 총 이자 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'{months}개월 총 이자'**
  String loanInterestTotalInterestLabel(int months);

  /// 이력 저장 완료 스낵바
  ///
  /// In ko, this message translates to:
  /// **'계산 결과가 저장되었습니다.'**
  String get loanInterestSaved;

  /// 공유 시트 제목과 메일 제목
  ///
  /// In ko, this message translates to:
  /// **'대출이자 계산 결과'**
  String get loanInterestShareSubject;

  /// 공유 본문 첫 줄
  ///
  /// In ko, this message translates to:
  /// **'[{appName}] 대출이자 계산 결과'**
  String loanInterestShareHeader(String appName);

  /// 공유 본문 대출금 줄
  ///
  /// In ko, this message translates to:
  /// **'대출금: {amount}'**
  String loanInterestShareLoanAmount(String amount);

  /// 공유 본문 월 이자 줄
  ///
  /// In ko, this message translates to:
  /// **'월 이자: {amount}'**
  String loanInterestShareMonthlyInterest(String amount);

  /// 공유 본문 총 이자 줄
  ///
  /// In ko, this message translates to:
  /// **'{months}개월 총 이자: {amount}'**
  String loanInterestShareTotalInterest(int months, String amount);

  /// 공유 본문 마지막 줄 면책 문구
  ///
  /// In ko, this message translates to:
  /// **'※ 본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.'**
  String get loanInterestShareDisclaimer;

  /// 연말정산 세액공제 화면 앱바 제목
  ///
  /// In ko, this message translates to:
  /// **'연말정산 세액공제'**
  String get taxDeductionTitle;

  /// PDF 내보내기 문서 제목
  ///
  /// In ko, this message translates to:
  /// **'연말정산 세액공제 결과'**
  String get taxDeductionPdfTitle;

  /// PDF 결과 표의 월세 공제율 항목. 표가 평면이라 '월세'를 붙여 구분한다
  ///
  /// In ko, this message translates to:
  /// **'월세 공제율'**
  String get taxDeductionPdfRentRate;

  /// PDF 결과 표의 월세 세액공제액 항목
  ///
  /// In ko, this message translates to:
  /// **'월세 세액공제'**
  String get taxDeductionPdfRentTaxCredit;

  /// PDF 결과 표의 전세대출 절세액 항목
  ///
  /// In ko, this message translates to:
  /// **'전세대출 절세액'**
  String get taxDeductionPdfLoanTaxSaving;

  /// 소득 입력 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'소득 정보'**
  String get taxDeductionIncomeSection;

  /// 연간 총급여 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'연간 총급여'**
  String get taxDeductionAnnualSalaryLabel;

  /// 소득세율 슬라이더 라벨
  ///
  /// In ko, this message translates to:
  /// **'소득세율 (과세표준 기준)'**
  String get taxDeductionIncomeTaxRateLabel;

  /// 월세 세액공제 입력·결과 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'월세 세액공제'**
  String get taxDeductionRentSection;

  /// 총급여 구간별 월세 세액공제율 안내
  ///
  /// In ko, this message translates to:
  /// **'총급여 5,500만원 이하 17% / 7,000만원 이하 15% / 초과 0%'**
  String get taxDeductionRentRateGuide;

  /// 월세 입력 필드 라벨. 월 단위 금액
  ///
  /// In ko, this message translates to:
  /// **'월세 (월)'**
  String get taxDeductionMonthlyRentLabel;

  /// 전세대출 원리금 소득공제 입력 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'전세대출 원리금 소득공제'**
  String get taxDeductionLoanSection;

  /// 전세대출 원리금 소득공제 요율과 한도 안내
  ///
  /// In ko, this message translates to:
  /// **'연 상환액의 40% 소득공제, 연 400만원 한도'**
  String get taxDeductionLoanGuide;

  /// 연간 원리금 상환액 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'연간 원리금 상환액'**
  String get taxDeductionAnnualRepaymentLabel;

  /// 계산 실행 버튼
  ///
  /// In ko, this message translates to:
  /// **'계산하기'**
  String get taxDeductionCalculate;

  /// 결과 카드 월세 공제율 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'공제율'**
  String get taxDeductionRentRateRowLabel;

  /// 결과 카드 공제 대상 연 월세 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'공제 대상 연 월세'**
  String get taxDeductionEligibleAnnualRentLabel;

  /// 결과 카드 월세 세액공제액 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'세액공제액'**
  String get taxDeductionRentTaxCreditLabel;

  /// 결과 카드 전세대출 소득공제 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'전세대출 소득공제'**
  String get taxDeductionLoanResultSection;

  /// 결과 카드 공제 대상 상환액 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'공제 대상 상환액'**
  String get taxDeductionEligibleRepaymentLabel;

  /// 결과 카드 소득공제액 행 라벨. 상환액의 40%
  ///
  /// In ko, this message translates to:
  /// **'소득공제액 (40%)'**
  String get taxDeductionIncomeDeductionLabel;

  /// 결과 카드 전세대출 절세액 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'절세액 (세율 {rate}%)'**
  String taxDeductionLoanTaxSavingLabel(String rate);

  /// 결과 카드 연간 총 절세 혜택 행 라벨
  ///
  /// In ko, this message translates to:
  /// **'연간 총 절세 혜택'**
  String get taxDeductionTotalBenefitLabel;

  /// 총급여가 월세 세액공제 한도를 넘고 다른 공제도 없을 때의 결과 문구
  ///
  /// In ko, this message translates to:
  /// **'총급여 7천만원 초과로 월세 세액공제 대상이 아닙니다.'**
  String get taxDeductionMessageIncomeTooHigh;

  /// 월세 세액공제는 못 받지만 전세대출 소득공제 절세액이 있을 때의 결과 문구
  ///
  /// In ko, this message translates to:
  /// **'총급여 7천만원 초과로 월세 세액공제는 받을 수 없지만, 전세대출 소득공제로 연간 최대 {amount} 아낄 수 있어요.'**
  String taxDeductionMessageIncomeTooHighWithLoan(String amount);

  /// 절세 혜택이 있을 때의 결과 문구
  ///
  /// In ko, this message translates to:
  /// **'연간 최대 {amount} 세금을 아낄 수 있어요!'**
  String taxDeductionMessageHasBenefit(String amount);

  /// 공제 대상 입력이 없어 혜택이 0일 때의 결과 문구
  ///
  /// In ko, this message translates to:
  /// **'해당하는 공제 항목을 입력해 주세요.'**
  String get taxDeductionMessageNoInput;

  /// 하단 내비게이션 홈 탭
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get sharedHomeTab;

  /// 하단 내비게이션 주거 탭과 주거 계산 카테고리 제목
  ///
  /// In ko, this message translates to:
  /// **'주거'**
  String get sharedHousingTab;

  /// 주거 계산 카테고리 헤드라인
  ///
  /// In ko, this message translates to:
  /// **'계약과 임대료를\n비교하세요'**
  String get sharedHousingHeadline;

  /// 주거 계산 카테고리 설명
  ///
  /// In ko, this message translates to:
  /// **'전세, 월세, 반전세, 계약 갱신처럼 집 계약에 직접 연결되는 계산입니다.'**
  String get sharedHousingDescription;

  /// 하단 내비게이션 금융 탭과 금융 계산 카테고리 제목
  ///
  /// In ko, this message translates to:
  /// **'금융'**
  String get sharedFinanceTab;

  /// 금융 계산 카테고리 헤드라인
  ///
  /// In ko, this message translates to:
  /// **'대출과 세금을\n따져보세요'**
  String get sharedFinanceHeadline;

  /// 금융 계산 카테고리 설명
  ///
  /// In ko, this message translates to:
  /// **'대출 부담, 월 고정비, 세액공제, 거래 비용을 한곳에 모았습니다.'**
  String get sharedFinanceDescription;

  /// 하단 내비게이션 최근 계산 탭
  ///
  /// In ko, this message translates to:
  /// **'최근계산'**
  String get sharedRecentTab;

  /// 하단 내비게이션 설정 탭
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get sharedSettingsTab;

  /// 금액 입력 보조 버튼 초기화
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get sharedResetAmount;

  /// 퍼센트 입력 필드 예시 힌트
  ///
  /// In ko, this message translates to:
  /// **'예: 3.5'**
  String get sharedPercentHint;

  /// 결과 액션 공유 버튼
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get sharedShareAction;

  /// 결과 액션 PDF 내보내기 버튼
  ///
  /// In ko, this message translates to:
  /// **'PDF 내보내기'**
  String get sharedExportPdfAction;

  /// 설정과 공용 면책 박스에 표시하는 긴 면책 문구
  ///
  /// In ko, this message translates to:
  /// **'본 앱은 전세, 월세, 대출 이자, 월 고정비 등을 단순 계산하기 위한 참고용 도구입니다.\n실제 대출 가능 여부, 금리, 세금, 보증금 반환 가능성, 계약 위험도는 금융기관, 세무사, 공인중개사 등 전문가에게 반드시 확인하시기 바랍니다.\n본 앱의 계산 결과는 법적·금융적 판단의 근거로 사용할 수 없습니다.'**
  String get sharedDisclaimerMain;

  /// 계산 결과 하단에 표시하는 짧은 면책 문구
  ///
  /// In ko, this message translates to:
  /// **'본 계산 결과는 참고용입니다. 실제 계약 전 전문가에게 확인하세요.'**
  String get sharedDisclaimerShort;

  /// 결과 화면 광고 배너 라벨
  ///
  /// In ko, this message translates to:
  /// **'광고'**
  String get sharedAdLabel;

  /// 네트워크가 끊겼을 때 표시하는 배너 문구
  ///
  /// In ko, this message translates to:
  /// **'오프라인 상태입니다'**
  String get sharedOfflineBanner;

  /// 공지사항 푸시 알림 Android 채널명
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get notificationNoticeChannelName;

  /// 공지사항 푸시 알림 Android 채널 설명
  ///
  /// In ko, this message translates to:
  /// **'새 공지사항 알림'**
  String get notificationNoticeChannelDescription;

  /// 원격 푸시에 제목이 없을 때 쓰는 기본 제목
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get notificationNoticeFallbackTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
