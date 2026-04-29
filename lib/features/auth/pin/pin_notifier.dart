import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pin_state.dart';

class PinNotifier extends StateNotifier<PinState> {
  PinNotifier() : super(_loadInitialState());

  static const _keyEnabled = 'simple_login_enabled';
  static const _keyHash = 'simple_login_pin_hash';

  static PinState _loadInitialState() {
    final box = Hive.box('app_settings');
    final enabled = box.get(_keyEnabled, defaultValue: false) as bool;
    return enabled ? const PinEnabled() : const PinDisabled();
  }

  static String _hash(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> setPin(String pin) async {
    final box = Hive.box('app_settings');
    await box.put(_keyHash, _hash(pin));
    await box.put(_keyEnabled, true);
    state = const PinEnabled(isUnlocked: true);
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

  Future<void> disablePin() async {
    final box = Hive.box('app_settings');
    await box.delete(_keyHash);
    await box.put(_keyEnabled, false);
    state = const PinDisabled();
  }

  bool get hasPIN => state is PinEnabled;
}

final pinNotifierProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier();
});
