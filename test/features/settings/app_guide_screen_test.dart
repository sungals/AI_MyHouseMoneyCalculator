import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/features/settings/app_guide_screen.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

/// 페이지 목록을 initState 가 아니라 build 에서 만들도록 바꿨다.
/// 이 테스트는 그 전환이 (1) 로케일을 반영하고 (2) 언어를 바꾸면 다시 그리는지를
/// 고정한다. initState 로 되돌아가면 두 번째 기대가 깨진다.
Widget wrap(Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppGuideScreen(),
    );

void main() {
  testWidgets('ko 로케일에서 한국어 제목과 첫 페이지를 그린다', (tester) async {
    await tester.pumpWidget(wrap(const Locale('ko')));
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('ko'));
    expect(find.text(l10n.guideTitle), findsOneWidget);
    expect(find.text(l10n.guideIntroTagline), findsOneWidget);
    expect(find.text(l10n.guideFlowStep1Title), findsOneWidget);
  });

  testWidgets('en 로케일에서 영어 문구를 그린다', (tester) async {
    await tester.pumpWidget(wrap(const Locale('en')));
    await tester.pumpAndSettle();

    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ko = await AppLocalizations.delegate.load(const Locale('ko'));
    expect(find.text(en.guideTitle), findsOneWidget);
    expect(find.text(ko.guideTitle), findsNothing);
  });

  testWidgets('로케일을 바꾸면 페이지 내용이 다시 만들어진다', (tester) async {
    await tester.pumpWidget(wrap(const Locale('ko')));
    await tester.pumpAndSettle();

    final ko = await AppLocalizations.delegate.load(const Locale('ko'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(ko.guideIntroTagline), findsOneWidget);

    await tester.pumpWidget(wrap(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text(en.guideIntroTagline), findsOneWidget);
    expect(find.text(ko.guideIntroTagline), findsNothing);
  });

  testWidgets('다크 테마에서도 예외 없이 그린다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.dark(),
      home: const AppGuideScreen(),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
