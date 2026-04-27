abstract class PurchaseService {
  Future<void> initialize();
  bool get isAdFreeUnlocked;
  Future<bool> purchaseAdFree();
  Future<bool> restorePurchases();
  void dispose();
}

class NoOpPurchaseService implements PurchaseService {
  @override
  Future<void> initialize() async {}

  @override
  bool get isAdFreeUnlocked => false;

  @override
  Future<bool> purchaseAdFree() async => false;

  @override
  Future<bool> restorePurchases() async => false;

  @override
  void dispose() {}
}
