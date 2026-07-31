import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/theme/app_colors.dart';

/// WCAG 2.1 상대 휘도.
double _luminance(Color c) {
  double channel(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.red) + 0.7152 * channel(c.green) + 0.0722 * channel(c.blue);
}

double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('다크 팔레트 WCAG AA', () {
    test('본문 텍스트는 배경 대비 4.5:1 이상이다', () {
      expect(contrastRatio(AppColors.darkTextPrimary, AppColors.darkBackground),
          greaterThanOrEqualTo(4.5));
      expect(contrastRatio(AppColors.darkTextPrimary, AppColors.darkSurface),
          greaterThanOrEqualTo(4.5));
    });

    test('보조 텍스트는 배경 대비 4.5:1 이상이다', () {
      expect(contrastRatio(AppColors.darkTextSecondary, AppColors.darkBackground),
          greaterThanOrEqualTo(4.5));
      expect(contrastRatio(AppColors.darkTextSecondary, AppColors.darkSurface),
          greaterThanOrEqualTo(4.5));
    });

    test('상태 색상은 surface 대비 3:1 이상이다', () {
      for (final c in [
        AppColors.darkPrimary,
        AppColors.darkPositive,
        AppColors.darkWarning,
        AppColors.darkDanger,
      ]) {
        expect(contrastRatio(c, AppColors.darkSurface), greaterThanOrEqualTo(3.0));
      }
    });

    test('라이트 팔레트도 동일 기준을 지킨다', () {
      expect(contrastRatio(AppColors.textPrimary, AppColors.background),
          greaterThanOrEqualTo(4.5));
      expect(contrastRatio(AppColors.textSecondary, AppColors.surface),
          greaterThanOrEqualTo(4.5));
    });
  });
}
