import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAuthResult { authenticated, failed, unavailable }

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;
  static const _keyEnabled = 'simple_login_biometric_enabled';

  bool get isEnabled {
    final box = Hive.box('app_settings');
    return box.get(_keyEnabled, defaultValue: false) as bool;
  }

  Future<void> setEnabled(bool enabled) async {
    final box = Hive.box('app_settings');
    await box.put(_keyEnabled, enabled);
  }

  Future<void> disable() => setEnabled(false);

  Future<bool> canAuthenticate() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    final result = await authenticateForResult();
    return result == BiometricAuthResult.authenticated;
  }

  Future<BiometricAuthResult> authenticateForResult() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: '간편로그인을 위해 생체인증을 진행해주세요',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated
          ? BiometricAuthResult.authenticated
          : BiometricAuthResult.failed;
    } on PlatformException {
      return BiometricAuthResult.unavailable;
    }
  }
}

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});
