import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/gen/app_localizations.dart';

class DisclaimerBox extends StatelessWidget {
  final bool isShort;

  const DisclaimerBox({super.key, this.isShort = true});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: palette.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isShort ? l10n.sharedDisclaimerShort : l10n.sharedDisclaimerMain,
              style: typography.disclaimer,
            ),
          ),
        ],
      ),
    );
  }
}
