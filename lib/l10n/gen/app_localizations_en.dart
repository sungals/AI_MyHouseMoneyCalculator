import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Housing Cost Calculator';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonError => 'Something went wrong. Please try again in a moment.';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get settingsLanguageKorean => '한국어';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get guideTitle => 'About this app';

  @override
  String get guideIntroTagline => 'A housing cost calculator that takes you from the numbers to saving and sharing in one flow.';

  @override
  String get guideFlowStep1Title => '1. Pick a calculator';

  @override
  String get guideFlowStep1Body => 'Choose the housing cost calculator you need from the home screen.';

  @override
  String get guideFlowStep2Title => '2. Enter amounts and terms';

  @override
  String get guideFlowStep2Body => 'Amounts you type are also shown in Korean units, for example 3억2천만원 (KRW 320M).';

  @override
  String get guideFlowStep3Title => '3. Save and share the result';

  @override
  String get guideFlowStep3Body => 'Save a result, then export it as PDF or CSV from the Recent tab.';

  @override
  String get guideCategoryLeaseTitle => 'Lease calculators';

  @override
  String get guideCategoryLeaseSubtitle => 'Compare jeonse against monthly rent, and check whether a semi-jeonse offer is fair.';

  @override
  String get guideCategoryFinanceTitle => 'Loans and finance';

  @override
  String get guideCategoryFinanceSubtitle => 'Work out loan interest, how much you can borrow, and your monthly outgoings.';

  @override
  String get guideCategoryTaxTitle => 'Taxes and fees';

  @override
  String get guideCategoryTaxSubtitle => 'Rough estimates for the taxes and fees that come with housing.';

  @override
  String get guideJeonseRentTitle => 'Jeonse vs monthly rent';

  @override
  String get guideJeonseRentSummary => 'Compares jeonse loan interest against monthly rent over the same period.';

  @override
  String get guideJeonseRentStep1 => 'Enter the jeonse deposit, loan amount, and rate';

  @override
  String get guideJeonseRentStep2 => 'Enter the rental deposit and monthly rent';

  @override
  String get guideJeonseRentStep3 => 'See the monthly and total cost difference';

  @override
  String get guideSemiRentTitle => 'Semi-jeonse';

  @override
  String get guideSemiRentSummary => 'Checks whether the rent is fair when part of the deposit is converted to monthly payments.';

  @override
  String get guideSemiRentStep1 => 'Enter the old and the new deposit';

  @override
  String get guideSemiRentStep2 => 'Enter the rent and the conversion rate';

  @override
  String get guideSemiRentStep3 => 'See whether the rent is too high or a good deal';

  @override
  String get guideLoanInterestTitle => 'Loan interest';

  @override
  String get guideLoanInterestSummary => 'Calculates monthly and total interest from the loan amount, rate, and term.';

  @override
  String get guideLoanInterestStep1 => 'Enter the loan amount';

  @override
  String get guideLoanInterestStep2 => 'Enter the annual rate and the number of months';

  @override
  String get guideLoanInterestStep3 => 'See monthly interest and total interest over the term';

  @override
  String get guideDsrDtiTitle => 'DSR and DTI';

  @override
  String get guideDsrDtiSummary => 'Shows your loan repayment burden as a share of your annual income.';

  @override
  String get guideDsrDtiStep1 => 'Enter your annual income';

  @override
  String get guideDsrDtiStep2 => 'Enter your mortgage and any other loans';

  @override
  String get guideDsrDtiStep3 => 'See your DSR and DTI ratios';

  @override
  String get guideMonthlyExpenseTitle => 'Monthly fixed costs';

  @override
  String get guideMonthlyExpenseSummary => 'Adds up housing and living costs so you can see your monthly outgoings.';

  @override
  String get guideMonthlyExpenseStep1 => 'Enter rent, maintenance fees, phone bills, and so on';

  @override
  String get guideMonthlyExpenseStep2 => 'See the monthly and yearly totals';

  @override
  String get guideMonthlyExpenseStep3 => 'Save it and compare recurring costs over time';

  @override
  String get guideTaxDeductionTitle => 'Year-end tax credit';

  @override
  String get guideTaxDeductionSummary => 'Rough estimate of what you can claim for rent and jeonse loan payments.';

  @override
  String get guideTaxDeductionStep1 => 'Choose your income level and housing type';

  @override
  String get guideTaxDeductionStep2 => 'Enter your rent or jeonse loan details';

  @override
  String get guideTaxDeductionStep3 => 'See the estimated deduction';

  @override
  String get guideBrokerageFeeTitle => 'Agent commission';

  @override
  String get guideBrokerageFeeSummary => 'Quickly check the legal maximum agent commission for a sale or a lease.';

  @override
  String get guideBrokerageFeeStep1 => 'Choose the transaction type';

  @override
  String get guideBrokerageFeeStep2 => 'Enter the transaction amount';

  @override
  String get guideBrokerageFeeStep3 => 'See the maximum rate and the expected fee';

  @override
  String get guideAcquisitionTaxTitle => 'Acquisition tax';

  @override
  String get guideAcquisitionTaxSummary => 'Rough estimate based on the purchase price, homes owned, and regional rules.';

  @override
  String get guideAcquisitionTaxStep1 => 'Enter the purchase price';

  @override
  String get guideAcquisitionTaxStep2 => 'Choose how many homes you own and whether the area is regulated';

  @override
  String get guideAcquisitionTaxStep3 => 'See the rate and the estimated tax';

  @override
  String get guidePreviewJeonseMonthlyLabel => 'Jeonse per month';

  @override
  String get guidePreviewJeonseItem1 => 'Loan interest';

  @override
  String get guidePreviewJeonseItem2 => '+ opportunity cost of your own cash';

  @override
  String get guidePreviewJeonseAmount => 'KRW 1.16M/mo';

  @override
  String get guidePreviewRentMonthlyLabel => 'Monthly rent per month';

  @override
  String get guidePreviewRentItem1 => 'Rent + maintenance fee';

  @override
  String get guidePreviewRentItem2 => '+ opportunity cost of the deposit';

  @override
  String get guidePreviewRentAmount => 'KRW 1.45M/mo';

  @override
  String get guidePreviewOpportunityCostFormula => 'opportunity cost = deposit × market rate ÷ 12';

  @override
  String get guidePreviewSemiRentFormula => 'fair rent = (jeonse price − deposit) × conversion rate ÷ 12';

  @override
  String get guidePreviewConversionCapLabel => 'Legal cap on the conversion rate';

  @override
  String get guidePreviewConversionCapValue => 'base rate + 2%p';

  @override
  String get guidePreviewConversionExampleLabel => 'Example current rate';

  @override
  String get guidePreviewConversionExampleValue => 'about 4.5%';

  @override
  String get guidePreviewLoanFormula => 'monthly interest = loan × annual rate ÷ 12\ntotal interest = monthly interest × months';

  @override
  String get guidePreviewLoanExample => 'Example: KRW 320M × 4.0% ÷ 12';

  @override
  String get guidePreviewLoanInterestType => 'simple interest, interest only';

  @override
  String get guidePreviewLoanMonthlyLabel => 'Monthly interest';

  @override
  String get guidePreviewLoanMonthlyValue => 'KRW 1,066,667';

  @override
  String get guidePreviewExpenseHousing => 'Housing';

  @override
  String get guidePreviewExpenseMaintenance => 'Maintenance';

  @override
  String get guidePreviewExpenseCommunication => 'Phone';

  @override
  String get guidePreviewExpenseTransport => 'Transport';

  @override
  String get guidePreviewExpenseInsurance => 'Insurance';

  @override
  String get guidePreviewExpenseSubscription => 'Subscriptions';

  @override
  String get guidePreviewMonthlyToYearly => 'Monthly total → yearly total';

  @override
  String get guidePreviewTimesTwelve => '× 12 months, calculated for you';

  @override
  String get guidePreviewRentTaxCreditHeader => 'Rent tax credit';

  @override
  String get guidePreviewSalaryUnder55 => 'Gross salary up to KRW 55M';

  @override
  String get guidePreviewSalary55To80 => 'KRW 55M to 80M';

  @override
  String get guidePreviewSalaryOver80 => 'Over KRW 80M';

  @override
  String get guidePreviewNotDeductible => 'Not eligible';

  @override
  String get guidePreviewJeonseLoanDeductionHeader => 'Jeonse loan income deduction';

  @override
  String get guidePreviewPrincipalAndInterest => 'principal + interest paid × 40%';

  @override
  String get guidePreviewDeductionLimit => 'capped at KRW 3M';

  @override
  String get guidePreviewDsrDtiFormula => 'DSR = yearly payments on all loans ÷ annual income × 100%\nDTI = (mortgage payments + other interest) ÷ annual income × 100%';

  @override
  String get guidePreviewBandSafe => 'Safe';

  @override
  String get guidePreviewBandCaution => 'Caution';

  @override
  String get guidePreviewBandRisk => 'Risky';

  @override
  String get guidePreviewDealTypeAmount => 'Transaction type / amount';

  @override
  String get guidePreviewMaxRate => 'Maximum rate';

  @override
  String get guidePreviewSaleUnder500M => 'Sale · under KRW 500M';

  @override
  String get guidePreviewSaleOver500M => 'Sale · KRW 500M and over';

  @override
  String get guidePreviewLeaseUnder100M => 'Lease · under KRW 100M';

  @override
  String get guidePreviewLeaseOver100M => 'Lease · KRW 100M and over';

  @override
  String get guidePreviewVatSeparate => '10% VAT on top';

  @override
  String get guidePreviewHomesAndCondition => 'Homes owned / conditions';

  @override
  String get guidePreviewTaxRate => 'Rate';

  @override
  String get guidePreviewOneHomeUnder600M => '1 home · up to KRW 600M';

  @override
  String get guidePreviewOneHome600To900M => '1 home · KRW 600M to 900M';

  @override
  String get guidePreviewOneHomeOver900M => '1 home · over KRW 900M';

  @override
  String get guidePreviewTwoHomesRegulated => '2 homes (regulated area)';

  @override
  String get guidePreviewThreeOrMoreHomes => '3 or more homes';

  @override
  String get guidePreviewRateBand1To3 => '1–3% band';

  @override
  String get guidePreviewSurtaxNote => 'more with rural and education surtax';

  @override
  String get guideSavedTitle => 'Using saved calculations';

  @override
  String get guideSaveResultTitle => 'Save a result';

  @override
  String get guideSaveResultBody => 'Save from the result screen and it appears in the Recent tab.';

  @override
  String get guideFavoriteMemoTitle => 'Favorites and notes';

  @override
  String get guideFavoriteMemoBody => 'Star the calculations you check often, and add notes on the detail screen.';

  @override
  String get guideExportShareTitle => 'Share as PDF or CSV';

  @override
  String get guideExportShareBody => 'Export or share as PDF or CSV from the detail screen.';

  @override
  String get guideAccountSyncTitle => 'Account, sync, and notices';

  @override
  String get guideSyncHeader => 'Sign in and your records sync';

  @override
  String get guideSyncBody => 'Offline, everything is saved on your phone first and synced with the server once you are back online.';

  @override
  String get guideSyncNodeApp => 'App';

  @override
  String get guideSyncNodeServer => 'Server';

  @override
  String get guidePinBiometricHeader => 'Lock the app with a PIN or biometrics';

  @override
  String get guideNoticePushHeader => 'Notices and push alerts';

  @override
  String get guideNoticePushBody => 'You can read notices in Settings. Sign in and turn on push alerts to be notified when a new one is posted.';

  @override
  String get guideDisclaimer => 'The results in this app are rough estimates based on what you enter. Real loan, tax, agent commission, and contract terms vary by area, timing, your own situation, and the law that applies, so check with a professional or an official body before you decide anything.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'Account';

  @override
  String get settingsSignedIn => 'Signed in';

  @override
  String get settingsAccountManage => 'Manage account';

  @override
  String get settingsSignIn => 'Sign in';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsQuickLoginEnabled => 'Quick login is on';

  @override
  String get settingsQuickLoginSetup => 'Set up quick login';

  @override
  String get settingsQuickLoginDisable => 'Turn off';

  @override
  String get settingsPinChange => 'Change PIN';

  @override
  String get settingsBiometricReset => 'Set up biometrics again';

  @override
  String get settingsRequireAuthOnLaunch => 'Ask to unlock when reopening the app';

  @override
  String get settingsSectionNotification => 'Notifications';

  @override
  String get settingsNoticePush => 'Notice alerts';

  @override
  String get settingsSectionThemeLanguage => 'Theme and language';

  @override
  String get settingsSectionAppInfo => 'App info';

  @override
  String get settingsAppGuide => 'How to use the app';

  @override
  String get settingsNotices => 'Notices';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsTermsOfService => 'Terms of service';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsOpenSourceLicenses => 'Open source licenses';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSectionAdmin => 'Admin';

  @override
  String get settingsManageNotices => 'Manage notices';

  @override
  String get settingsDangerZone => 'Danger zone';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountCaption => 'Deleting your account also deletes every saved calculation. This cannot be undone.';

  @override
  String get settingsDeleteAccountConfirm => 'Deleting your account also deletes every saved calculation.\nThis cannot be undone.';

  @override
  String get settingsDeleteAccountAction => 'Delete account';

  @override
  String settingsErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get settingsNoticesEmpty => 'No notices yet';

  @override
  String settingsNoticesLoadError(String error) {
    return 'Could not load notices\n$error';
  }

  @override
  String get settingsNoticeNotFound => 'This notice was not found';

  @override
  String get monthlyExpenseTitle => 'Monthly fixed costs';

  @override
  String get monthlyExpenseSectionTitle => 'Monthly fixed spending';

  @override
  String get monthlyExpenseHelpTitle => 'What counts as a fixed cost?';

  @override
  String get monthlyExpenseHelpBody => 'Costs you pay every month at a steady amount.\n\n• Housing: monthly rent, or the monthly interest on a jeonse (large-deposit lease) loan\n• Maintenance: building management and shared facility fees\n• Phone and internet: mobile and broadband bills\n• Transport: transit card top-ups, fuel, and similar\n• Insurance: life, health, and other monthly premiums\n• Subscriptions: streaming and other recurring services\n• Food: eating out and groceries\n• Other: any other fixed cost\n\nItems left at 0 are excluded from the result.';

  @override
  String get monthlyExpenseHousingFieldLabel => 'Housing (rent or loan interest)';

  @override
  String get monthlyExpenseCategoryHousing => 'Housing';

  @override
  String get monthlyExpenseCategoryMaintenance => 'Maintenance';

  @override
  String get monthlyExpenseCategoryCommunication => 'Phone and internet';

  @override
  String get monthlyExpenseCategoryTransportation => 'Transport';

  @override
  String get monthlyExpenseCategoryInsurance => 'Insurance';

  @override
  String get monthlyExpenseCategorySubscription => 'Subscriptions';

  @override
  String get monthlyExpenseCategoryFood => 'Food';

  @override
  String get monthlyExpenseCategoryOther => 'Other';

  @override
  String get monthlyExpenseCalculate => 'Calculate';

  @override
  String get monthlyExpenseResultTitle => 'Result';

  @override
  String get monthlyExpenseMonthlyTotalLabel => 'Monthly total';

  @override
  String get monthlyExpenseAnnualTotalLabel => 'Yearly total';

  @override
  String get monthlyExpenseSaved => 'Result saved.';

  @override
  String get monthlyExpenseShareSubject => 'Monthly fixed cost result';

  @override
  String monthlyExpenseShareHeader(String appName) {
    return '[$appName] Monthly fixed cost result';
  }

  @override
  String monthlyExpenseShareLine(String label, String amount) {
    return '$label: $amount';
  }

  @override
  String monthlyExpenseShareMonthlyTotal(String amount) {
    return 'Monthly total: $amount';
  }

  @override
  String monthlyExpenseShareAnnualTotal(String amount) {
    return 'Yearly total: $amount';
  }

  @override
  String get monthlyExpenseShareDisclaimer => '* This result is for reference only.';

  @override
  String get loanInterestTitle => 'Loan interest';

  @override
  String get loanInterestSectionTitle => 'Loan terms';

  @override
  String get loanInterestHelpTitle => 'How is loan interest calculated?';

  @override
  String get loanInterestHelpBody => 'Works out monthly and total interest for an interest-only loan (simple interest).\n\n• Loan amount: the principal you borrow\n• Annual rate: the yearly interest rate (for example 4.5%)\n• Loan term: how many months you pay interest\n\nMonthly interest = loan amount × annual rate ÷ 12\nTotal interest = monthly interest × loan term\n\nThis is different from an equal principal-and-interest loan,\nwhere you repay principal every month too.';

  @override
  String get loanInterestAmountLabel => 'Loan amount';

  @override
  String get loanInterestRateLabel => 'Annual rate';

  @override
  String get loanInterestMonthsLabel => 'Loan term';

  @override
  String get loanInterestMonthsHint => 'e.g. 24';

  @override
  String get loanInterestMonthsSuffix => 'months';

  @override
  String loanInterestMonthsValue(int months) {
    return '$months months';
  }

  @override
  String get loanInterestCalculate => 'Calculate';

  @override
  String get loanInterestResultTitle => 'Result';

  @override
  String get loanInterestMonthlyInterestLabel => 'Monthly interest';

  @override
  String loanInterestTotalInterestLabel(int months) {
    return 'Total interest over $months months';
  }

  @override
  String get loanInterestSaved => 'Result saved.';

  @override
  String get loanInterestShareSubject => 'Loan interest result';

  @override
  String loanInterestShareHeader(String appName) {
    return '[$appName] Loan interest result';
  }

  @override
  String loanInterestShareLoanAmount(String amount) {
    return 'Loan amount: $amount';
  }

  @override
  String loanInterestShareMonthlyInterest(String amount) {
    return 'Monthly interest: $amount';
  }

  @override
  String loanInterestShareTotalInterest(int months, String amount) {
    return 'Total interest over $months months: $amount';
  }

  @override
  String get loanInterestShareDisclaimer => '* This result is for reference only. Check with a professional before you sign.';

  @override
  String get taxDeductionTitle => 'Year-end tax settlement';

  @override
  String get taxDeductionPdfTitle => 'Year-end tax settlement result';

  @override
  String get taxDeductionPdfRentRate => 'Rent credit rate';

  @override
  String get taxDeductionPdfRentTaxCredit => 'Rent tax credit';

  @override
  String get taxDeductionPdfLoanTaxSaving => 'Tax saved on jeonse loan';

  @override
  String get taxDeductionIncomeSection => 'Income';

  @override
  String get taxDeductionAnnualSalaryLabel => 'Gross annual salary';

  @override
  String get taxDeductionIncomeTaxRateLabel => 'Income tax rate (on your tax base)';

  @override
  String get taxDeductionRentSection => 'Monthly rent tax credit';

  @override
  String get taxDeductionRentRateGuide => '17% up to 55,000,000 KRW gross salary / 15% up to 70,000,000 KRW / 0% above that';

  @override
  String get taxDeductionMonthlyRentLabel => 'Monthly rent';

  @override
  String get taxDeductionLoanSection => 'Jeonse loan repayment income deduction';

  @override
  String get taxDeductionLoanGuide => '40% of your yearly repayment, capped at 4,000,000 KRW a year';

  @override
  String get taxDeductionAnnualRepaymentLabel => 'Yearly loan repayment';

  @override
  String get taxDeductionCalculate => 'Calculate';

  @override
  String get taxDeductionRentRateRowLabel => 'Credit rate';

  @override
  String get taxDeductionEligibleAnnualRentLabel => 'Rent that qualifies (per year)';

  @override
  String get taxDeductionRentTaxCreditLabel => 'Tax credit';

  @override
  String get taxDeductionLoanResultSection => 'Jeonse loan income deduction';

  @override
  String get taxDeductionEligibleRepaymentLabel => 'Repayment that qualifies';

  @override
  String get taxDeductionIncomeDeductionLabel => 'Income deduction (40%)';

  @override
  String taxDeductionLoanTaxSavingLabel(String rate) {
    return 'Tax saved (at $rate%)';
  }

  @override
  String get taxDeductionTotalBenefitLabel => 'Total tax saved per year';

  @override
  String get taxDeductionMessageIncomeTooHigh => 'Your gross salary is over 70,000,000 KRW, so the monthly rent tax credit does not apply.';

  @override
  String taxDeductionMessageIncomeTooHighWithLoan(String amount) {
    return 'Your gross salary is over 70,000,000 KRW, so the monthly rent tax credit does not apply. You can still save up to $amount a year through the jeonse loan income deduction.';
  }

  @override
  String taxDeductionMessageHasBenefit(String amount) {
    return 'You could save up to $amount in tax this year.';
  }

  @override
  String get taxDeductionMessageNoInput => 'Enter an amount for a deduction you qualify for.';

  @override
  String get sharedHomeTab => 'Home';

  @override
  String get sharedHousingTab => 'Housing';

  @override
  String get sharedHousingHeadline => 'Compare contracts\nand rent';

  @override
  String get sharedHousingDescription => 'Calculators for jeonse, wolse, semi-rent, and lease renewal decisions.';

  @override
  String get sharedFinanceTab => 'Finance';

  @override
  String get sharedFinanceHeadline => 'Check loans\nand taxes';

  @override
  String get sharedFinanceDescription => 'Loan burden, monthly fixed costs, tax credits, and transaction costs in one place.';

  @override
  String get sharedRecentTab => 'Recent';

  @override
  String get sharedSettingsTab => 'Settings';

  @override
  String get sharedResetAmount => 'Reset';

  @override
  String get sharedPercentHint => 'e.g. 3.5';

  @override
  String get sharedShareAction => 'Share';

  @override
  String get sharedExportPdfAction => 'Export PDF';

  @override
  String get sharedDisclaimerMain => 'This app is a reference calculator for housing contracts, rent, loans, taxes, and fixed monthly costs.\nConfirm actual loan eligibility, interest rates, taxes, deposit return risk, and contract risk with qualified professionals.\nDo not use these results as the sole basis for legal or financial decisions.';

  @override
  String get sharedDisclaimerShort => 'These results are for reference only. Confirm details before signing.';

  @override
  String get sharedAdLabel => 'Ad';

  @override
  String get sharedOfflineBanner => 'You are offline';

  @override
  String get notificationNoticeChannelName => 'Notices';

  @override
  String get notificationNoticeChannelDescription => 'New notice alerts';

  @override
  String get notificationNoticeFallbackTitle => 'Notice';
}
