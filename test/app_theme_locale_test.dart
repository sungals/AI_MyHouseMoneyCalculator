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
///
/// 실제 `App`은 Firebase 초기화와 라우터에 의존해 위젯 테스트로 띄울 수 없어서
/// 같은 설정을 조립해 배선 규칙만 검증한다. 따라서 이 테스트는 app.dart 자체의
/// 오배선은 잡지 못한다 — app.dart를 고칠 때는 눈으로 대조할 것.
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

/// 설정 변경을 실제 이벤트 루프에서 수행한다.
///
/// `testWidgets`는 가상 시간(FakeAsync) 위에서 돌기 때문에, 그 안에서 만들어진
/// Hive의 디스크 쓰기 Future는 완료 콜백이 가상 존에 묶여 영영 실행되지 않는다.
/// 그러면 테스트가 종료되지 않고 매달린다. 상태 변경과 flush를 함께
/// `runAsync` 안에서 수행해야 Future가 실제 존에서 생성·완료된다.
Future<void> applySetting(
  WidgetTester tester,
  void Function() change,
) async {
  await tester.runAsync(() async {
    change();
    await Hive.box('app_settings').flush();
  });
  // 첫 pump는 리빌드를, 두 번째 pump는 테마 전환 애니메이션을 끝낸다.
  // 하나로 합치면 애니메이션이 시작만 되고 진행되지 않는다.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
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

  Future<BuildContext> pumpHarness(WidgetTester tester) async {
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
    return captured;
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(Consumer)));

  testWidgets('기본값은 라이트 팔레트다', (tester) async {
    final context = await pumpHarness(tester);

    expect(context.palette.surface, AppPalette.light.surface);
  });

  testWidgets('테마 모드를 dark로 바꾸면 다크 팔레트가 적용되고 저장된다', (tester) async {
    final context = await pumpHarness(tester);
    final container = containerOf(tester);

    await applySetting(
      tester,
      () => container
          .read(themeModeNotifierProvider.notifier)
          .setMode(ThemeMode.dark),
    );

    expect(context.palette.surface, AppPalette.dark.surface);
    expect(Hive.box('app_settings').get(kThemeModeKey), 'dark');
  });

  testWidgets('테마 모드를 light로 되돌리면 라이트 팔레트로 돌아온다', (tester) async {
    final context = await pumpHarness(tester);
    final container = containerOf(tester);
    final notifier = container.read(themeModeNotifierProvider.notifier);

    await applySetting(tester, () => notifier.setMode(ThemeMode.dark));
    await applySetting(tester, () => notifier.setMode(ThemeMode.light));

    expect(context.palette.surface, AppPalette.light.surface);
    expect(Hive.box('app_settings').get(kThemeModeKey), 'light');
  });

  testWidgets('로케일을 ko로 바꾸면 한국어 문자열이 나온다', (tester) async {
    final context = await pumpHarness(tester);
    final container = containerOf(tester);

    await applySetting(
      tester,
      () => container
          .read(localeNotifierProvider.notifier)
          .setLocale(const Locale('ko')),
    );

    expect(AppLocalizations.of(context).commonCancel, '취소');
    expect(Hive.box('app_settings').get(kLocaleKey), 'ko');
  });

  testWidgets('로케일을 en으로 바꾸면 영어 문자열이 나온다', (tester) async {
    final context = await pumpHarness(tester);
    final container = containerOf(tester);

    await applySetting(
      tester,
      () => container
          .read(localeNotifierProvider.notifier)
          .setLocale(const Locale('en')),
    );

    expect(AppLocalizations.of(context).commonCancel, 'Cancel');
    expect(Hive.box('app_settings').get(kLocaleKey), 'en');
  });
}
