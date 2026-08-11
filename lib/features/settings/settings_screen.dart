import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';
import '../../core/notifications/firebase_push_service.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/auth_notifier.dart';
import '../auth/auth_state.dart';
import '../auth/pin/biometric_auth_service.dart';
import '../auth/pin/pin_notifier.dart';
import '../auth/pin/pin_state.dart';
import 'theme_locale_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final authState = ref.watch(authNotifierProvider);
    final pinState = ref.watch(pinNotifierProvider);
    final isLoggedIn = authState is AppAuthAuthenticated;
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 계정 ──────────────────────────────────
            _Label(l10n.settingsSectionAccount),
            if (isLoggedIn) ...[
              _SettingsCard(children: [
                _InfoRow(
                  icon: Icons.account_circle_outlined,
                  title: email ?? l10n.settingsSignedIn,
                ),
                const _Divider(),
                _ActionRow(
                  icon: Icons.manage_accounts_outlined,
                  title: l10n.settingsAccountManage,
                  onTap: () => context.push('/account-manage'),
                ),
              ]),
            ] else ...[
              _SettingsCard(children: [
                _ActionRow(
                  icon: Icons.login,
                  title: l10n.settingsSignIn,
                  onTap: () => context.push('/login'),
                ),
              ]),
            ],

            const SizedBox(height: 24),

            // ── 보안 (로그인 시만) ─────────────────────
            if (isLoggedIn) ...[
              _Label(l10n.settingsSectionSecurity),
              _SettingsCard(children: [
                _PinRow(pinState: pinState, ref: ref),
                if (pinState is PinEnabled) ...[
                  const _Divider(),
                  _ActionRow(
                    icon: Icons.password_outlined,
                    title: l10n.settingsPinChange,
                    onTap: () => context.push('/pin-change'),
                  ),
                  const _Divider(),
                  _ActionRow(
                    icon: Icons.fingerprint,
                    title: l10n.settingsBiometricReset,
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
              _Label(l10n.settingsSectionNotification),
              _SettingsCard(children: [
                _PushNotificationRow(ref: ref),
              ]),
              const SizedBox(height: 24),
            ],

            // ── 테마·언어 ────────────────────────────
            _Label(l10n.settingsSectionThemeLanguage),
            const _SettingsCard(children: [
              ThemeLocaleSection(),
            ]),

            const SizedBox(height: 24),

            // ── 앱 정보 ───────────────────────────────
            _Label(l10n.settingsSectionAppInfo),
            _SettingsCard(children: [
              _ActionRow(
                icon: Icons.help_outline,
                title: l10n.settingsAppGuide,
                onTap: () => context.push('/app-guide'),
              ),
              const _Divider(),
              _ActionRow(
                icon: Icons.campaign_outlined,
                title: l10n.settingsNotices,
                onTap: () => context.push('/notices'),
              ),
              const _Divider(),
              _InfoRow(
                icon: Icons.info_outline,
                title: l10n.settingsVersion,
                value: AppConstants.appVersion,
              ),
            ]),

            const SizedBox(height: 24),

            // ── 약관 ──────────────────────────────────
            _Label(l10n.settingsSectionLegal),
            _SettingsCard(children: [
              _ActionRow(
                icon: Icons.description_outlined,
                title: l10n.settingsTermsOfService,
                onTap: () => context.push('/terms'),
              ),
              const _Divider(),
              _ActionRow(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingsPrivacyPolicy,
                onTap: () => context.push('/privacy'),
              ),
              const _Divider(),
              _ActionRow(
                icon: Icons.code,
                title: l10n.settingsOpenSourceLicenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: AppConstants.appVersion,
                ),
              ),
            ]),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Text(
                l10n.sharedDisclaimerMain,
                style: context.typography.disclaimer,
              ),
            ),
            if (isLoggedIn) ...[
              const SizedBox(height: 16),
              _SettingsCard(children: [
                _ActionRow(
                  icon: Icons.logout,
                  title: l10n.settingsSignOut,
                  onTap: () => _signOut(context, ref),
                ),
              ]),
            ],
            if (email == AppConstants.adminEmail) ...[
              const SizedBox(height: 24),
              _Label(l10n.settingsSectionAdmin),
              _SettingsCard(children: [
                _ActionRow(
                  icon: Icons.admin_panel_settings_outlined,
                  title: l10n.settingsManageNotices,
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
      child: Text(text, style: context.typography.label),
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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.palette.cardBorder),
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
    final palette = context.palette;
    return ListTile(
      leading: Icon(icon, color: palette.primary, size: 22),
      title: Text(title,
          style: TextStyle(fontSize: 15, color: palette.textPrimary)),
      trailing: Icon(
        Icons.chevron_right,
        color: palette.textSecondary,
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
    final palette = context.palette;
    return ListTile(
      leading: Icon(icon, color: palette.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(fontSize: 15, color: palette.textPrimary),
      ),
      trailing: value != null
          ? Text(
              value!,
              style: TextStyle(
                fontSize: 14,
                color: palette.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            )
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
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final enabled = pinState is PinEnabled;
    return ListTile(
      leading: Icon(
        enabled ? Icons.lock : Icons.lock_open,
        color: enabled ? palette.primary : palette.textSecondary,
        size: 22,
      ),
      title: Text(
        enabled ? l10n.settingsQuickLoginEnabled : l10n.settingsQuickLoginSetup,
        style: TextStyle(fontSize: 15, color: palette.textPrimary),
      ),
      trailing: enabled
          ? TextButton(
              onPressed: () =>
                  ref.read(pinNotifierProvider.notifier).disablePin(),
              child: Text(
                l10n.settingsQuickLoginDisable,
                style: TextStyle(color: palette.danger, fontSize: 14),
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: palette.textSecondary,
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
    final palette = context.palette;
    return SwitchListTile(
      secondary: Icon(
        Icons.screen_lock_portrait,
        color: palette.primary,
        size: 22,
      ),
      title: Text(
        AppLocalizations.of(context).settingsRequireAuthOnLaunch,
        style: TextStyle(fontSize: 15, color: palette.textPrimary),
      ),
      value: pinState.requireAuthOnLaunch,
      onChanged: (v) =>
          ref.read(pinNotifierProvider.notifier).setRequireAuthOnLaunch(v),
      activeColor: palette.primary,
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
    final palette = context.palette;
    return SwitchListTile(
      secondary: _saving
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.notifications_active_outlined,
              color: palette.primary,
              size: 22,
            ),
      title: Text(
        AppLocalizations.of(context).settingsNoticePush,
        style: TextStyle(fontSize: 15, color: palette.textPrimary),
      ),
      value: _enabled,
      onChanged: _saving ? null : _toggle,
      activeColor: palette.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}
