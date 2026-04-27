import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: AppTextStyles.resultAmount.copyWith(
                    color: amountColor ?? AppColors.primary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: AppTextStyles.bodySecondary),
          ],
        ],
      ),
    );
  }
}
