import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/extensions/number_format_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/rent_compare_result.dart';
import '../../../shared/widgets/disclaimer_box.dart';
import '../../../shared/widgets/result_action_buttons.dart';
import '../rent_compare_localizations.dart';

class RentCompareResultCard extends StatelessWidget {
  final RentCompareResult result;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onExportPdf;
  final bool showActions;

  const RentCompareResultCard({
    super.key,
    required this.result,
    this.onSave,
    this.onShare,
    this.onExportPdf,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final winnerLabel = result.isJeonseAdvantageous ? '전세 우세' : '월세 우세';
    final winnerIcon = result.isJeonseAdvantageous
        ? Icons.home_work_outlined
        : Icons.key_outlined;
    final diffColor =
        result.isJeonseAdvantageous ? AppColors.positive : AppColors.danger;
    const jeonseColor = AppColors.primary;
    const rentColor = AppColors.warning;

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: diffColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(winnerIcon, size: 18, color: diffColor),
                    const SizedBox(width: 6),
                    Text(
                      winnerLabel,
                      style: context.typography.label.copyWith(
                        color: diffColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                rentCompareRecommendationText(result),
                style: context.typography.heading2.copyWith(color: diffColor),
              ),
              const SizedBox(height: 6),
              Text(
                '전세와 월세의 실질 월 비용을 같은 기준으로 비교했어요.',
                style: context.typography.bodySecondary,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final useVertical = constraints.maxWidth < 420;
                  final cards = [
                    _CompareCostCard(
                      title: '전세',
                      amount: result.jeonseMonthlyCost,
                      color: jeonseColor,
                      icon: Icons.home_outlined,
                      isWinner: result.isJeonseAdvantageous,
                      helper: '대출이자 + 관리비',
                    ),
                    _CompareCostCard(
                      title: '월세',
                      amount: result.adjustedRentMonthlyCost,
                      color: rentColor,
                      icon: Icons.meeting_room_outlined,
                      isWinner: !result.isJeonseAdvantageous,
                      helper: '월세 + 관리비 - 기회비용',
                    ),
                  ];

                  if (useVertical) {
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 10),
                        cards[1],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 10),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              _DifferenceBanner(
                monthlyDifference: result.monthlyDifference.abs(),
                totalDifference: result.totalDifference.abs(),
                color: diffColor,
              ),
              const SizedBox(height: 20),
              _CostBarChart(
                jeonse: result.jeonseMonthlyCost,
                adjustedRent: result.adjustedRentMonthlyCost,
                jeonseColor: jeonseColor,
                rentColor: rentColor,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Text('비용 상세', style: context.typography.label),
              const SizedBox(height: 12),
              _Row(
                label: '전세 월 비용',
                value: result.jeonseMonthlyCost.wonFormat,
                valueColor: jeonseColor,
              ),
              const SizedBox(height: 10),
              _Row(
                label: '월세 + 관리비',
                value: result.rentMonthlyCost.wonFormat,
                valueColor: rentColor,
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
                valueColor: rentColor,
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
        if (showActions &&
            (onSave != null || onShare != null || onExportPdf != null)) ...[
          const SizedBox(height: 16),
          ResultActionButtons(
            onShare: onShare,
            onSave: onSave,
            onExportPdf: onExportPdf,
            shareLabel: '이미지 공유',
            shareIcon: Icons.image_outlined,
          ),
        ],
      ],
    );
  }
}

class _CostBarChart extends StatelessWidget {
  final int jeonse;
  final int adjustedRent;
  final Color jeonseColor;
  final Color rentColor;

  const _CostBarChart({
    required this.jeonse,
    required this.adjustedRent,
    required this.jeonseColor,
    required this.rentColor,
  });

  @override
  Widget build(BuildContext context) {
    final jeonseY = jeonse.toDouble();
    final rentY = adjustedRent.clamp(0, double.maxFinite).toDouble();
    final maxY = (jeonseY > rentY ? jeonseY : rentY) * 1.25;
    final safeMaxY = maxY <= 0 ? 1.0 : maxY;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('월 비용 비교 그래프', style: context.typography.label),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: safeMaxY,
                barTouchData: BarTouchData(enabled: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: jeonseY,
                        color: jeonseColor,
                        width: 44,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: rentY,
                        color: rentColor,
                        width: 44,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
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
                          child:
                              Text(labels[idx], style: context.typography.caption),
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
          ),
        ],
      ),
    );
  }
}

class _CompareCostCard extends StatelessWidget {
  final String title;
  final int amount;
  final Color color;
  final IconData icon;
  final bool isWinner;
  final String helper;

  const _CompareCostCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isWinner,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWinner ? color.withOpacity(0.75) : color.withOpacity(0.18),
          width: isWinner ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: context.typography.heading3.copyWith(color: color),
                ),
              ),
              if (isWinner)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '유리',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            amount.wonFormat,
            style: context.typography.resultAmount.copyWith(
              color: color,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(helper, style: context.typography.caption),
        ],
      ),
    );
  }
}

class _DifferenceBanner extends StatelessWidget {
  final int monthlyDifference;
  final int totalDifference;
  final Color color;

  const _DifferenceBanner({
    required this.monthlyDifference,
    required this.totalDifference,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows_rounded, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '월 ${monthlyDifference.wonFormat} 차이, 전체 기간 ${totalDifference.wonFormat} 차이',
              style: context.typography.body.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
        Text(label, style: context.typography.bodySecondary),
        Text(
          value,
          style: isBold
              ? context.typography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                )
              : context.typography.body.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
