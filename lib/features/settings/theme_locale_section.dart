import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/locale_notifier.dart';
import '../../core/settings/theme_mode_notifier.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/gen/app_localizations.dart';

class ThemeLocaleSection extends ConsumerWidget {
  const ThemeLocaleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text(
            l10n.settingsThemeLabel,
            style: TextStyle(fontSize: 15, color: context.palette.textPrimary),
          ),
          trailing: Text(
            _themeLabel(l10n, themeMode),
            style: TextStyle(color: context.palette.textSecondary),
          ),
          onTap: () => _pickTheme(context, ref, themeMode),
        ),
        ListTile(
          title: Text(
            l10n.settingsLanguageLabel,
            style: TextStyle(fontSize: 15, color: context.palette.textPrimary),
          ),
          trailing: Text(
            _localeLabel(l10n, locale),
            style: TextStyle(color: context.palette.textSecondary),
          ),
          onTap: () => _pickLocale(context, ref, locale),
        ),
      ],
    );
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.system => l10n.settingsThemeSystem,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.dark => l10n.settingsThemeDark,
      };

  String _localeLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return l10n.settingsLanguageSystem;
    return locale.languageCode == 'en'
        ? l10n.settingsLanguageEnglish
        : l10n.settingsLanguageKorean;
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: current,
                title: Text(_themeLabel(l10n, mode)),
                onChanged: (value) => Navigator.of(sheetContext).pop(value),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      ref.read(themeModeNotifierProvider.notifier).setMode(selected);
    }
  }

  Future<void> _pickLocale(
    BuildContext context,
    WidgetRef ref,
    Locale? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    const options = <Locale?>[null, Locale('ko'), Locale('en')];

    final selected = await showModalBottomSheet<_LocaleChoice>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              RadioListTile<Locale?>(
                value: option,
                groupValue: current,
                title: Text(_localeLabel(l10n, option)),
                onChanged: (value) =>
                    Navigator.of(sheetContext).pop(_LocaleChoice(value)),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      ref.read(localeNotifierProvider.notifier).setLocale(selected.value);
    }
  }
}

/// null(시스템 따름) 선택과 "시트를 그냥 닫음"을 구분하기 위한 래퍼.
class _LocaleChoice {
  final Locale? value;
  const _LocaleChoice(this.value);
}
