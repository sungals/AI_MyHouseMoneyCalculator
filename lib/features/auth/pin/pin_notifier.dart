import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pin_state.dart';

class PinNotifier extends StateNotifier<PinState> {
  PinNotifier() : super(_loadInitialState());

  static const _keyEnabled = 'simple_login_enabled';
  static const _keyHash = 'simple_login_pin_hash';
  static const _keyBiometricEnabled = 'simple_login_biometric_enabled';
  static const _keyRequireAuthOnLaunch = 'simple_login_require_auth_on_launch';

  static PinState _loadInitialState() {
    final box = Hive.box('app_settings');
    final enabled = box.get(_keyEnabled, defaultValue: false) as bool;
    final requireAuthOnLaunch =
        box.get(_keyRequireAuthOnLaunch, defaultValue: true) as bool;
    return enabled
        ? PinEnabled(
            isUnlocked: !requireAuthOnLaunch,
            requireAuthOnLaunch: requireAuthOnLaunch,
          )
        : const PinDisabled();
  }

  static String _hash(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> setPin(String pin) async {
    final box = Hive.box('app_settings');
    final requireAuthOnLaunch =
        box.get(_keyRequireAuthOnLaunch, defaultValue: true) as bool;
    await box.put(_keyHash, _hash(pin));
    await box.put(_keyEnabled, true);
    await box.put(_keyRequireAuthOnLaunch, requireAuthOnLaunch);
    state = PinEnabled(
      isUnlocked: true,
      requireAuthOnLaunch: requireAuthOnLaunch,
    );
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (!verifyPin(currentPin)) return false;
    await setPin(newPin);
    return true;
  }

  bool verifyPin(String pin) {
    final box = Hive.box('app_settings');
    final stored = box.get(_keyHash) as String?;
    if (stored == null) return false;
    return stored == _hash(pin);
  }

  void unlock() {
    if (state is PinEnabled) {
      state = (state as PinEnabled).copyWith(isUnlocked: true);
    }
  }

  void lockForLaunch() {
    final current = state;
    if (current is PinEnabled && current.requireAuthOnLaunch) {
      state = current.copyWith(isUnlocked: false);
    }
  }

  Future<void> disablePin() async {
    final box = Hive.box('app_settings');
    await box.delete(_keyHash);
    await box.delete(_keyBiometricEnabled);
    await box.delete(_keyRequireAuthOnLaunch);
    await box.put(_keyEnabled, false);
    state = const PinDisabled();
  }

  Future<void> setRequireAuthOnLaunch(bool requireAuthOnLaunch) async {
    final current = state;
    if (current is! PinEnabled) return;

    final box = Hive.box('app_settings');
    await box.put(_keyRequireAuthOnLaunch, requireAuthOnLaunch);
    state = current.copyWith(
      isUnlocked: requireAuthOnLaunch ? current.isUnlocked : true,
      requireAuthOnLaunch: requireAuthOnLaunch,
    );
  }

  bool get hasPIN => state is PinEnabled;
}

final pinNotifierProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier();
});
