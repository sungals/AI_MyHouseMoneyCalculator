abstract class AdService {
  Future<void> initialize();
  bool get isAdFree;
  void showBanner();
  Future<void> showInterstitial();
  void dispose();
}

class NoOpAdService implements AdService {
  @override
  Future<void> initialize() async {}

  @override
  bool get isAdFree => true;

  @override
  void showBanner() {}

  @override
  Future<void> showInterstitial() async {}

  @override
  void dispose() {}
}
