import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

/// 라이트 색이 고정된 구형 텍스트 스타일.
///
/// 테마를 따라가지 못하므로 `context.typography`로 옮겨야 한다.
/// 아직 옮기지 않은 호출부는 다크모드에서도 라이트 색을 쓴다 —
/// 컴파일 에러가 아니라 조용히 틀리므로, 남은 호출부는
/// deprecation 경고와 `tool/check_hardcoded.sh`로 추적한다.
/// Phase 1에서 모든 호출부를 옮긴 뒤 이 파일을 삭제한다.
@Deprecated('context.typography를 사용하세요. Phase 1 완료 후 제거됩니다.')
class AppTextStyles {
  AppTextStyles._();

  static AppTypography get _t => AppTypography.fromPalette(AppPalette.light);

  static TextStyle get heading1 => _t.heading1;
  static TextStyle get heading2 => _t.heading2;
  static TextStyle get heading3 => _t.heading3;
  static TextStyle get resultAmount => _t.resultAmount;
  static TextStyle get resultAmountPositive => _t.resultAmountPositive;
  static TextStyle get body => _t.body;
  static TextStyle get bodySecondary => _t.bodySecondary;
  static TextStyle get label => _t.label;
  static TextStyle get caption => _t.caption;
  static TextStyle get disclaimer => _t.disclaimer;
}
