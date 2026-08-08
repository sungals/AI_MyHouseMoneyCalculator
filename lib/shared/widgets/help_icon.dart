import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/gen/app_localizations.dart';

class HelpIcon extends StatelessWidget {
  final String title;
  final String body;

  const HelpIcon({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 20, color: palette.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Text(body,
              style: TextStyle(
                  fontSize: 14, height: 1.65, color: palette.textPrimary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.help_outline_rounded,
            size: 18, color: palette.textSecondary),
      ),
    );
  }
}
