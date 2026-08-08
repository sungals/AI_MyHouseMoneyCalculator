import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/features/jeonse_risk/jeonse_risk_screen.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('전세사기 위험도 체크 결과와 액션을 표시한다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: JeonseRiskScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '300000000');
    await tester.enterText(find.byType(TextFormField).at(1), '280000000');
    await tester.enterText(find.byType(TextFormField).at(2), '70000000');
    await tester.ensureVisible(find.text('위험도 체크하기'));
    await tester.tap(find.text('위험도 체크하기'));
    await tester.pumpAndSettle();

    expect(find.textContaining('전세사기 위험도 높음'), findsOneWidget);
    await tester.ensureVisible(find.text('권장 조치'));
    expect(find.text('권장 조치'), findsOneWidget);
    await tester.ensureVisible(find.text('보호 절차 체크리스트'));
    expect(find.text('보호 절차 체크리스트'), findsOneWidget);
    await tester.ensureVisible(find.text('공유'));
    expect(find.text('공유'), findsOneWidget);
    expect(find.text('저장'), findsOneWidget);
    expect(find.text('PDF 내보내기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
