import 'package:flutter/material.dart';

import 'app_palette.dart';

/// 앱 전역 텍스트 스타일.
/// 색상이 팔레트에 의존하므로 const가 아니라 ThemeExtension으로 둔다.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle heading1;
  final TextStyle heading2;
  final TextStyle heading3;
  final TextStyle resultAmount;
  final TextStyle resultAmountPositive;
  final TextStyle body;
  final TextStyle bodySecondary;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle disclaimer;

  const AppTypography({
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.resultAmount,
    required this.resultAmountPositive,
    required this.body,
    required this.bodySecondary,
    required this.label,
    required this.caption,
    required this.disclaimer,
  });

  factory AppTypography.fromPalette(AppPalette palette) {
    return AppTypography(
      heading1: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: palette.textPrimary,
        letterSpacing: -0.5,
      ),
      heading2: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: palette.textPrimary,
        letterSpacing: -0.3,
      ),
      heading3: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      resultAmount: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: palette.primary,
        letterSpacing: -0.5,
      ),
      resultAmountPositive: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: palette.positive,
        letterSpacing: -0.5,
      ),
      body: TextStyle(fontSize: 16, color: palette.textPrimary),
      bodySecondary: TextStyle(fontSize: 14, color: palette.textSecondary),
      label: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: palette.textSecondary,
      ),
      caption: TextStyle(fontSize: 12, color: palette.textSecondary),
      disclaimer: TextStyle(
        fontSize: 12,
        color: palette.textSecondary,
        height: 1.6,
      ),
    );
  }

  static final AppTypography light = AppTypography.fromPalette(AppPalette.light);
  static final AppTypography dark = AppTypography.fromPalette(AppPalette.dark);

  @override
  AppTypography copyWith({
    TextStyle? heading1,
    TextStyle? heading2,
    TextStyle? heading3,
    TextStyle? resultAmount,
    TextStyle? resultAmountPositive,
    TextStyle? body,
    TextStyle? bodySecondary,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? disclaimer,
  }) {
    return AppTypography(
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      resultAmount: resultAmount ?? this.resultAmount,
      resultAmountPositive: resultAmountPositive ?? this.resultAmountPositive,
      body: body ?? this.body,
      bodySecondary: bodySecondary ?? this.bodySecondary,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      disclaimer: disclaimer ?? this.disclaimer,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      heading1: TextStyle.lerp(heading1, other.heading1, t)!,
      heading2: TextStyle.lerp(heading2, other.heading2, t)!,
      heading3: TextStyle.lerp(heading3, other.heading3, t)!,
      resultAmount: TextStyle.lerp(resultAmount, other.resultAmount, t)!,
      resultAmountPositive:
          TextStyle.lerp(resultAmountPositive, other.resultAmountPositive, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySecondary: TextStyle.lerp(bodySecondary, other.bodySecondary, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      disclaimer: TextStyle.lerp(disclaimer, other.disclaimer, t)!,
    );
  }
}

extension AppTypographyContext on BuildContext {
  /// 테마에 등록된 타이포그래피. 등록되지 않았으면 light로 폴백한다.
  AppTypography get typography =>
      Theme.of(this).extension<AppTypography>() ?? AppTypography.light;
}
