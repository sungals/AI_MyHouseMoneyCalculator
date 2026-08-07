import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/locale_notifier.dart';
import 'package:house_money_calculator/core/settings/theme_mode_notifier.dart';
import 'package:house_money_calculator/core/theme/app_palette.dart';
import 'package:house_money_calculator/core/theme/app_theme.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

/// app.dart의 MaterialApp 설정과 동일한 축소판.
Widget harness(WidgetRef ref, Widget child) {
  return MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ref.watch(themeModeNotifierProvider),
    locale: ref.watch(localeNotifierProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: kSupportedLocales,
    localeResolutionCallback: resolveLocale,
    home: child,
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_wiring_test');
    Hive.init(tempDir.path);
    await Hive.openBox('app_settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  testWidgets('테마 모드를 dark로 바꾸면 다크 팔레트가 적용된다', (tester) async {
    late BuildContext captured;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => harness(
            ref,
            Builder(builder: (c) {
              captured = c;
              return const SizedBox();
            }),
          ),
        ),
      ),
    );

    expect(captured.palette.surface, AppPalette.light.surface);

    final container =
        ProviderScope.containerOf(tester.element(find.byType(Consumer)));
    container.read(themeModeNotifierProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(captured.palette.surface, AppPalette.dark.surface);
  });

  testWidgets('로케일을 en으로 바꾸면 영어 문자열이 나온다', (tester) async {
    late BuildContext captured;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => harness(
            ref,
            Builder(builder: (c) {
              captured = c;
              return const SizedBox();
            }),
          ),
        ),
      ),
    );

    expect(AppLocalizations.of(captured).commonCancel, '취소');

    final container =
        ProviderScope.containerOf(tester.element(find.byType(Consumer)));
    container.read(localeNotifierProvider.notifier).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    expect(AppLocalizations.of(captured).commonCancel, 'Cancel');
  });
}
