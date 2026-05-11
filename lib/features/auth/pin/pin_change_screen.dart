import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'pin_notifier.dart';
import 'randomized_pin_pad.dart';

class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  String _current = '';
  String _newPin = '';
  String _confirm = '';
  int _step = 0;
  int _shuffleSeed = 0;
  String? _error;

  String get _entered => switch (_step) {
        0 => _current,
        1 => _newPin,
        _ => _confirm,
      };

  String get _title => switch (_step) {
        0 => '현재 PIN 입력',
        1 => '새 PIN 입력',
        _ => '새 PIN 확인',
      };

  String get _subtitle => switch (_step) {
        0 => '현재 사용 중인 PIN 4자리를 입력해주세요',
        1 => '새로 사용할 PIN 4자리를 입력해주세요',
        _ => '새 PIN을 한 번 더 입력해주세요',
      };

  void _onDigit(String value) {
    if (_entered.length >= 4) return;
    setState(() {
      if (_step == 0) _current += value;
      if (_step == 1) _newPin += value;
      if (_step == 2) _confirm += value;
      _error = null;
    });
    if (_entered.length == 4) {
      Future.microtask(_next);
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() {
      if (_step == 0) _current = _current.substring(0, _current.length - 1);
      if (_step == 1) _newPin = _newPin.substring(0, _newPin.length - 1);
      if (_step == 2) _confirm = _confirm.substring(0, _confirm.length - 1);
      _error = null;
    });
  }

  Future<void> _next() async {
    if (_step == 0) {
      if (!ref.read(pinNotifierProvider.notifier).verifyPin(_current)) {
        setState(() {
          _current = '';
          _shuffleSeed++;
          _error = '현재 PIN이 일치하지 않습니다.';
        });
        return;
      }
      setState(() {
        _step = 1;
        _shuffleSeed++;
      });
      return;
    }

    if (_step == 1) {
      setState(() {
        _step = 2;
        _shuffleSeed++;
      });
      return;
    }

    if (_newPin != _confirm) {
      setState(() {
        _newPin = '';
        _confirm = '';
        _step = 1;
        _shuffleSeed++;
        _error = '새 PIN이 서로 다릅니다. 다시 입력해주세요.';
      });
      return;
    }

    await ref.read(pinNotifierProvider.notifier).changePin(
          currentPin: _current,
          newPin: _newPin,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN이 변경되었습니다.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('PIN 변경')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                _error ?? _subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _error == null
                      ? AppColors.textSecondary
                      : AppColors.danger,
                ),
              ),
              const SizedBox(height: 32),
              _PinDots(count: _entered.length),
              const Spacer(),
              RandomizedPinPad(
                shuffleSeed: _shuffleSeed,
                onDigit: _onDigit,
                onDelete: _onDelete,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int count;

  const _PinDots({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < count ? AppColors.primary : const Color(0xFFD1D5DB),
          ),
        ),
      ),
    );
  }
}
