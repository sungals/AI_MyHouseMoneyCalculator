import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

class ResultSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final Color? amountColor;
  final Widget? trailing;

  const ResultSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.amountColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typography.label),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: typography.resultAmount.copyWith(
                    color: amountColor ?? palette.primary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: typography.bodySecondary),
          ],
        ],
      ),
    );
  }
}
