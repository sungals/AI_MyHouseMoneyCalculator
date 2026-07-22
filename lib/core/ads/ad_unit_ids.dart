import 'dart:io';

import 'package:flutter/foundation.dart';

class AdUnitIds {
  AdUnitIds._();

  static const _androidApplicationId =
      String.fromEnvironment('ADMOB_ANDROID_APP_ID');
  static const _iosApplicationId = String.fromEnvironment('ADMOB_IOS_APP_ID');
  static const _androidResultBanner =
      String.fromEnvironment('ADMOB_ANDROID_RESULT_BANNER_ID');
  static const _iosResultBanner =
      String.fromEnvironment('ADMOB_IOS_RESULT_BANNER_ID');

  static bool get hasApplicationId {
    if (Platform.isIOS) return _iosApplicationId.isNotEmpty || !kReleaseMode;
    if (Platform.isAndroid) {
      return _androidApplicationId.isNotEmpty || !kReleaseMode;
    }
    return false;
  }

  // Google official test banner IDs are used only for debug/profile builds.
  static String get resultBanner {
    if (Platform.isIOS) {
      return _iosResultBanner.isNotEmpty
          ? _iosResultBanner
          : _debugTestIosResultBanner;
    }
    return _androidResultBanner.isNotEmpty
        ? _androidResultBanner
        : _debugTestAndroidResultBanner;
  }

  static bool get hasResultBannerId {
    if (Platform.isIOS) return resultBanner.isNotEmpty;
    if (Platform.isAndroid) return resultBanner.isNotEmpty;
    return false;
  }

  static String get _debugTestAndroidResultBanner =>
      kReleaseMode ? '' : 'ca-app-pub-3940256099942544/6300978111';

  static String get _debugTestIosResultBanner =>
      kReleaseMode ? '' : 'ca-app-pub-3940256099942544/2934735716';
}
