import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/legal_texts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LegalDocumentScreen extends StatelessWidget {
  final LegalDocument document;

  const LegalDocumentScreen({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(document.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(document.updatedAt, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 16),
              ...document.sections.map(_LegalSectionView.new),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalSectionView extends StatelessWidget {
  final LegalSection section;

  const _LegalSectionView(this.section);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          ...section.paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                paragraph,
                style: AppTextStyles.bodySecondary.copyWith(height: 1.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
