import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../router/app_router.dart';
import 'biometric_auth_service.dart';
import 'pin_notifier.dart';

class BiometricLoginScreen extends ConsumerStatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  ConsumerState<BiometricLoginScreen> createState() =>
      _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends ConsumerState<BiometricLoginScreen> {
  static const _maxBiometricAttempts = 3;

  bool _isChecking = true;
  bool _hasError = false;
  String _message = '생체인증으로 앱을 잠금 해제하세요';
  int _failCount = 0;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final service = ref.read(biometricAuthServiceProvider);
    final canUseBiometric =
        service.isEnabled && await service.canAuthenticate();
    if (!mounted) return;

    if (!canUseBiometric) {
      context.go('/pin-login');
      return;
    }

    setState(() => _isChecking = false);
  }

  Future<void> _authenticate() async {
    if (_isChecking) return;

    final result =
        await ref.read(biometricAuthServiceProvider).authenticateForResult();
    if (!mounted) return;

    if (result == BiometricAuthResult.authenticated) {
      ref.read(pinNotifierProvider.notifier).unlock();
      context.go(AppRouter.consumePendingRouteAfterUnlock());
      return;
    }

    if (result == BiometricAuthResult.unavailable) {
      setState(() {
        _hasError = true;
        _message = '생체인증을 완료하지 못했습니다. 다시 시도해주세요';
      });
      return;
    }

    _failCount++;
    if (_failCount >= _maxBiometricAttempts) {
      await ref.read(biometricAuthServiceProvider).disable();
      if (mounted) context.go('/pin-login');
      return;
    }

    final remaining = _maxBiometricAttempts - _failCount;
    setState(() {
      _hasError = true;
      _message = '생체인증에 실패했습니다. $remaining회 더 시도할 수 있습니다';
    });
  }

  void _usePin() {
    context.go('/pin-login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const Spacer(),
                        Icon(
                          Icons.fingerprint,
                          size: 80,
                          color:
                              _hasError ? AppColors.danger : AppColors.primary,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '생체인증',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isChecking ? '기기 생체인증 상태를 확인하고 있습니다' : _message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: _hasError
                                ? AppColors.danger
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isChecking ? null : _authenticate,
                            child: const Text('인증하기'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _usePin,
                          child: const Text(
                            'PIN 번호로 인증',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
