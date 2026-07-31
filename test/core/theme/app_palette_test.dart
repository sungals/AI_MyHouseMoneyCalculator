import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/theme/app_colors.dart';
import 'package:house_money_calculator/core/theme/app_palette.dart';

void main() {
  test('light 인스턴스는 라이트 색상을 담는다', () {
    expect(AppPalette.light.textPrimary, AppColors.textPrimary);
    expect(AppPalette.light.surface, AppColors.surface);
  });

  test('dark 인스턴스는 다크 색상을 담는다', () {
    expect(AppPalette.dark.textPrimary, AppColors.darkTextPrimary);
    expect(AppPalette.dark.surface, AppColors.darkSurface);
  });

  test('copyWith는 지정한 필드만 바꾼다', () {
    final changed = AppPalette.light.copyWith(primary: const Color(0xFF000000));
    expect(changed.primary, const Color(0xFF000000));
    expect(changed.surface, AppPalette.light.surface);
  });

  test('lerp t=1이면 대상 팔레트가 된다', () {
    final result = AppPalette.light.lerp(AppPalette.dark, 1.0);
    expect(result.surface, AppPalette.dark.surface);
  });

  test('lerp에 다른 타입이 오면 자기 자신을 반환한다', () {
    expect(AppPalette.light.lerp(null, 0.5), AppPalette.light);
  });

  testWidgets('context.palette가 테마에 등록된 팔레트를 반환한다', (tester) async {
    late AppPalette captured;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.dark]),
        home: Builder(
          builder: (context) {
            captured = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(captured.surface, AppColors.darkSurface);
  });

  testWidgets('팔레트가 등록되지 않았으면 light로 폴백한다', (tester) async {
    late AppPalette captured;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            captured = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(captured.surface, AppColors.surface);
  });
}
