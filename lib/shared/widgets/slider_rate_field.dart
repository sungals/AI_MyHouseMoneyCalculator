import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

class SliderRateField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const SliderRateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1.0,
    this.max = 6.0,
    this.divisions = 50,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: typography.bodySecondary),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: typography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: palette.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: palette.primary,
            inactiveColor: palette.divider,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toStringAsFixed(1)}%', style: typography.caption),
            Text('${max.toStringAsFixed(1)}%', style: typography.caption),
          ],
        ),
      ],
    );
  }
}
