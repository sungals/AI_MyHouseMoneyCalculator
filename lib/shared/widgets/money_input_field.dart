import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/utils/money_formatter.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/gen/app_localizations.dart';

class MoneyInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final bool showQuickButtons;
  final List<int>? quickButtonAmounts;
  final double? sliderMax;
  final double sliderMin;
  final int sliderDivisions;

  const MoneyInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.showQuickButtons = true,
    this.quickButtonAmounts,
    this.sliderMax,
    this.sliderMin = 0,
    this.sliderDivisions = 100,
  });

  @override
  State<MoneyInputField> createState() => _MoneyInputFieldState();
}

class _MoneyInputFieldState extends State<MoneyInputField> {
  final _formatter = NumberFormat('#,###', 'ko_KR');
  double _sliderValue = 0;
  String _koreanAmount = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _syncSliderFromText();
  }

  void _syncSliderFromText() {
    final digits = widget.controller.text.replaceAll(',', '');
    final value = double.tryParse(digits) ?? 0;
    _koreanAmount = MoneyFormatter.formatKorean(value.round());
    if (widget.sliderMax == null) return;
    _sliderValue = value.clamp(widget.sliderMin, widget.sliderMax!);
  }

  void _onChanged() {
    final text = widget.controller.text;
    final digits = text.replaceAll(',', '');
    if (digits.isEmpty) {
      if (widget.sliderMax != null) {
        setState(() => _sliderValue = widget.sliderMin);
      } else if (_koreanAmount.isNotEmpty) {
        setState(() => _koreanAmount = '');
      }
      return;
    }

    final value = int.tryParse(digits);
    if (value == null) return;

    final formatted = _formatter.format(value);
    if (formatted != text) {
      final cursorPos = widget.controller.selection.base.offset;
      final oldLength = text.length;
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: cursorPos + (formatted.length - oldLength),
        ),
      );
    }

    if (widget.sliderMax != null) {
      final clamped =
          value.toDouble().clamp(widget.sliderMin, widget.sliderMax!);
      final korean = MoneyFormatter.formatKorean(value);
      if (clamped != _sliderValue || korean != _koreanAmount) {
        setState(() {
          _sliderValue = clamped;
          _koreanAmount = korean;
        });
      }
    } else {
      final korean = MoneyFormatter.formatKorean(value);
      if (korean != _koreanAmount) {
        setState(() => _koreanAmount = korean);
      }
    }
  }

  void _onSliderChanged(double value) {
    setState(() => _sliderValue = value);
    final rounded = value.round();
    final formatted = _formatter.format(rounded);
    if (widget.controller.text != formatted) {
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _addAmount(int amount) {
    final current =
        int.tryParse(widget.controller.text.replaceAll(',', '')) ?? 0;
    final next = (current + amount).clamp(0, 9999999999);
    final formatted = _formatter.format(next);
    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _deleteLastZero() {
    final current =
        int.tryParse(widget.controller.text.replaceAll(',', '')) ?? 0;
    if (current == 0) return;
    final next = current ~/ 10;
    if (next == 0) {
      widget.controller.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
      final formatted = _formatter.format(next);
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _reset() {
    widget.controller.text = '';
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
          ],
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onFieldSubmitted: (_) {
            if (widget.nextFocusNode != null) {
              FocusScope.of(context).requestFocus(widget.nextFocusNode);
            }
          },
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? '0',
            suffixText: '원',
            helperText: _koreanAmount.isEmpty ? null : _koreanAmount,
          ),
        ),
        if (widget.sliderMax != null) ...[
          const SizedBox(height: 2),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _sliderValue,
              min: widget.sliderMin,
              max: widget.sliderMax!,
              divisions: widget.sliderDivisions,
              activeColor: palette.primary,
              inactiveColor: palette.divider,
              onChanged: _onSliderChanged,
            ),
          ),
        ],
        if (widget.showQuickButtons) ...[
          const SizedBox(height: 8),
          _QuickButtons(
            onAdd: _addAmount,
            onDelete: _deleteLastZero,
            onReset: _reset,
            amounts: widget.quickButtonAmounts,
          ),
        ],
      ],
    );
  }
}

class _QuickButtons extends StatelessWidget {
  final void Function(int) onAdd;
  final VoidCallback onDelete;
  final VoidCallback onReset;
  final List<int>? amounts;

  const _QuickButtons({
    required this.onAdd,
    required this.onDelete,
    required this.onReset,
    this.amounts,
  });

  static const _defaultAmounts = [100000000, 10000000, 1000000];

  static String _label(int amount) {
    if (amount >= 100000000) return '${amount ~/ 100000000}억';
    if (amount >= 10000000) return '${amount ~/ 10000000}천만';
    if (amount >= 1000000) return '${amount ~/ 1000000}백만';
    if (amount >= 10000) return '${amount ~/ 10000}만';
    return amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final list = amounts ?? _defaultAmounts;
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final a in list)
          _Chip(label: '+${_label(a)}', onTap: () => onAdd(a), isPlus: true),
        _Chip(label: '⌫', onTap: onDelete, isDelete: true),
        _Chip(label: l10n.sharedResetAmount, onTap: onReset, isReset: true),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPlus;
  final bool isDelete;
  final bool isReset;

  const _Chip({
    required this.label,
    required this.onTap,
    this.isPlus = false,
    this.isDelete = false,
    this.isReset = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    final Color bg;
    final Color border;
    final Color text;

    if (isReset) {
      bg = palette.background;
      border = palette.divider;
      text = palette.textSecondary;
    } else if (isDelete) {
      bg = const Color(0xFFFFF7ED);
      border = const Color(0xFFFDBA74);
      text = const Color(0xFFEA580C);
    } else {
      bg = palette.primary.withOpacity(0.08);
      border = palette.primary.withOpacity(0.3);
      text = palette.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
