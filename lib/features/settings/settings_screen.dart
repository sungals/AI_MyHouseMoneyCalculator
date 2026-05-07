import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
              if (pinState is PinEnabled) ...[
                const SizedBox(height: 12),
                _RequireAuthOnLaunchTile(pinState: pinState, ref: ref),
              ],
            ],
            const SizedBox(height: 24),
            const _SectionHeader('앱 정보'),
            _SettingsActionTile(
              icon: Icons.campaign_outlined,
              title: '공지사항',
              subtitle: '서비스 안내와 업데이트 소식을 확인합니다',
              onTap: () => context.push('/notices'),
            ),
            const _InfoTile(label: '앱 이름', value: AppConstants.appName),
            const _InfoTile(label: '버전', value: '1.0.0'),
            const SizedBox(height: 24),
            const _SectionHeader('법적 고지'),
            _SettingsActionTile(
              icon: Icons.description_outlined,
              title: '이용약관',
              subtitle: '서비스 이용 조건과 책임 범위를 확인합니다',
              onTap: () => context.push('/terms'),
            ),
            _SettingsActionTile(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 처리방침',
              subtitle: '수집 정보와 이용 목적을 확인합니다',
              onTap: () => context.push('/privacy'),
            ),
            _SettingsActionTile(
              icon: Icons.code,
              title: '오픈소스 라이선스',
              subtitle: '앱에서 사용하는 오픈소스 정보를 확인합니다',
              onTap: () => showLicensePage(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: '1.0.0',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(DisclaimerTexts.main,
                  style: AppTextStyles.disclaimer),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _RequireAuthOnLaunchTile extends StatelessWidget {
  final PinEnabled pinState;
  final WidgetRef ref;

  const _RequireAuthOnLaunchTile({
    required this.pinState,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
      ),
      child: SwitchListTile(
        value: pinState.requireAuthOnLaunch,
        onChanged: (value) {
          ref.read(pinNotifierProvider.notifier).setRequireAuthOnLaunch(value);
        },
        secondary: const Icon(
          Icons.screen_lock_portrait,
          color: AppColors.primary,
        ),
        title: const Text('앱 재진입 시 인증'),
        subtitle: const Text(
          '앱을 종료한 뒤 다시 열 때 PIN 또는 생체인증을 요구합니다',
          style: TextStyle(fontSize: 12),
        ),
        activeColor: AppColors.primary,
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
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: InkRipple.splashFactory,
          splashColor: const Color(0x661F4FFF),
          highlightColor: const Color(0x991F4FFF),
        ),
        child: ListTile(
          onTap: hasPIN ? null : () => context.push('/pin-setup'),
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
        ),
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
          onPressed: () async {
            final box = Hive.box('app_settings');
            await box.put('login_skipped', false);
            await ref.read(authNotifierProvider.notifier).signOut();
            if (context.mounted) {
              context.go('/login');
            }
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
