import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/locale_notifier.dart';
import 'package:house_money_calculator/core/settings/theme_mode_notifier.dart';
import 'package:house_money_calculator/features/settings/theme_locale_section.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

/// Hive 를 건드리지 않는 대역 notifier 들.
///
/// testWidgets 는 가상 시간(FakeAsync) 위에서 돌기 때문에 그 존 안에서 생성된
/// Hive 디스크 쓰기 Future 는 완료 콜백이 실행되지 않아 테스트가 종료되지 않는다.
/// 탭으로 유발되는 쓰기는 나중에 runAsync 로 배수하는 것도 불가능하다(실측 확인).
/// 영속화 자체는 T6/T7 의 일반 test() 가 실제 Hive 로 이미 검증하므로,
/// 이 위젯 테스트는 "탭이 notifier 에 제대로 연결되는가"만 본다.
class FakeThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  @override
  void setMode(ThemeMode mode) => state = mode;
}

class FakeLocaleNotifier extends LocaleNotifier {
  @override
  Locale? build() => null;

  @override
  void setLocale(Locale? locale) => state = locale;
}

/// `locale` 을 ko 로 고정한다. flutter_test 의 기본 기기 로케일은 en-US 이므로
/// 지정하지 않으면 영어로 해석되어 한글 기대가 전부 깨진다.
Widget wrap(Widget child) => ProviderScope(
      overrides: [
        themeModeNotifierProvider.overrideWith(FakeThemeModeNotifier.new),
        localeNotifierProvider.overrideWith(FakeLocaleNotifier.new),
      ],
      child: MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: kSupportedLocales,
        home: Scaffold(body: child),
      ),
    );

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ThemeLocaleSection)));

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('theme_locale_ui_test');
    Hive.init(tempDir.path);
    await Hive.openBox('app_settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  testWidgets('테마와 언어 항목을 표시한다', (tester) async {
    await tester.pumpWidget(wrap(const ThemeLocaleSection()));
    await tester.pumpAndSettle();

    expect(find.text('테마'), findsOneWidget);
    expect(find.text('언어'), findsOneWidget);
    expect(find.text('시스템 설정 따름'), findsNWidgets(2));
  });

  testWidgets('다크를 선택하면 테마 모드가 dark로 바뀐다', (tester) async {
    await tester.pumpWidget(wrap(const ThemeLocaleSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('테마'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다크').last);
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(themeModeNotifierProvider), ThemeMode.dark);
  });

  testWidgets('English를 선택하면 로케일이 en으로 바뀐다', (tester) async {
    await tester.pumpWidget(wrap(const ThemeLocaleSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('언어'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(localeNotifierProvider), const Locale('en'));
  });

  testWidgets('시스템 따름을 다시 고르면 로케일이 null로 돌아온다', (tester) async {
    await tester.pumpWidget(wrap(const ThemeLocaleSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('언어'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('언어'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시스템 설정 따름').last);
    await tester.pumpAndSettle();

    expect(containerOf(tester).read(localeNotifierProvider), isNull);
  });
}
