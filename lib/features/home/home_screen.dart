import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                '오늘 어떤 비용을\n계산할까요?',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              _MenuCard(
                title: '전세 vs 월세 비교',
                description: '전세 대출이자와 월세 비용을 비교해요',
                icon: Icons.compare_arrows_rounded,
                color: AppColors.primary,
                onTap: () => context.push('/rent-compare'),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: '반전세 계산',
                description: '전월세 전환율로 월세 적정성을 확인해요',
                icon: Icons.swap_horiz_rounded,
                color: const Color(0xFF7C3AED),
                onTap: () => context.push('/semi-rent'),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: '대출이자 계산',
                description: '월 이자와 총 이자를 빠르게 계산해요',
                icon: Icons.account_balance_rounded,
                color: AppColors.warning,
                onTap: () => context.push('/loan-interest'),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: '월 고정비 계산',
                description: '매달 나가는 고정 지출을 한눈에 정리해요',
                icon: Icons.receipt_long_rounded,
                color: AppColors.positive,
                onTap: () => context.push('/monthly-expense'),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: '연말정산 세액공제',
                description: '월세 공제와 전세대출 절세 혜택을 계산해요',
                icon: Icons.receipt_outlined,
                color: const Color(0xFF0891B2),
                onTap: () => context.push('/tax-deduction'),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: 'DSR/DTI 계산',
                description: '소득 대비 대출 상환 부담을 확인해요',
                icon: Icons.speed_rounded,
                color: const Color(0xFF0F766E),
                onTap: () => context.push('/dsr-dti'),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: '중개보수 계산',
                description: '주택 매매와 임대차 중개보수 상한을 계산해요',
                icon: Icons.handshake_outlined,
                color: const Color(0xFF9333EA),
                onTap: () => context.push('/brokerage-fee'),
              ),
              const SizedBox(height: 12),
              _MenuCard(
                title: '취득세 계산',
                description: '주택 취득가액과 보유 주택 수로 간이 계산해요',
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFFBE123C),
                onTap: () => context.push('/acquisition-tax'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(description, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
