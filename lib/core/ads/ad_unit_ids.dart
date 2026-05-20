import 'dart:io';

class AdUnitIds {
  AdUnitIds._();

  // Google official test banner IDs. Replace with production IDs before release.
  static String get resultBanner {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return 'ca-app-pub-3940256099942544/6300978111';
  }
}
