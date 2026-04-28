import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HelpIcon extends StatelessWidget {
  final String title;
  final String body;

  const HelpIcon({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Text(body,
              style: const TextStyle(fontSize: 14, height: 1.65, color: AppColors.textPrimary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.help_outline_rounded, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}
