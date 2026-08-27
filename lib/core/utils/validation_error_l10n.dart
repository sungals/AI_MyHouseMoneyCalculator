import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';
import '../../l10n/gen/app_localizations.dart';
import 'validation_error.dart';

extension ValidationErrorL10n on ValidationError {
  /// 표현 계층에서 지역화 문장으로 변환한다.
  String localize(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case ValidationError.amountRequired:
        return l10n.validationAmountRequired;
      case ValidationError.amountInvalid:
        return l10n.validationAmountInvalid;
      case ValidationError.rateRequired:
        return l10n.validationRateRequired;
      case ValidationError.rateOutOfRange:
        return l10n.validationRateOutOfRange(
          AppConstants.maxInterestRate.toString(),
        );
      case ValidationError.monthsRequired:
        return l10n.validationMonthsRequired;
      case ValidationError.monthsOutOfRange:
        return l10n.validationMonthsOutOfRange(
          AppConstants.minMonths.toString(),
          AppConstants.maxMonths.toString(),
        );
      case ValidationError.loanExceedsDeposit:
        return l10n.validationLoanExceedsDeposit;
    }
  }
}
