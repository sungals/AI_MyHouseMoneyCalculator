import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 앱 전역 시맨틱 색상.
/// Material의 ColorScheme에는 positive/warning 같은 도메인 색상 슬롯이 없어
/// ThemeExtension으로 별도 관리한다.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color positive;
  final Color warning;
  final Color danger;
  final Color divider;
  final Color cardBorder;

  const AppPalette({
    required this.primary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.positive,
    required this.warning,
    required this.danger,
    required this.divider,
    required this.cardBorder,
  });

  static const AppPalette light = AppPalette(
    primary: AppColors.primary,
    background: AppColors.background,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    positive: AppColors.positive,
    warning: AppColors.warning,
    danger: AppColors.danger,
    divider: AppColors.divider,
    cardBorder: AppColors.cardBorder,
  );

  static const AppPalette dark = AppPalette(
    primary: AppColors.darkPrimary,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    positive: AppColors.darkPositive,
    warning: AppColors.darkWarning,
    danger: AppColors.darkDanger,
    divider: AppColors.darkDivider,
    cardBorder: AppColors.darkCardBorder,
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? positive,
    Color? warning,
    Color? danger,
    Color? divider,
    Color? cardBorder,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      divider: divider ?? this.divider,
      cardBorder: cardBorder ?? this.cardBorder,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// 테마에 등록된 팔레트. 등록되지 않았으면 light로 폴백한다.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
