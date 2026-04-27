import 'package:flutter/material.dart';
import '../../../core/extensions/number_format_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/rent_compare_result.dart';
import '../../../shared/widgets/disclaimer_box.dart';

class RentCompareResultCard extends StatelessWidget {
  final RentCompareResult result;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const RentCompareResultCard({
    super.key,
    required this.result,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final diffColor =
        result.isJeonseAdvantageous ? AppColors.positive : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.recommendationText,
                style: AppTextStyles.heading3.copyWith(color: diffColor),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _Row(label: '전세 월 비용', value: result.jeonseMonthlyCost.wonFormat),
              const SizedBox(height: 10),
              _Row(label: '월세 월 비용', value: result.rentMonthlyCost.wonFormat),
              const SizedBox(height: 10),
              _Row(
                label: '월 차이',
                value: result.monthlyDifference.abs().wonFormat,
                valueColor: diffColor,
                isBold: true,
              ),
              const SizedBox(height: 10),
              _Row(
                label: '전체 기간 차이',
                value: result.totalDifference.abs().wonFormat,
                valueColor: diffColor,
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const DisclaimerBox(),
        if (onSave != null || onShare != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (onShare != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('공유'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              if (onSave != null && onShare != null) const SizedBox(width: 10),
              if (onSave != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('저장'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(
          value,
          style: isBold
              ? AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                )
              : AppTextStyles.body.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
