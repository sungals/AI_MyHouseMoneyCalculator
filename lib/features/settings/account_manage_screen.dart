import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_notifier.dart';

class AccountManageScreen extends ConsumerWidget {
  const AccountManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('계정 관리')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(email, style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('위험 구역', style: AppTextStyles.label),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.danger.withOpacity(0.4)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.danger,
                  size: 22,
                ),
                title: const Text(
                  '회원탈퇴',
                  style: TextStyle(fontSize: 15, color: AppColors.danger),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onTap: () => _deleteAccount(context, ref),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '탈퇴하면 계정과 저장된 모든 계산 기록이 삭제되며 되돌릴 수 없습니다.',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text(
          '탈퇴하면 계정과 저장된 모든 계산 기록이 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final error = await ref.read(authNotifierProvider.notifier).deleteAccount();

    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $error'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    await Hive.box('app_settings').put('login_skipped', false);
    if (!context.mounted) return;
    context.go('/login');
  }
}
