import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CalculatorMenuItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const CalculatorMenuItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class CalculatorMenus {
  CalculatorMenus._();

  static const housing = [
    CalculatorMenuItem(
      title: '전세 vs 월세 비교',
      description: '전세 대출이자와 월세 비용을 비교해요',
      icon: Icons.compare_arrows_rounded,
      color: AppColors.primary,
      route: '/rent-compare',
    ),
    CalculatorMenuItem(
      title: '복수 시나리오 비교',
      description: '금리 A/B/C 조건을 나란히 비교해요',
      icon: Icons.view_column_rounded,
      color: Color(0xFF2563EB),
      route: '/scenario-compare',
    ),
    CalculatorMenuItem(
      title: '계약 갱신 계산',
      description: '갱신청구권 5% 상한 금액을 계산해요',
      icon: Icons.update_rounded,
      color: Color(0xFFEA580C),
      route: '/contract-renewal',
    ),
    CalculatorMenuItem(
      title: '반전세 계산',
      description: '전월세 전환율로 월세 적정성을 확인해요',
      icon: Icons.swap_horiz_rounded,
      color: Color(0xFF7C3AED),
      route: '/semi-rent',
    ),
  ];

  static const finance = [
    CalculatorMenuItem(
      title: '대출이자 계산',
      description: '월 이자와 총 이자를 빠르게 계산해요',
      icon: Icons.account_balance_rounded,
      color: AppColors.warning,
      route: '/loan-interest',
    ),
    CalculatorMenuItem(
      title: '월 고정비 계산',
      description: '매달 나가는 고정 지출을 한눈에 정리해요',
      icon: Icons.receipt_long_rounded,
      color: AppColors.positive,
      route: '/monthly-expense',
    ),
    CalculatorMenuItem(
      title: '연말정산 세액공제',
      description: '월세 공제와 전세대출 절세 혜택을 계산해요',
      icon: Icons.receipt_outlined,
      color: Color(0xFF0891B2),
      route: '/tax-deduction',
    ),
    CalculatorMenuItem(
      title: 'DSR/DTI 계산',
      description: '소득 대비 대출 상환 부담을 확인해요',
      icon: Icons.speed_rounded,
      color: Color(0xFF0F766E),
      route: '/dsr-dti',
    ),
    CalculatorMenuItem(
      title: '중개보수 계산',
      description: '주택 매매와 임대차 중개보수 상한을 계산해요',
      icon: Icons.handshake_outlined,
      color: Color(0xFF9333EA),
      route: '/brokerage-fee',
    ),
    CalculatorMenuItem(
      title: '취득세 계산',
      description: '주택 취득가액과 보유 주택 수로 간이 계산해요',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFFBE123C),
      route: '/acquisition-tax',
    ),
  ];

  static const featured = [
    CalculatorMenuItem(
      title: '전세 vs 월세 비교',
      description: '전세 대출이자와 월세 비용을 비교해요',
      icon: Icons.compare_arrows_rounded,
      color: AppColors.primary,
      route: '/rent-compare',
    ),
    CalculatorMenuItem(
      title: '복수 시나리오 비교',
      description: '금리 A/B/C 조건을 나란히 비교해요',
      icon: Icons.view_column_rounded,
      color: Color(0xFF2563EB),
      route: '/scenario-compare',
    ),
    CalculatorMenuItem(
      title: '계약 갱신 계산',
      description: '갱신청구권 5% 상한 금액을 계산해요',
      icon: Icons.update_rounded,
      color: Color(0xFFEA580C),
      route: '/contract-renewal',
    ),
    CalculatorMenuItem(
      title: '대출이자 계산',
      description: '월 이자와 총 이자를 빠르게 계산해요',
      icon: Icons.account_balance_rounded,
      color: AppColors.warning,
      route: '/loan-interest',
    ),
  ];
}

class CalculatorMenuCard extends StatelessWidget {
  final CalculatorMenuItem item;
  final VoidCallback onTap;

  const CalculatorMenuCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(item.description, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
