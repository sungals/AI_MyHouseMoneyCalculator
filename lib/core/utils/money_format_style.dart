import 'package:flutter/widgets.dart';

/// 금액 표기 방식.
/// 한국식 만 단위 체계는 영어로 직역되지 않으므로 로케일에 따라 분기한다.
enum MoneyFormatStyle { korean, western }

MoneyFormatStyle moneyStyleFor(Locale? locale) {
  return locale?.languageCode == 'en'
      ? MoneyFormatStyle.western
      : MoneyFormatStyle.korean;
}
