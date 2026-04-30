import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'pin_notifier.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _entered = '';
  bool _hasError = false;
  static const _pinLength = 6;

  void _onDigit(String digit) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _entered += digit;
      _hasError = false;
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
    });
  }

  void _verify() {
    final notifier = ref.read(pinNotifierProvider.notifier);
    if (notifier.verifyPin(_entered)) {
      notifier.unlock();
      context.go('/');
    } else {
      setState(() {
        _entered = '';
        _hasError = true;
      });
    }
  }

  void _useEmailLogin() {
    ref.read(pinNotifierProvider.notifier).disablePin();
    final box = Hive.box('app_settings');
    box.put('login_skipped', false);
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Text(
              '간편로그인',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasError ? '비밀번호가 틀렸습니다' : 'PIN 번호를 입력하세요',
              style: TextStyle(
                fontSize: 14,
                color: _hasError ? AppColors.danger : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _PinDots(
              entered: _entered.length,
              total: _pinLength,
              hasError: _hasError,
            ),
            const Spacer(),
            _NumPad(onDigit: _onDigit, onDelete: _onDelete),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _useEmailLogin,
              child: const Text(
                '이메일로 로그인',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
          ],
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

class _NumPad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  const _NumPad({required this.onDigit, required this.onDelete});

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', 'del'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 96, height: 84);
            if (key == 'del') {
              return _KeyButton(
                onTap: (_) => onDelete(),
                child: const Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              );
            }
            return _KeyButton(onTap: onDigit, label: key);
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final void Function(String) onTap;
  final String? label;
  final Widget? child;

  const _KeyButton({required this.onTap, this.label, this.child});

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        widget.onTap(widget.label ?? '');
        setState(() => _pressed = false);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: SizedBox(
        width: 96,
        height: 84,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pressed
                  ? const Color(0xFFD8DCE4)
                  : AppColors.surface,
              boxShadow: _pressed
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Center(
              child: widget.child ??
                  Text(
                    widget.label!,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
