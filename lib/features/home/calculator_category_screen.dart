import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'calculator_menu.dart';

class CalculatorCategoryScreen extends StatelessWidget {
  final String title;
  final String headline;
  final String description;
  final List<CalculatorMenuItem> items;

  const CalculatorCategoryScreen({
    super.key,
    required this.title,
    required this.headline,
    required this.description,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(headline, style: context.typography.heading1),
              const SizedBox(height: 8),
              Text(description, style: context.typography.bodySecondary),
              const SizedBox(height: 24),
              for (final item in items) ...[
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
