abstract class AnalyticsService {
  Future<void> initialize();
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
}

class NoOpAnalyticsService implements AnalyticsService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> logEvent(String name,
      {Map<String, dynamic>? parameters}) async {}
}

class AnalyticsEvents {
  AnalyticsEvents._();

  static const String openHome = 'open_home';
  static const String openRentCompare = 'open_rent_compare';
  static const String calculateRentCompare = 'calculate_rent_compare';
  static const String openSemiRent = 'open_semi_rent';
  static const String calculateSemiRent = 'calculate_semi_rent';
  static const String openLoanInterest = 'open_loan_interest';
  static const String calculateLoanInterest = 'calculate_loan_interest';
  static const String openMonthlyExpense = 'open_monthly_expense';
  static const String calculateMonthlyExpense = 'calculate_monthly_expense';
  static const String saveCalculation = 'save_calculation';
  static const String shareCalculation = 'share_calculation';
  static const String openHistory = 'open_history';
  static const String purchaseRemoveAds = 'purchase_remove_ads';
}
