import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'calculator_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                '자주 쓰는 계산을\n빠르게 시작하세요',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                '전체 기능은 하단의 주거, 금융 탭에서 분류별로 볼 수 있어요.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),
              Text('추천 계산', style: AppTextStyles.label),
              const SizedBox(height: 12),
              for (final item in CalculatorMenus.featured) ...[
                CalculatorMenuCard(
                  item: item,
                  onTap: () => context.push(item.route),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
