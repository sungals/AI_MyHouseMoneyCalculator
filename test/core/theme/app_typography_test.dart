import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/theme/app_colors.dart';
import 'package:house_money_calculator/core/theme/app_palette.dart';
import 'package:house_money_calculator/core/theme/app_typography.dart';

void main() {
  test('팔레트의 색을 반영한다', () {
    final dark = AppTypography.fromPalette(AppPalette.dark);
    expect(dark.heading1.color, AppColors.darkTextPrimary);
    expect(dark.bodySecondary.color, AppColors.darkTextSecondary);
    expect(dark.resultAmount.color, AppColors.darkPrimary);
    expect(dark.resultAmountPositive.color, AppColors.darkPositive);
  });

  test('기존 라이트 스타일의 크기와 굵기를 그대로 유지한다', () {
    final light = AppTypography.light;
    expect(light.heading1.fontSize, 28);
    expect(light.heading1.fontWeight, FontWeight.bold);
    expect(light.heading1.letterSpacing, -0.5);
    expect(light.heading2.fontSize, 22);
    expect(light.heading2.letterSpacing, -0.3);
    expect(light.heading3.fontSize, 18);
    expect(light.heading3.fontWeight, FontWeight.w600);
    expect(light.resultAmount.fontSize, 28);
    expect(light.resultAmountPositive.color, AppColors.positive);
    expect(light.body.fontSize, 16);
    expect(light.bodySecondary.fontSize, 14);
    expect(light.label.fontWeight, FontWeight.w500);
    expect(light.caption.fontSize, 12);
    expect(light.disclaimer.height, 1.6);
  });

  test('lerp t=1이면 대상 타이포가 된다', () {
    final result = AppTypography.light.lerp(AppTypography.dark, 1.0);
    expect(result.heading1.color, AppColors.darkTextPrimary);
  });

  testWidgets('context.typography가 테마에 등록된 값을 반환한다', (tester) async {
    late AppTypography captured;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [AppTypography.dark]),
        home: Builder(
          builder: (context) {
            captured = context.typography;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(captured.body.color, AppColors.darkTextPrimary);
  });
}
