import 'package:flutter/material.dart';
import '../../core/constants/disclaimer_texts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DisclaimerBox extends StatelessWidget {
  final bool isShort;

  const DisclaimerBox({super.key, this.isShort = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isShort ? DisclaimerTexts.short : DisclaimerTexts.main,
              style: AppTextStyles.disclaimer,
            ),
          ),
        ],
      ),
    );
  }
}
