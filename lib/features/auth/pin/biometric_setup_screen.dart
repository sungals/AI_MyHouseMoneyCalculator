import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'biometric_auth_service.dart';
import 'pin_notifier.dart';

class BiometricSetupScreen extends ConsumerStatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  ConsumerState<BiometricSetupScreen> createState() =>
      _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends ConsumerState<BiometricSetupScreen> {
  bool _isLoading = true;
  bool _canUseBiometric = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final canUseBiometric =
        await ref.read(biometricAuthServiceProvider).canAuthenticate();
    if (!mounted) return;
    setState(() {
      _canUseBiometric = canUseBiometric;
      _isLoading = false;
    });
  }

  Future<void> _enableBiometric() async {
    final service = ref.read(biometricAuthServiceProvider);
    final authenticated = await service.authenticate();
    if (!mounted) return;

    if (authenticated) {
      await service.setEnabled(true);
      ref.read(pinNotifierProvider.notifier).unlock();
      if (mounted) context.go('/');
      return;
    }

    setState(() => _hasError = true);
  }

  Future<void> _skip() async {
    await ref.read(biometricAuthServiceProvider).setEnabled(false);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _isLoading
        ? '기기 생체인증 상태를 확인하고 있습니다'
        : _canUseBiometric
            ? '다음 로그인부터 지문 또는 Face ID로 잠금 해제할 수 있습니다'
            : '이 기기에서는 사용할 수 있는 생체인증을 찾지 못했습니다';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
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
                          size: 72,
                          color: _canUseBiometric
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '생체인증 사용',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hasError ? '생체인증에 실패했습니다. 다시 시도해주세요' : subtitle,
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
                            onPressed: _isLoading
                                ? null
                                : _canUseBiometric
                                    ? _enableBiometric
                                    : _skip,
                            child: Text(_canUseBiometric ? '사용하기' : '확인'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_canUseBiometric)
                          TextButton(
                            onPressed: _skip,
                            child: const Text(
                              '나중에 하기',
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
