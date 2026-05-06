import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class RandomizedPinPad extends StatefulWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final int shuffleSeed;

  const RandomizedPinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.shuffleSeed = 0,
  });

  @override
  State<RandomizedPinPad> createState() => _RandomizedPinPadState();
}

class _RandomizedPinPadState extends State<RandomizedPinPad> {
  late List<String> _digits;

  @override
  void initState() {
    super.initState();
    _shuffleDigits();
  }

  @override
  void didUpdateWidget(RandomizedPinPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shuffleSeed != widget.shuffleSeed) {
      _shuffleDigits();
    }
  }

  void _shuffleDigits() {
    _digits = List.generate(10, (index) => '$index')..shuffle(Random.secure());
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ..._digits.take(9),
      '',
      _digits.last,
      'del',
    ];

    return Column(
      children: List.generate(4, (rowIndex) {
        final row = keys.skip(rowIndex * 3).take(3);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) return const SizedBox(width: 96, height: 84);
            if (key == 'del') {
              return _KeyButton(
                onTap: (_) => widget.onDelete(),
                child: const Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              );
            }
            return _KeyButton(onTap: widget.onDigit, label: key);
          }).toList(),
        );
      }),
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
              color: _pressed ? const Color(0xFFD8DCE4) : AppColors.surface,
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
