import 'package:fl_chart/fl_chart.dart';
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
              _CostBarChart(
                jeonse: result.jeonseMonthlyCost,
                adjustedRent: result.adjustedRentMonthlyCost,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _Row(
                label: '전세 월 비용',
                value: result.jeonseMonthlyCost.wonFormat,
              ),
              const SizedBox(height: 10),
              _Row(
                label: '월세 + 관리비',
                value: result.rentMonthlyCost.wonFormat,
              ),
              if (result.opportunityCostMonthly != 0) ...[
                const SizedBox(height: 10),
                _Row(
                  label: '기회비용 공제',
                  value: '- ${result.opportunityCostMonthly.wonFormat}',
                  valueColor: AppColors.positive,
                ),
              ],
              const SizedBox(height: 10),
              _Row(
                label: '실질 월세 월 비용',
                value: result.adjustedRentMonthlyCost.wonFormat,
              ),
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
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('이미지 공유'),
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

class _CostBarChart extends StatelessWidget {
  final int jeonse;
  final int adjustedRent;

  const _CostBarChart({required this.jeonse, required this.adjustedRent});

  @override
  Widget build(BuildContext context) {
    final jeonseY = jeonse.toDouble();
    final rentY = adjustedRent.clamp(0, double.maxFinite).toDouble();
    final maxY = (jeonseY > rentY ? jeonseY : rentY) * 1.25;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: jeonseY,
                  color: AppColors.primary,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: rentY,
                  color: AppColors.warning,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = ['전세', '실질 월세'];
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(labels[idx], style: AppTextStyles.caption),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
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
