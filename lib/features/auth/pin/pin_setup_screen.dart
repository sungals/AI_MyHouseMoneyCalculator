import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'pin_notifier.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  static const _pinLength = 6;

  _SetupStep _step = _SetupStep.enter;
  String _first = '';
  String _entered = '';
  bool _hasError = false;

  String get _title => _step == _SetupStep.enter ? 'PIN 번호 설정' : 'PIN 번호 확인';
  String get _subtitle {
    if (_hasError) return '번호가 일치하지 않습니다. 다시 시도하세요';
    return _step == _SetupStep.enter
        ? '사용할 PIN 번호 6자리를 입력하세요'
        : '확인을 위해 다시 한번 입력하세요';
  }

  void _onDigit(String digit) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _entered += digit;
      _hasError = false;
    });
    if (_entered.length == _pinLength) {
      _handleComplete();
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
      _hasError = false;
    });
  }

  Future<void> _handleComplete() async {
    if (_step == _SetupStep.enter) {
      setState(() {
        _first = _entered;
        _entered = '';
        _step = _SetupStep.confirm;
      });
    } else {
      if (_entered == _first) {
        await ref.read(pinNotifierProvider.notifier).setPin(_entered);
        if (mounted) context.go('/');
      } else {
        setState(() {
          _entered = '';
          _first = '';
          _step = _SetupStep.enter;
          _hasError = true;
        });
      }
    }
  }

  void _skip() => context.go('/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text(
              '건너뛰기',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              _title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              style: TextStyle(
                fontSize: 14,
                color: _hasError ? AppColors.danger : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _PinDotsRow(
              entered: _entered.length,
              total: _pinLength,
              hasError: _hasError,
            ),
            const Spacer(),
            _NumPadWidget(onDigit: _onDigit, onDelete: _onDelete),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

enum _SetupStep { enter, confirm }

class _PinDotsRow extends StatelessWidget {
  final int entered;
  final int total;
  final bool hasError;

  const _PinDotsRow({
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

class _NumPadWidget extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  const _NumPadWidget({required this.onDigit, required this.onDelete});

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
              return _Key(
                onTap: (_) => onDelete(),
                child: const Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              );
            }
            return _Key(onTap: onDigit, label: key);
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _Key extends StatefulWidget {
  final void Function(String) onTap;
  final String? label;
  final Widget? child;

  const _Key({required this.onTap, this.label, this.child});

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
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
