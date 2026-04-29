import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/disclaimer_texts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../auth/pin/pin_notifier.dart';
import '../auth/pin/pin_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final pinState = ref.watch(pinNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _AccountSection(authState: authState, ref: ref),
            if (authState is AppAuthAuthenticated) ...[
              const SizedBox(height: 24),
              const _SectionHeader('간편로그인'),
              _PinTile(pinState: pinState, ref: ref),
            ],
            const SizedBox(height: 24),
            const _SectionHeader('앱 정보'),
            const _InfoTile(label: '앱 이름', value: AppConstants.appName),
            const _InfoTile(label: '버전', value: '1.0.0'),
            const SizedBox(height: 24),
            const _SectionHeader('법적 고지'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(DisclaimerTexts.main, style: AppTextStyles.disclaimer),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinTile extends StatelessWidget {
  final PinState pinState;
  final WidgetRef ref;

  const _PinTile({required this.pinState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final hasPIN = pinState is PinEnabled;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Icon(
          hasPIN ? Icons.lock : Icons.lock_open,
          color: hasPIN ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(hasPIN ? '간편로그인 사용 중' : '간편로그인 설정'),
        subtitle: Text(
          hasPIN ? 'PIN 번호로 앱을 잠금 해제합니다' : 'PIN 번호를 설정하면 빠르게 로그인할 수 있습니다',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: hasPIN
            ? TextButton(
                onPressed: () async {
                  await ref.read(pinNotifierProvider.notifier).disablePin();
                },
                child: const Text(
                  '해제',
                  style: TextStyle(color: AppColors.danger),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: hasPIN ? null : () => context.push('/pin-setup'),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  final AppAuthState authState;
  final WidgetRef ref;

  const _AccountSection({
    required this.authState,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (authState is AppAuthAuthenticated) {
      return ListTile(
        leading: const Icon(Icons.account_circle),
        title: const Text('로그인됨'),
        subtitle: const Text('계정으로 데이터가 동기화됩니다'),
        trailing: TextButton(
          onPressed: () {
            ref.read(authNotifierProvider.notifier).signOut();
          },
          child: const Text('로그아웃'),
        ),
      );
    } else if (authState is AppAuthLoading) {
      return const ListTile(
        leading: CircularProgressIndicator.adaptive(),
        title: Text('처리 중...'),
      );
    } else if (authState is AppAuthError) {
      final errorMessage = (authState as AppAuthError).message;
      return ListTile(
        leading: const Icon(Icons.error_outline),
        title: const Text('오류 발생'),
        subtitle: Text(errorMessage),
      );
    } else {
      // AppAuthUnauthenticated
      return ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: const Text('로그인'),
        subtitle: const Text('계정으로 데이터를 동기화하세요'),
        onTap: () => context.push('/login'),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppTextStyles.label),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}
