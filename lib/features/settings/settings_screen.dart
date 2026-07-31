import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/disclaimer_texts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/notifications/firebase_push_service.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../auth/pin/biometric_auth_service.dart';
import '../auth/pin/pin_notifier.dart';
import '../auth/pin/pin_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final pinState = ref.watch(pinNotifierProvider);
    final isLoggedIn = authState is AppAuthAuthenticated;
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 계정 ──────────────────────────────────
            const _Label('계정'),
            if (isLoggedIn) ...[
              _SettingsCard(children: [
                _InfoRow(
                  icon: Icons.account_circle_outlined,
                  title: email ?? '로그인됨',
                ),
                const _Divider(),
                _ActionRow(
                  icon: Icons.manage_accounts_outlined,
                  title: '계정 관리',
                  onTap: () => context.push('/account-manage'),
                ),
              ]),
            ] else ...[
              _SettingsCard(children: [
                _ActionRow(
                  icon: Icons.login,
                  title: '로그인',
                  onTap: () => context.push('/login'),
                ),
              ]),
            ],

            const SizedBox(height: 24),

            // ── 보안 (로그인 시만) ─────────────────────
            if (isLoggedIn) ...[
              const _Label('보안'),
              _SettingsCard(children: [
                _PinRow(pinState: pinState, ref: ref),
                if (pinState is PinEnabled) ...[
                  const _Divider(),
                  _ActionRow(
                    icon: Icons.password_outlined,
                    title: 'PIN 변경',
                    onTap: () => context.push('/pin-change'),
                  ),
                  const _Divider(),
                  _ActionRow(
                    icon: Icons.fingerprint,
                    title: '생체인증 재설정',
                    onTap: () async {
                      await ref.read(biometricAuthServiceProvider).disable();
                      if (context.mounted) context.push('/biometric-setup');
                    },
                  ),
                  const _Divider(),
                  _RequireAuthRow(pinState: pinState, ref: ref),
                ],
              ]),
              const SizedBox(height: 24),

              // ── 알림 ──────────────────────────────────
              const _Label('알림'),
              _SettingsCard(children: [
                _PushNotificationRow(ref: ref),
              ]),
              const SizedBox(height: 24),
            ],

            // ── 앱 정보 ───────────────────────────────
            const _Label('앱 정보'),
            _SettingsCard(children: [
              _ActionRow(
                icon: Icons.help_outline,
                title: '앱 사용법',
                onTap: () => context.push('/app-guide'),
              ),
              const _Divider(),
              _ActionRow(
                icon: Icons.campaign_outlined,
                title: '공지사항',
                onTap: () => context.push('/notices'),
              ),
              const _Divider(),
              const _InfoRow(
                icon: Icons.info_outline,
                title: '버전',
                value: AppConstants.appVersion,
              ),
            ]),

            const SizedBox(height: 24),

            // ── 약관 ──────────────────────────────────
            const _Label('약관'),
            _SettingsCard(children: [
              _ActionRow(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () => context.push('/terms'),
              ),
              const _Divider(),
              _ActionRow(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 처리방침',
                onTap: () => context.push('/privacy'),
              ),
              const _Divider(),
              _ActionRow(
                icon: Icons.code,
                title: '오픈소스 라이선스',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                ),
              ),
            ]),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                DisclaimerTexts.main,
                style: AppTextStyles.disclaimer,
              ),
            ),
            if (isLoggedIn) ...[
              const SizedBox(height: 16),
              _SettingsCard(children: [
                _ActionRow(
                  icon: Icons.logout,
                  title: '로그아웃',
                  onTap: () => _signOut(context, ref),
                ),
              ]),
            ],
            if (email == AppConstants.adminEmail) ...[
              const SizedBox(height: 24),
              const _Label('관리자'),
              _SettingsCard(children: [
                _ActionRow(
                  icon: Icons.admin_panel_settings_outlined,
                  title: '공지사항 관리',
                  onTap: () => context.push('/admin/notices'),
                ),
              ]),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final box = Hive.box('app_settings');
    await box.put('login_skipped', false);
    await ref.read(authNotifierProvider.notifier).signOut();
    if (context.mounted) context.go('/login');
  }

}

// ─── Layout helpers ───────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: AppTextStyles.label),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 52, endIndent: 0);
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ─── Row types ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;

  const _InfoRow({required this.icon, required this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: value != null
          ? Text(value!, style: AppTextStyles.bodySecondary)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}

// ─── Stateful / stateless rows ───────────────────────────────────────────────

class _PinRow extends StatelessWidget {
  final PinState pinState;
  final WidgetRef ref;
  const _PinRow({required this.pinState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final enabled = pinState is PinEnabled;
    return ListTile(
      leading: Icon(
        enabled ? Icons.lock : Icons.lock_open,
        color: enabled ? AppColors.primary : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        enabled ? '간편로그인 사용 중' : '간편로그인 설정',
        style: const TextStyle(fontSize: 15),
      ),
      trailing: enabled
          ? TextButton(
              onPressed: () =>
                  ref.read(pinNotifierProvider.notifier).disablePin(),
              child: const Text(
                '해제',
                style: TextStyle(color: AppColors.danger, fontSize: 14),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
      onTap: enabled ? null : () => context.push('/pin-setup'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RequireAuthRow extends StatelessWidget {
  final PinEnabled pinState;
  final WidgetRef ref;
  const _RequireAuthRow({required this.pinState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(
        Icons.screen_lock_portrait,
        color: AppColors.primary,
        size: 22,
      ),
      title: const Text('앱 재진입 시 인증', style: TextStyle(fontSize: 15)),
      value: pinState.requireAuthOnLaunch,
      onChanged: (v) =>
          ref.read(pinNotifierProvider.notifier).setRequireAuthOnLaunch(v),
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PushNotificationRow extends StatefulWidget {
  final WidgetRef ref;
  const _PushNotificationRow({required this.ref});

  @override
  State<_PushNotificationRow> createState() => _PushNotificationRowState();
}

class _PushNotificationRowState extends State<_PushNotificationRow> {
  late bool _enabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _enabled = FirebasePushService.isNoticePushEnabled;
  }

  Future<void> _toggle(bool value) async {
    setState(() {
      _enabled = value;
      _saving = true;
    });
    await widget.ref
        .read(firebasePushServiceProvider)
        .setNoticePushEnabled(value);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: _saving
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 22,
            ),
      title: const Text('공지 알림', style: TextStyle(fontSize: 15)),
      value: _enabled,
      onChanged: _saving ? null : _toggle,
      activeColor: AppColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}
