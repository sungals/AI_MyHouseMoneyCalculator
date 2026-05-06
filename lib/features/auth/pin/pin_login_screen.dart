import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'pin_notifier.dart';
import 'randomized_pin_pad.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  static const _pinLength = 6;
  static const _maxPinAttempts = 5;

  String _entered = '';
  bool _hasError = false;
  String? _message;
  int _keypadShuffleSeed = 0;
  int _pinFailCount = 0;

  void _onDigit(String digit) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _entered += digit;
      _hasError = false;
      _message = null;
    });
    if (_entered.length == _pinLength) {
      _verify();
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
      _hasError = false;
      _message = null;
    });
  }

  Future<void> _verify() async {
    final notifier = ref.read(pinNotifierProvider.notifier);
    if (notifier.verifyPin(_entered)) {
      notifier.unlock();
      context.go('/');
    } else {
      _pinFailCount++;

      if (_pinFailCount >= _maxPinAttempts) {
        await _resetPinAndGoToEmailLogin();
        return;
      }

      final remaining = _maxPinAttempts - _pinFailCount;
      setState(() {
        _entered = '';
        _hasError = true;
        _message = 'PIN 번호가 틀렸습니다. $remaining회 더 시도할 수 있습니다';
        _keypadShuffleSeed++;
      });
    }
  }

  Future<void> _resetPinAndGoToEmailLogin() async {
    await ref.read(pinNotifierProvider.notifier).disablePin();
    final box = Hive.box('app_settings');
    await box.put('login_skipped', false);
    if (mounted) context.go('/login');
  }

  Future<void> _useEmailLogin() async {
    final box = Hive.box('app_settings');
    await box.put('login_skipped', false);
    if (mounted) context.go('/login');
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
                  child: Column(
                    children: [
                      const Spacer(),
                      const Text(
                        'PIN 인증',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _message ?? 'PIN 번호를 입력하세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: _hasError
                              ? AppColors.danger
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _PinDots(
                        entered: _entered.length,
                        total: _pinLength,
                        hasError: _hasError,
                      ),
                      const Spacer(),
                      RandomizedPinPad(
                        onDigit: _onDigit,
                        onDelete: _onDelete,
                        shuffleSeed: _keypadShuffleSeed,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: _useEmailLogin,
                        child: const Text(
                          '이메일로 로그인',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
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

class _PinDots extends StatelessWidget {
  final int entered;
  final int total;
  final bool hasError;

  const _PinDots({
    required this.entered,
    required this.total,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final filled = i < entered;
        final color = hasError
            ? AppColors.danger
            : filled
                ? AppColors.primary
                : Colors.transparent;
        final borderColor = hasError
            ? AppColors.danger
            : filled
                ? AppColors.primary
                : AppColors.textSecondary;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: borderColor, width: 2),
          ),
        );
      }),
    );
  }
}
