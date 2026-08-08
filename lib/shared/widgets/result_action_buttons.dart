import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import 'result_ad_banner.dart';

class ResultActionButtons extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onExportPdf;
  final String? shareLabel;
  final String? saveLabel;
  final String? pdfLabel;
  final IconData shareIcon;
  final bool showAd;

  const ResultActionButtons({
    super.key,
    this.onShare,
    this.onSave,
    this.onExportPdf,
    this.shareLabel,
    this.saveLabel,
    this.pdfLabel,
    this.shareIcon = Icons.share_outlined,
    this.showAd = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveShareLabel = shareLabel ?? l10n.sharedShareAction;
    final effectiveSaveLabel = saveLabel ?? l10n.commonSave;
    final effectivePdfLabel = pdfLabel ?? l10n.sharedExportPdfAction;

    if (onShare == null && onSave == null && onExportPdf == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (onShare != null || onSave != null)
          Row(
            children: [
              if (onShare != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: Icon(shareIcon, size: 18),
                    label: Text(effectiveShareLabel),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              if (onShare != null && onSave != null) const SizedBox(width: 10),
              if (onSave != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: Text(effectiveSaveLabel),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
            ],
          ),
        if (onExportPdf != null) ...[
          if (onShare != null || onSave != null) const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: Text(effectivePdfLabel),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
        if (showAd) const ResultAdBanner(),
      ],
    );
  }
}
