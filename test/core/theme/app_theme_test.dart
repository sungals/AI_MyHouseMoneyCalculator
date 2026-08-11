import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/theme/app_palette.dart';
import 'package:house_money_calculator/core/theme/app_theme.dart';
import 'package:house_money_calculator/core/theme/app_typography.dart';

void main() {
  test('light 테마에 팔레트와 타이포가 등록된다', () {
    final theme = AppTheme.light;
    expect(theme.extension<AppPalette>(), AppPalette.light);
    expect(theme.extension<AppTypography>(), isNotNull);
    expect(theme.brightness, Brightness.light);
  });

  test('dark 테마에 다크 팔레트와 타이포가 등록된다', () {
    final theme = AppTheme.dark;
    expect(theme.extension<AppPalette>(), AppPalette.dark);
    expect(theme.extension<AppTypography>(), isNotNull);
    expect(theme.brightness, Brightness.dark);
  });

  test('dark 테마의 scaffold 배경은 다크 배경색이다', () {
    expect(AppTheme.dark.scaffoldBackgroundColor, AppPalette.dark.background);
  });

  test('dark 테마의 리스트 텍스트는 본문색을 사용한다', () {
    final theme = AppTheme.dark;
    expect(theme.listTileTheme.textColor, AppPalette.dark.textPrimary);
    expect(
        theme.listTileTheme.titleTextStyle?.color, AppPalette.dark.textPrimary);
    expect(theme.listTileTheme.leadingAndTrailingTextStyle?.color,
        AppPalette.dark.textPrimary);
  });

  test('light 테마의 시각 속성은 기존과 동일하다', () {
    final theme = AppTheme.light;
    expect(theme.useMaterial3, isTrue);
    expect(theme.scaffoldBackgroundColor, AppPalette.light.background);
    expect(theme.appBarTheme.elevation, 0);
    expect(theme.appBarTheme.scrolledUnderElevation, 1);
    expect(theme.appBarTheme.centerTitle, isFalse);
  });
}
