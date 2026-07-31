# 다크모드 + 다국어 Phase 0 (기반) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 다크모드와 ko/en 다국어의 기반 API·배선·도메인 구조를 완성하여, 이후 10개 슬라이스가 병렬로 작업할 수 있는 토대를 만든다.

**Architecture:** 색상과 타이포그래피를 `ThemeExtension`으로 전환해 `context.palette.*` / `context.typography.*` 단일 치환 패턴을 확립한다. i18n은 Flutter 공식 `gen_l10n`(ARB)을 쓰고, 슬라이스별 ARB 프래그먼트를 병합하는 도구를 함께 만든다. 도메인 계산기가 반환하던 한글 문자열은 enum 코드로 바꾸고 표현 계층이 지역화를 담당한다.

**Tech Stack:** Flutter (Dart SDK `^3.5.1`), `flutter_localizations`(SDK), `intl ^0.19.0`(기존), `flutter_riverpod ^2.5.1`(기존), Hive(기존)

**설계 근거:** `docs/superpowers/specs/2026-07-31-darkmode-i18n-design.md`

## Global Constraints

- **Dart 패키지명은 `house_money_calculator`다.** 모든 import는 `package:house_money_calculator/...` 형태여야 한다. (`my_house_money_calculator`가 아니다.)
- **모든 커밋에서 `flutter analyze`의 error가 0이어야 하고 앱이 빌드되어야 한다.** Phase 0은 그 자체로 독립 검증 가능한 산출물이다. 기존 API를 제거해 호출부를 깨뜨리는 대신 `@Deprecated` shim으로 병존시키고, 실제 제거는 Phase 1이 모든 호출부를 옮긴 뒤에 한다. 전환 누락을 잡는 강제력은 컴파일 에러가 아니라 **deprecation 경고 수 + `tool/check_hardcoded.sh`의 exit 1**이 담당한다.
- 지원 로케일은 `ko`, `en` 두 개뿐이다. 템플릿은 `app_ko.arb`.
- `lib/core/constants/legal_texts.dart`는 **수정 금지**. 약관 원문은 한국어를 유지한다.
- `lib/data/models/calculation_history.dart`의 **저장 값 포맷을 변경하지 않는다.** 사용자 기기에 이미 저장된 이력이 깨진다. 지역화는 표시 시점에만 한다.
- `MoneyFormatter`의 **ko 출력은 현행과 문자 단위로 동일해야 한다.** 기존 `test/core/utils/money_formatter_test.dart`가 이를 보호한다.
- en 금액 출력에 억/만 단위를 쓰지 않는다. 서구식 K/M/B 단위를 쓴다. 통화는 KRW 고정, 환율 변환 없음.
- ARB 키는 `common` 또는 feature 이름으로 시작하는 camelCase여야 한다. 예: `commonCancel`, `settingsThemeLabel`.
- 다크 팔레트는 WCAG AA(본문 4.5:1, 큰 텍스트 3:1)를 충족해야 한다.
- `AppColors`의 시맨틱 이름 10개(`primary` `background` `surface` `textPrimary` `textSecondary` `positive` `warning` `danger` `divider` `cardBorder`)를 유지한다. 이름을 바꾸면 슬라이스 치환이 기계적이지 않게 된다.
- Riverpod 패턴을 따른다. 새 상태는 `flutter_riverpod`로 만든다.
- 각 태스크 끝에 커밋한다.

---

## File Structure

**신규 생성**

| 파일 | 책임 |
|---|---|
| `lib/core/theme/app_palette.dart` | `ThemeExtension<AppPalette>` — 10개 시맨틱 색상, light/dark 인스턴스, `context.palette` |
| `lib/core/theme/app_typography.dart` | `ThemeExtension<AppTypography>` — 10개 TextStyle, `context.typography` |
| `lib/core/settings/theme_mode_notifier.dart` | 테마 모드 상태 + Hive 영속화 |
| `lib/core/settings/locale_notifier.dart` | 로케일 상태 + Hive 영속화 |
| `lib/core/utils/money_format_style.dart` | 로케일별 금액 포맷 전략 |
| `lib/core/utils/validation_error.dart` | 입력 검증 실패 코드 |
| `lib/domain/entities/jeonse_risk_codes.dart` | 전세위험 경고/체크/조치 enum |
| `lib/features/settings/theme_locale_section.dart` | 설정 화면의 테마·언어 선택 UI |
| `l10n.yaml` | gen_l10n 설정 |
| `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb` | 베이스 ARB (`common*` + 설정 화면 키) |
| `tool/merge_arb.dart` | 슬라이스 프래그먼트 병합기 |
| `tool/check_hardcoded.sh` | 잔여 스캔 |
| `docs/superpowers/specs/2026-07-31-slice-contract.md` | 슬라이스 계약서 |

**수정**

| 파일 | 변경 |
|---|---|
| `lib/core/theme/app_colors.dart` | dark 색상 세트 추가 |
| `lib/core/theme/app_theme.dart` | `dark` 게터 추가, extension 등록 |
| `lib/core/theme/app_text_styles.dart` | `@Deprecated` shim으로 축소 — `AppTypography.light`에 위임. 제거는 Phase 1 |
| `lib/app.dart` | `darkTheme`/`themeMode`/`locale`/delegates/`onGenerateTitle` |
| `lib/core/utils/money_formatter.dart` | 로케일 분기 |
| `lib/core/utils/validators.dart` | `*Code` enum 반환 메서드 추가. 기존 String 반환 메서드는 `@Deprecated`로 유지 |
| `lib/core/utils/calculation_pdf_exporter.dart` | 지역화 문자열 주입 시그니처 |
| `lib/domain/entities/jeonse_risk_result.dart` | String 필드 → enum 리스트 |
| `lib/domain/calculators/*.dart` (6개) | 한글 반환 제거 |
| `lib/features/settings/settings_screen.dart` | 테마·언어 섹션 삽입 |
| `pubspec.yaml` | `flutter_localizations`, `generate: true` |

**기존 테스트 중 한글 문자열에 의존하여 이 작업으로 깨지는 것**

Task 12·13에서 함께 고친다: `jeonse_risk_calculator_test.dart`(한글 2) · `rent_compare_calculator_test.dart`(22) · `semi_rent_calculator_test.dart`(9) · `monthly_expense_calculator_test.dart`(6) · `loan_interest_calculator_test.dart`(6) · `contract_renewal_calculator_test.dart`(1)

Phase 1로 넘긴다 (화면 문자열이 ARB로 옮겨간 뒤에야 고칠 수 있음): `jeonse_risk_screen_test.dart`(12) · `home_screen_test.dart`(10)

**변경하지 않는다** — 이들이 계속 통과하는 것이 곧 회귀 방지다: `money_formatter_test.dart`(ko 출력 불변 보증) · `calculation_history_test.dart` · `calculation_history_repository_test.dart` · `calculation_history_remote_store_test.dart`(저장 포맷 불변 보증) · `auth_notifier_test.dart` · `acquisition_tax_calculator_test.dart` · `dsr_dti_calculator_test.dart` · `brokerage_fee_calculator_test.dart`

---

## Task 1: 다크 색상 세트와 대비 검증

**Files:**
- Modify: `lib/core/theme/app_colors.dart`
- Test: `test/core/theme/app_colors_contrast_test.dart`

**Interfaces:**
- Consumes: 없음 (첫 태스크)
- Produces: `AppColors`에 `static const Color` 10개 추가 — `darkPrimary`, `darkBackground`, `darkSurface`, `darkTextPrimary`, `darkTextSecondary`, `darkPositive`, `darkWarning`, `darkDanger`, `darkDivider`, `darkCardBorder`

- [ ] **Step 1: 대비 검증 실패 테스트 작성**

`test/core/theme/app_colors_contrast_test.dart`:

```dart
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
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/theme/app_colors_contrast_test.dart`
Expected: FAIL — `AppColors.darkTextPrimary` 등이 정의되지 않아 컴파일 에러

- [ ] **Step 3: 다크 색상 추가**

`lib/core/theme/app_colors.dart`의 클래스 본문 끝(`cardBorder` 다음)에 추가:

```dart

  // Dark
  static const Color darkPrimary = Color(0xFF7C9CFF);
  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF181B21);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkPositive = Color(0xFF4ADE80);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkDanger = Color(0xFFF87171);
  static const Color darkDivider = Color(0xFF2A2F3A);
  static const Color darkCardBorder = Color(0xFF232833);
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/core/theme/app_colors_contrast_test.dart`
Expected: PASS

실패하는 항목이 있으면 **테스트가 아니라 색상 값을 조정한다.** 텍스트가 미달이면 더 밝게, 상태 색이 미달이면 채도를 낮추고 밝기를 올린다.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/theme/app_colors.dart test/core/theme/app_colors_contrast_test.dart
git commit -m "feat: 다크 팔레트 색상 정의 및 WCAG AA 대비 검증 테스트 추가"
```

---

## Task 2: AppPalette ThemeExtension

**Files:**
- Create: `lib/core/theme/app_palette.dart`
- Test: `test/core/theme/app_palette_test.dart`

**Interfaces:**
- Consumes: Task 1의 `AppColors.dark*`
- Produces:
  - `class AppPalette extends ThemeExtension<AppPalette>` — `final Color` 필드 10개: `primary` `background` `surface` `textPrimary` `textSecondary` `positive` `warning` `danger` `divider` `cardBorder`
  - `static const AppPalette light`, `static const AppPalette dark`
  - `AppPalette copyWith({...})`, `AppPalette lerp(ThemeExtension<AppPalette>? other, double t)`
  - `extension AppPaletteContext on BuildContext { AppPalette get palette; }`

- [ ] **Step 1: 실패 테스트 작성**

`test/core/theme/app_palette_test.dart`:

```dart
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
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/theme/app_palette_test.dart`
Expected: FAIL — `app_palette.dart`가 없어 컴파일 에러

- [ ] **Step 3: 구현**

`lib/core/theme/app_palette.dart`:

```dart
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
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/core/theme/app_palette_test.dart`
Expected: PASS (7개 테스트)

- [ ] **Step 5: 커밋**

```bash
git add lib/core/theme/app_palette.dart test/core/theme/app_palette_test.dart
git commit -m "feat: AppPalette ThemeExtension 추가"
```

---

## Task 3: AppTypography ThemeExtension

**Files:**
- Create: `lib/core/theme/app_typography.dart`
- Modify: `lib/core/theme/app_text_styles.dart` (`@Deprecated` shim으로 축소)
- Test: `test/core/theme/app_typography_test.dart`

**Interfaces:**
- Consumes: Task 2의 `AppPalette`
- Produces:
  - `class AppTypography extends ThemeExtension<AppTypography>` — `TextStyle` 필드 10개: `heading1` `heading2` `heading3` `resultAmount` `resultAmountPositive` `body` `bodySecondary` `label` `caption` `disclaimer`
  - `factory AppTypography.fromPalette(AppPalette palette)`
  - `static final AppTypography light`, `static final AppTypography dark`
  - `extension AppTypographyContext on BuildContext { AppTypography get typography; }`

`AppTextStyles`의 `static const TextStyle`은 색이 박제되어 테마를 따라갈 수 없다. 다만 **이 태스크에서 삭제하지 않는다** — 135곳의 호출부가 한꺼번에 깨지고 앱이 빌드되지 않기 때문이다. 대신 `AppTypography.light`에 위임하는 `@Deprecated` shim으로 축소한다.

shim 구간의 동작을 정확히 알고 가야 한다. **아직 전환되지 않은 호출부는 다크모드에서 라이트 색을 쓴다** — 컴파일 에러로 터지지 않고 조용히 틀린다. 이를 잡는 강제력은 두 가지다.

1. `flutter analyze`의 deprecation 경고 — 남은 호출부 수가 그대로 드러난다
2. `tool/check_hardcoded.sh` (Task 16) — `AppTextStyles.` 참조가 1건이라도 있으면 exit 1

Phase 1이 135곳을 모두 옮긴 뒤 `app_text_styles.dart`를 삭제한다.

- [ ] **Step 1: 실패 테스트 작성**

`test/core/theme/app_typography_test.dart`:

```dart
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
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/theme/app_typography_test.dart`
Expected: FAIL — `app_typography.dart` 없음

- [ ] **Step 3: 구현**

`lib/core/theme/app_typography.dart`:

```dart
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
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/core/theme/app_typography_test.dart`
Expected: PASS (4개 테스트)

- [ ] **Step 5: `app_text_styles.dart`를 shim으로 축소**

전체 교체한다. 스타일 값은 `AppTypography.light`가 이미 갖고 있으므로 중복 정의하지 않고 위임한다.

```dart
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
```

`const`에서 `get`으로 바뀌므로 호출부가 `const` 컨텍스트에서 쓰고 있었다면 그 부분만 `const`를 떼야 한다. `flutter analyze`가 정확한 위치를 알려준다.

- [ ] **Step 6: 빌드가 유지되는지 확인**

```bash
flutter analyze 2>&1 | grep -E "^\s*error" | head -20
```

Expected: **출력 없음.** error가 하나라도 있으면 shim이 제 역할을 못 한 것이므로 먼저 고친다.

```bash
flutter analyze 2>&1 | grep -c "deprecated"
```

Expected: 100 이상. 이 수치가 Phase 1의 전환 잔여량이다.

- [ ] **Step 7: 커밋**

```bash
git add lib/core/theme/app_typography.dart lib/core/theme/app_text_styles.dart test/core/theme/app_typography_test.dart
git commit -m "feat: AppTypography ThemeExtension 추가, AppTextStyles는 deprecated shim으로 축소

색이 박제된 static const TextStyle은 테마 전환을 따라갈 수 없다.
호출부 135곳을 한꺼번에 깨뜨리지 않도록 삭제 대신 위임 shim을 남기고,
전환 잔여량은 deprecation 경고와 check_hardcoded.sh로 추적한다."
```

---

## Task 4: AppTheme에 dark 추가

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Test: `test/core/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: Task 2 `AppPalette`, Task 3 `AppTypography`
- Produces: `AppTheme.light`, `AppTheme.dark` (둘 다 `static ThemeData get`). 두 ThemeData 모두 `extensions`에 `AppPalette`와 `AppTypography`를 등록한다.

- [ ] **Step 1: 실패 테스트 작성**

`test/core/theme/app_theme_test.dart`:

```dart
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

  test('light 테마의 시각 속성은 기존과 동일하다', () {
    final theme = AppTheme.light;
    expect(theme.useMaterial3, isTrue);
    expect(theme.scaffoldBackgroundColor, AppPalette.light.background);
    expect(theme.appBarTheme.elevation, 0);
    expect(theme.appBarTheme.scrolledUnderElevation, 1);
    expect(theme.appBarTheme.centerTitle, isFalse);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL — `AppTheme.dark` 미정의

- [ ] **Step 3: 구현**

`lib/core/theme/app_theme.dart` 전체 교체. 기존 `light`의 시각 속성(모서리 반경, 패딩, 최소 크기, elevation)을 그대로 보존하되 팔레트를 파라미터로 받는 형태로 바꾼다.

```dart
import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      primary: palette.primary,
      surface: palette.surface,
      brightness: brightness,
    );
    final typography = AppTypography.fromPalette(palette);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      extensions: <ThemeExtension<dynamic>>[palette, typography],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.danger),
        ),
        labelStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.surface,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.primary),
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: typography.body,
        bodyMedium: typography.body,
        bodySmall: typography.caption,
      ),
    );
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS (4개 테스트)

`CardTheme` 타입이 Flutter 버전에 따라 `CardThemeData`로 바뀌었을 수 있다. `flutter analyze`가 지적하면 그대로 따른다.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/theme/app_theme.dart test/core/theme/app_theme_test.dart
git commit -m "feat: AppTheme.dark 추가 및 팔레트 기반으로 테마 조립 일원화"
```

---

## Task 5: l10n 스캐폴딩과 베이스 ARB

**Files:**
- Modify: `pubspec.yaml`, `.gitignore`
- Create: `l10n.yaml`, `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb`

**Interfaces:**
- Consumes: 없음
- Produces: `AppLocalizations` 클래스 — import 경로 `package:house_money_calculator/l10n/gen/app_localizations.dart`. 이 태스크가 확정하는 키는 `appTitle` 1개, `common*` 7개, `settings*` 8개다.

- [ ] **Step 1: pubspec.yaml 수정**

`dependencies:`의 `flutter: sdk: flutter` 바로 다음에 추가:

```yaml
  flutter_localizations:
    sdk: flutter
```

`flutter:` 섹션에 `uses-material-design: true`와 같은 들여쓰기 레벨로 추가:

```yaml
  generate: true
```

- [ ] **Step 2: l10n.yaml 생성**

프로젝트 루트에 `l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/gen
synthetic-package: false
nullable-getter: false
```

`nullable-getter: false`로 두면 `AppLocalizations.of(context)`가 non-null을 반환해 호출부에 `!`가 필요 없다.

- [ ] **Step 3: 베이스 ARB 생성**

`lib/l10n/app_ko.arb`:

```json
{
  "@@locale": "ko",

  "appTitle": "어떤비용",
  "@appTitle": { "description": "앱 이름. 태스크 스위처에 표시" },

  "commonCancel": "취소",
  "@commonCancel": { "description": "다이얼로그 취소 버튼" },
  "commonConfirm": "확인",
  "@commonConfirm": { "description": "다이얼로그 확인 버튼" },
  "commonSave": "저장",
  "@commonSave": { "description": "저장 버튼" },
  "commonDelete": "삭제",
  "@commonDelete": { "description": "삭제 버튼" },
  "commonClose": "닫기",
  "@commonClose": { "description": "닫기 버튼" },
  "commonRetry": "다시 시도",
  "@commonRetry": { "description": "실패 후 재시도 버튼" },
  "commonError": "오류가 발생했어요. 잠시 후 다시 시도해 주세요.",
  "@commonError": { "description": "일반 오류 메시지" },

  "settingsThemeLabel": "테마",
  "@settingsThemeLabel": { "description": "테마 선택 항목 라벨" },
  "settingsThemeSystem": "시스템 설정 따름",
  "@settingsThemeSystem": { "description": "테마 옵션" },
  "settingsThemeLight": "라이트",
  "@settingsThemeLight": { "description": "테마 옵션" },
  "settingsThemeDark": "다크",
  "@settingsThemeDark": { "description": "테마 옵션" },
  "settingsLanguageLabel": "언어",
  "@settingsLanguageLabel": { "description": "언어 선택 항목 라벨" },
  "settingsLanguageSystem": "시스템 설정 따름",
  "@settingsLanguageSystem": { "description": "언어 옵션" },
  "settingsLanguageKorean": "한국어",
  "@settingsLanguageKorean": { "description": "언어 옵션. 두 로케일에서 동일하게 표기" },
  "settingsLanguageEnglish": "English",
  "@settingsLanguageEnglish": { "description": "언어 옵션. 두 로케일에서 동일하게 표기" }
}
```

`lib/l10n/app_en.arb`:

```json
{
  "@@locale": "en",

  "appTitle": "Housing Cost Calculator",

  "commonCancel": "Cancel",
  "commonConfirm": "OK",
  "commonSave": "Save",
  "commonDelete": "Delete",
  "commonClose": "Close",
  "commonRetry": "Retry",
  "commonError": "Something went wrong. Please try again in a moment.",

  "settingsThemeLabel": "Theme",
  "settingsThemeSystem": "Follow system",
  "settingsThemeLight": "Light",
  "settingsThemeDark": "Dark",
  "settingsLanguageLabel": "Language",
  "settingsLanguageSystem": "Follow system",
  "settingsLanguageKorean": "한국어",
  "settingsLanguageEnglish": "English"
}
```

- [ ] **Step 4: 코드 생성 및 검증**

```bash
flutter pub get
flutter gen-l10n
ls lib/l10n/gen/
```

Expected: `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_ko.dart` 생성

- [ ] **Step 5: .gitignore에 생성물 추가**

`.gitignore` 끝에 추가:

```
# gen_l10n 생성물
lib/l10n/gen/
```

- [ ] **Step 6: 커밋**

```bash
git add pubspec.yaml pubspec.lock l10n.yaml lib/l10n/app_ko.arb lib/l10n/app_en.arb .gitignore
git commit -m "feat: flutter_localizations 도입 및 베이스 ARB 추가

common 7개와 설정 화면 8개 키를 베이스로 확정한다.
슬라이스는 이 키를 재정의하지 않고 자기 네임스페이스 키만 프래그먼트에 추가한다."
```

---

## Task 6: ThemeMode 영속화 notifier

**Files:**
- Create: `lib/core/settings/theme_mode_notifier.dart`
- Test: `test/core/settings/theme_mode_notifier_test.dart`

**Interfaces:**
- Consumes: Hive `app_settings` 박스 (이미 `main.dart`에서 `runApp` 전에 열림)
- Produces:
  - `const String kThemeModeKey = 'theme_mode';`
  - `class ThemeModeNotifier extends Notifier<ThemeMode>` — `void setMode(ThemeMode mode)`
  - `final themeModeNotifierProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);`
  - 저장 문자열: `'system'` | `'light'` | `'dark'`

- [ ] **Step 1: 실패 테스트 작성**

`test/core/settings/theme_mode_notifier_test.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/theme_mode_notifier.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('theme_mode_test');
    Hive.init(tempDir.path);
    await Hive.openBox('app_settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('저장된 값이 없으면 system이다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.system);
  });

  test('setMode가 상태와 Hive를 함께 갱신한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(themeModeNotifierProvider.notifier).setMode(ThemeMode.dark);

    expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    expect(Hive.box('app_settings').get(kThemeModeKey), 'dark');
  });

  test('저장된 값을 복원한다', () async {
    await Hive.box('app_settings').put(kThemeModeKey, 'light');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.light);
  });

  test('알 수 없는 문자열이면 system으로 폴백한다', () async {
    await Hive.box('app_settings').put(kThemeModeKey, 'purple');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.system);
  });

  test('타입이 다른 값이어도 system으로 폴백한다', () async {
    await Hive.box('app_settings').put(kThemeModeKey, 42);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.system);
  });

  test('기존 설정 키를 건드리지 않는다', () async {
    await Hive.box('app_settings').put('login_skipped', true);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(themeModeNotifierProvider.notifier).setMode(ThemeMode.dark);

    expect(Hive.box('app_settings').get('login_skipped'), isTrue);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/settings/theme_mode_notifier_test.dart`
Expected: FAIL — `theme_mode_notifier.dart` 없음

- [ ] **Step 3: 구현**

`lib/core/settings/theme_mode_notifier.dart`:

```dart
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String kThemeModeKey = 'theme_mode';

const String _system = 'system';
const String _light = 'light';
const String _dark = 'dark';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => _read();

  void setMode(ThemeMode mode) {
    state = mode;
    Hive.box('app_settings').put(kThemeModeKey, _encode(mode));
  }

  ThemeMode _read() {
    final raw = Hive.box('app_settings').get(kThemeModeKey);
    if (raw == null) return ThemeMode.system;
    switch (raw) {
      case _light:
        return ThemeMode.light;
      case _dark:
        return ThemeMode.dark;
      case _system:
        return ThemeMode.system;
      default:
        // 손상된 값을 조용히 넘기지 않고 기록한 뒤 기본값으로 되돌린다.
        developer.log(
          'Unexpected theme_mode value: $raw. Falling back to system.',
          name: 'ThemeModeNotifier',
        );
        return ThemeMode.system;
    }
  }

  String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => _light,
        ThemeMode.dark => _dark,
        ThemeMode.system => _system,
      };
}

final themeModeNotifierProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/core/settings/theme_mode_notifier_test.dart`
Expected: PASS (6개 테스트)

- [ ] **Step 5: 커밋**

```bash
git add lib/core/settings/theme_mode_notifier.dart test/core/settings/theme_mode_notifier_test.dart
git commit -m "feat: 테마 모드 상태와 Hive 영속화 추가"
```

---

## Task 7: Locale 영속화 notifier

**Files:**
- Create: `lib/core/settings/locale_notifier.dart`
- Test: `test/core/settings/locale_notifier_test.dart`

**Interfaces:**
- Consumes: Hive `app_settings` 박스
- Produces:
  - `const String kLocaleKey = 'locale';`
  - `const List<Locale> kSupportedLocales = [Locale('ko'), Locale('en')];`
  - `class LocaleNotifier extends Notifier<Locale?>` — `void setLocale(Locale? locale)`. `null`은 "시스템 따름".
  - `final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);`
  - `Locale resolveLocale(Locale? deviceLocale, Iterable<Locale> supported)` — `MaterialApp.localeResolutionCallback`에 그대로 연결 가능한 최상위 함수

- [ ] **Step 1: 실패 테스트 작성**

`test/core/settings/locale_notifier_test.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/locale_notifier.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('locale_test');
    Hive.init(tempDir.path);
    await Hive.openBox('app_settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('저장된 값이 없으면 null(시스템 따름)이다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeNotifierProvider), isNull);
  });

  test('setLocale이 상태와 Hive를 함께 갱신한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeNotifierProvider.notifier).setLocale(const Locale('en'));

    expect(container.read(localeNotifierProvider), const Locale('en'));
    expect(Hive.box('app_settings').get(kLocaleKey), 'en');
  });

  test('시스템 따름으로 되돌리면 system을 저장한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(localeNotifierProvider.notifier);
    notifier.setLocale(const Locale('en'));
    notifier.setLocale(null);

    expect(container.read(localeNotifierProvider), isNull);
    expect(Hive.box('app_settings').get(kLocaleKey), 'system');
  });

  test('저장된 값을 복원한다', () async {
    await Hive.box('app_settings').put(kLocaleKey, 'ko');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeNotifierProvider), const Locale('ko'));
  });

  test('지원하지 않는 값이면 null로 폴백한다', () async {
    await Hive.box('app_settings').put(kLocaleKey, 'ja');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeNotifierProvider), isNull);
  });

  group('resolveLocale', () {
    test('지원 로케일이면 그대로 쓴다', () {
      expect(resolveLocale(const Locale('en'), kSupportedLocales),
          const Locale('en'));
    });

    test('지역 코드가 붙어도 언어 코드로 매칭한다', () {
      expect(resolveLocale(const Locale('en', 'US'), kSupportedLocales),
          const Locale('en'));
    });

    test('미지원 로케일은 ko로 폴백한다', () {
      expect(resolveLocale(const Locale('ja'), kSupportedLocales),
          const Locale('ko'));
    });

    test('기기 로케일이 null이면 ko로 폴백한다', () {
      expect(resolveLocale(null, kSupportedLocales), const Locale('ko'));
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/settings/locale_notifier_test.dart`
Expected: FAIL — `locale_notifier.dart` 없음

- [ ] **Step 3: 구현**

`lib/core/settings/locale_notifier.dart`:

```dart
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String kLocaleKey = 'locale';

const List<Locale> kSupportedLocales = [Locale('ko'), Locale('en')];

const String _system = 'system';

/// 상태가 null이면 "시스템 설정 따름"을 뜻한다.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => _read();

  void setLocale(Locale? locale) {
    state = locale;
    Hive.box('app_settings').put(kLocaleKey, locale?.languageCode ?? _system);
  }

  Locale? _read() {
    final raw = Hive.box('app_settings').get(kLocaleKey);
    if (raw == null || raw == _system) return null;
    for (final locale in kSupportedLocales) {
      if (locale.languageCode == raw) return locale;
    }
    developer.log(
      'Unexpected locale value: $raw. Falling back to system.',
      name: 'LocaleNotifier',
    );
    return null;
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

/// MaterialApp.localeResolutionCallback에 연결한다.
/// 지원하지 않는 기기 로케일은 한국어로 폴백한다.
Locale resolveLocale(Locale? deviceLocale, Iterable<Locale> supported) {
  if (deviceLocale != null) {
    for (final locale in supported) {
      if (locale.languageCode == deviceLocale.languageCode) return locale;
    }
  }
  return const Locale('ko');
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/core/settings/locale_notifier_test.dart`
Expected: PASS (9개 테스트)

- [ ] **Step 5: 커밋**

```bash
git add lib/core/settings/locale_notifier.dart test/core/settings/locale_notifier_test.dart
git commit -m "feat: 로케일 상태와 Hive 영속화, 폴백 규칙 추가"
```

---

## Task 8: app.dart 배선

**Files:**
- Modify: `lib/app.dart`
- Test: `test/app_theme_locale_test.dart`

**Interfaces:**
- Consumes: Task 4 `AppTheme.dark`, Task 5 `AppLocalizations`, Task 6 `themeModeNotifierProvider`, Task 7 `localeNotifierProvider`/`kSupportedLocales`/`resolveLocale`
- Produces: 앱 전역에서 테마·로케일이 동작. 이후 모든 코드가 `AppLocalizations.of(context)`를 쓸 수 있다.

`App` 위젯 자체는 Firebase 초기화와 라우터에 의존해 위젯 테스트로 띄우기 어렵다. 테스트는 **동일한 MaterialApp 설정을 조립한 축소판**으로 배선 규칙을 검증한다.

- [ ] **Step 1: 실패 테스트 작성**

`test/app_theme_locale_test.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/locale_notifier.dart';
import 'package:house_money_calculator/core/settings/theme_mode_notifier.dart';
import 'package:house_money_calculator/core/theme/app_palette.dart';
import 'package:house_money_calculator/core/theme/app_theme.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

/// app.dart의 MaterialApp 설정과 동일한 축소판.
Widget harness(WidgetRef ref, Widget child) {
  return MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ref.watch(themeModeNotifierProvider),
    locale: ref.watch(localeNotifierProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: kSupportedLocales,
    localeResolutionCallback: resolveLocale,
    home: child,
  );
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_wiring_test');
    Hive.init(tempDir.path);
    await Hive.openBox('app_settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  testWidgets('테마 모드를 dark로 바꾸면 다크 팔레트가 적용된다', (tester) async {
    late BuildContext captured;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => harness(
            ref,
            Builder(builder: (c) {
              captured = c;
              return const SizedBox();
            }),
          ),
        ),
      ),
    );

    expect(captured.palette.surface, AppPalette.light.surface);

    final container =
        ProviderScope.containerOf(tester.element(find.byType(Consumer)));
    container.read(themeModeNotifierProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(captured.palette.surface, AppPalette.dark.surface);
  });

  testWidgets('로케일을 en으로 바꾸면 영어 문자열이 나온다', (tester) async {
    late BuildContext captured;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => harness(
            ref,
            Builder(builder: (c) {
              captured = c;
              return const SizedBox();
            }),
          ),
        ),
      ),
    );

    expect(AppLocalizations.of(captured).commonCancel, '취소');

    final container =
        ProviderScope.containerOf(tester.element(find.byType(Consumer)));
    container.read(localeNotifierProvider.notifier).setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    expect(AppLocalizations.of(captured).commonCancel, 'Cancel');
  });
}
```

- [ ] **Step 2: 실패 확인**

```bash
flutter gen-l10n
flutter test test/app_theme_locale_test.dart
```

Expected: FAIL — provider 미배선이거나 생성 파일 경로 불일치

- [ ] **Step 3: app.dart 수정**

기존 import 목록에 추가:

```dart
import 'core/settings/locale_notifier.dart';
import 'core/settings/theme_mode_notifier.dart';
import 'l10n/gen/app_localizations.dart';
```

`build` 메서드에서 `final isOnline = ref.watch(connectivityProvider);` 아래에 추가:

```dart
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);
```

`return MaterialApp.router(...)`의 `title: '어떤비용',` 줄을 **삭제**하고 다음으로 교체한다:

```dart
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: kSupportedLocales,
      localeResolutionCallback: resolveLocale,
```

`routerConfig`, `debugShowCheckedModeBanner`, `builder`는 기존 그대로 둔다.

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/app_theme_locale_test.dart`
Expected: PASS (2개 테스트)

- [ ] **Step 5: 커밋**

```bash
git add lib/app.dart test/app_theme_locale_test.dart
git commit -m "feat: MaterialApp에 다크테마/로케일/지역화 델리게이트 배선"
```

---

## Task 9: 설정 화면 테마·언어 선택 UI

**Files:**
- Create: `lib/features/settings/theme_locale_section.dart`
- Modify: `lib/features/settings/settings_screen.dart`
- Test: `test/features/settings/theme_locale_section_test.dart`

**Interfaces:**
- Consumes: Task 5의 `settings*` ARB 키, Task 6 `themeModeNotifierProvider`, Task 7 `localeNotifierProvider`, Task 2 `context.palette`
- Produces: `class ThemeLocaleSection extends ConsumerWidget` — 생성자 인자 없음 (`const ThemeLocaleSection({super.key})`)

이 위젯은 **처음부터 새 패턴으로 작성한다** — `context.palette`와 `AppLocalizations`만 쓰고 하드코딩 한글이나 `AppColors` 직접 참조를 넣지 않는다. Phase 1의 S2가 다시 손대지 않아도 되게 한다.

- [ ] **Step 1: 실패 테스트 작성**

`test/features/settings/theme_locale_section_test.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/locale_notifier.dart';
import 'package:house_money_calculator/core/settings/theme_mode_notifier.dart';
import 'package:house_money_calculator/features/settings/theme_locale_section.dart';
import 'package:house_money_calculator/l10n/gen/app_localizations.dart';

Widget wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: kSupportedLocales,
        home: Scaffold(body: child),
      ),
    );

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

  testWidgets('다크를 선택하면 테마 모드가 저장된다', (tester) async {
    await tester.pumpWidget(wrap(const ThemeLocaleSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('테마'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다크').last);
    await tester.pumpAndSettle();

    expect(Hive.box('app_settings').get(kThemeModeKey), 'dark');
  });

  testWidgets('English를 선택하면 로케일이 저장된다', (tester) async {
    await tester.pumpWidget(wrap(const ThemeLocaleSection()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('언어'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(Hive.box('app_settings').get(kLocaleKey), 'en');
  });

  testWidgets('시스템 따름을 다시 고르면 system이 저장된다', (tester) async {
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

    expect(Hive.box('app_settings').get(kLocaleKey), 'system');
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/features/settings/theme_locale_section_test.dart`
Expected: FAIL — `theme_locale_section.dart` 없음

- [ ] **Step 3: 구현**

`lib/features/settings/theme_locale_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/locale_notifier.dart';
import '../../core/settings/theme_mode_notifier.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/gen/app_localizations.dart';

class ThemeLocaleSection extends ConsumerWidget {
  const ThemeLocaleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text(
            l10n.settingsThemeLabel,
            style: TextStyle(fontSize: 15, color: context.palette.textPrimary),
          ),
          trailing: Text(
            _themeLabel(l10n, themeMode),
            style: TextStyle(color: context.palette.textSecondary),
          ),
          onTap: () => _pickTheme(context, ref, themeMode),
        ),
        ListTile(
          title: Text(
            l10n.settingsLanguageLabel,
            style: TextStyle(fontSize: 15, color: context.palette.textPrimary),
          ),
          trailing: Text(
            _localeLabel(l10n, locale),
            style: TextStyle(color: context.palette.textSecondary),
          ),
          onTap: () => _pickLocale(context, ref, locale),
        ),
      ],
    );
  }

  String _themeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
        ThemeMode.system => l10n.settingsThemeSystem,
        ThemeMode.light => l10n.settingsThemeLight,
        ThemeMode.dark => l10n.settingsThemeDark,
      };

  String _localeLabel(AppLocalizations l10n, Locale? locale) {
    if (locale == null) return l10n.settingsLanguageSystem;
    return locale.languageCode == 'en'
        ? l10n.settingsLanguageEnglish
        : l10n.settingsLanguageKorean;
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: current,
                title: Text(_themeLabel(l10n, mode)),
                onChanged: (value) => Navigator.of(sheetContext).pop(value),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      ref.read(themeModeNotifierProvider.notifier).setMode(selected);
    }
  }

  Future<void> _pickLocale(
    BuildContext context,
    WidgetRef ref,
    Locale? current,
  ) async {
    final l10n = AppLocalizations.of(context);
    const options = <Locale?>[null, Locale('ko'), Locale('en')];

    final selected = await showModalBottomSheet<_LocaleChoice>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              RadioListTile<Locale?>(
                value: option,
                groupValue: current,
                title: Text(_localeLabel(l10n, option)),
                onChanged: (value) =>
                    Navigator.of(sheetContext).pop(_LocaleChoice(value)),
              ),
          ],
        ),
      ),
    );

    if (selected != null) {
      ref.read(localeNotifierProvider.notifier).setLocale(selected.value);
    }
  }
}

/// null(시스템 따름) 선택과 "시트를 그냥 닫음"을 구분하기 위한 래퍼.
class _LocaleChoice {
  final Locale? value;
  const _LocaleChoice(this.value);
}
```

- [ ] **Step 4: settings_screen.dart에 삽입**

상단 import에 추가:

```dart
import 'theme_locale_section.dart';
```

'앱 사용법' 항목(현재 105행 근처)이 속한 섹션 **바로 앞**에 `const ThemeLocaleSection(),`을 위젯 목록에 넣는다. 계정 섹션과 정보 섹션 사이가 자연스럽다.

- [ ] **Step 5: 통과 확인**

Run: `flutter test test/features/settings/theme_locale_section_test.dart`
Expected: PASS (4개 테스트)

- [ ] **Step 6: 커밋**

```bash
git add lib/features/settings/theme_locale_section.dart lib/features/settings/settings_screen.dart test/features/settings/theme_locale_section_test.dart
git commit -m "feat: 설정 화면에 테마/언어 선택 UI 추가"
```

---

## Task 10: MoneyFormatter 로케일 분기

**Files:**
- Create: `lib/core/utils/money_format_style.dart`
- Modify: `lib/core/utils/money_formatter.dart`
- Test: `test/core/utils/money_format_style_test.dart`
- **수정 금지**: `test/core/utils/money_formatter_test.dart` (ko 불변 보증)

**Interfaces:**
- Consumes: 없음
- Produces:
  - `enum MoneyFormatStyle { korean, western }`
  - `MoneyFormatStyle moneyStyleFor(Locale? locale)` — `en`이면 `western`, 그 외 `korean`
  - `static String MoneyFormatter.formatCompact(int amount, MoneyFormatStyle style)`
  - 기존 `MoneyFormatter.format`, `formatWithWon`, `formatKorean`, `parse`는 **시그니처·출력 모두 그대로 유지**

- [ ] **Step 1: 실패 테스트 작성**

`test/core/utils/money_format_style_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/utils/money_format_style.dart';
import 'package:house_money_calculator/core/utils/money_formatter.dart';

void main() {
  group('moneyStyleFor', () {
    test('en은 western이다', () {
      expect(moneyStyleFor(const Locale('en')), MoneyFormatStyle.western);
    });

    test('ko는 korean이다', () {
      expect(moneyStyleFor(const Locale('ko')), MoneyFormatStyle.korean);
    });

    test('null은 korean으로 폴백한다', () {
      expect(moneyStyleFor(null), MoneyFormatStyle.korean);
    });
  });

  group('formatCompact - korean', () {
    test('기존 formatKorean과 완전히 같은 출력을 낸다', () {
      for (final amount in [0, 3500, 10000, 20000000, 105000000, 320000000]) {
        expect(
          MoneyFormatter.formatCompact(amount, MoneyFormatStyle.korean),
          MoneyFormatter.formatKorean(amount),
          reason: '금액 $amount에서 ko 출력이 달라졌다',
        );
      }
    });
  });

  group('formatCompact - western', () {
    test('억/만/원 단위를 쓰지 않는다', () {
      final result =
          MoneyFormatter.formatCompact(320000000, MoneyFormatStyle.western);
      expect(result, isNot(contains('억')));
      expect(result, isNot(contains('만')));
      expect(result, isNot(contains('원')));
    });

    test('통화를 KRW로 표기한다', () {
      expect(MoneyFormatter.formatCompact(320000000, MoneyFormatStyle.western),
          startsWith('KRW '));
    });

    test('백만 단위는 M을 쓴다', () {
      expect(MoneyFormatter.formatCompact(320000000, MoneyFormatStyle.western),
          'KRW 320M');
    });

    test('십억 단위는 B를 쓴다', () {
      expect(MoneyFormatter.formatCompact(2500000000, MoneyFormatStyle.western),
          'KRW 2.5B');
    });

    test('천 단위는 K를 쓴다', () {
      expect(MoneyFormatter.formatCompact(35000, MoneyFormatStyle.western),
          'KRW 35K');
    });

    test('천 미만은 단위 없이 표기한다', () {
      expect(MoneyFormatter.formatCompact(500, MoneyFormatStyle.western),
          'KRW 500');
    });

    test('0 이하는 빈 문자열이다', () {
      expect(MoneyFormatter.formatCompact(0, MoneyFormatStyle.western), '');
      expect(MoneyFormatter.formatCompact(-1, MoneyFormatStyle.western), '');
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/utils/money_format_style_test.dart`
Expected: FAIL — `money_format_style.dart` 없음

- [ ] **Step 3: 구현**

`lib/core/utils/money_format_style.dart`:

```dart
import 'package:flutter/widgets.dart';

/// 금액 표기 방식.
/// 한국식 만 단위 체계는 영어로 직역되지 않으므로 로케일에 따라 분기한다.
enum MoneyFormatStyle { korean, western }

MoneyFormatStyle moneyStyleFor(Locale? locale) {
  return locale?.languageCode == 'en'
      ? MoneyFormatStyle.western
      : MoneyFormatStyle.korean;
}
```

`lib/core/utils/money_formatter.dart` 상단 import에 추가:

```dart
import 'money_format_style.dart';
```

`MoneyFormatter` 클래스 본문에 추가 (기존 메서드는 그대로 둔다):

```dart
  /// 로케일에 맞는 축약 표기. korean은 기존 formatKorean과 동일하다.
  static String formatCompact(int amount, MoneyFormatStyle style) {
    return switch (style) {
      MoneyFormatStyle.korean => formatKorean(amount),
      MoneyFormatStyle.western => _formatWestern(amount),
    };
  }

  static String _formatWestern(int amount) {
    if (amount <= 0) return '';
    if (amount >= 1000000000) return 'KRW ${_trim(amount / 1000000000)}B';
    if (amount >= 1000000) return 'KRW ${_trim(amount / 1000000)}M';
    if (amount >= 1000) return 'KRW ${_trim(amount / 1000)}K';
    return 'KRW $amount';
  }

  /// 소수 첫째 자리까지 쓰되 .0은 떼어낸다.
  static String _trim(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.truncateToDouble()
        ? rounded.truncate().toString()
        : rounded.toString();
  }
```

- [ ] **Step 4: 통과 확인**

```bash
flutter test test/core/utils/money_format_style_test.dart
flutter test test/core/utils/money_formatter_test.dart
```

Expected: 둘 다 PASS. 두 번째가 실패하면 ko 출력을 바꾼 것이므로 되돌린다.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/utils/money_format_style.dart lib/core/utils/money_formatter.dart test/core/utils/money_format_style_test.dart
git commit -m "feat: 로케일별 금액 표기 전략 추가

ko 출력은 기존과 동일하게 유지하고 en에는 서구식 K/M/B 단위를 쓴다."
```

**`lib/core/extensions/number_format_extension.dart`(한글 2)는 이 태스크에서 다루지 않는다.** 이 파일은 `MoneyFormatStyle`을 소비하기만 하는 얇은 확장이므로, 전략이 존재하기만 하면 호출부 치환은 기계적이다. Phase 1의 S10이 담당한다. 설계 문서 §3.7이 이 파일을 "money_formatter와 같은 전략 사용"으로 분류한 것은 **전략의 정의**가 아니라 **적용**을 뜻한다.

---

## Task 11: Validators enum 반환

**Files:**
- Create: `lib/core/utils/validation_error.dart`
- Modify: `lib/core/utils/validators.dart`
- Test: `test/core/utils/validators_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces:
  - `enum ValidationError { amountRequired, amountInvalid, rateRequired, rateOutOfRange, monthsRequired, monthsOutOfRange, loanExceedsDeposit }`
  - `static ValidationError? Validators.requiredAmountCode(String?)`
  - `static ValidationError? Validators.interestRateCode(String?)`
  - `static ValidationError? Validators.monthsCode(String?)`
  - `static ValidationError? Validators.loanNotExceedDepositCode(int loan, int deposit)`
  - 기존 4개 메서드(`requiredAmount`, `interestRate`, `months`, `loanNotExceedDeposit`)는 **시그니처·동작 그대로 `@Deprecated`로 유지**

**기존 메서드의 반환 타입을 바꾸면 안 되는 이유가 있다.** 호출부 40건 중 **38건이 tear-off**다:

```dart
validator: Validators.requiredAmount,
```

Flutter의 `validator:`는 `String? Function(String?)`(`FormFieldValidator<String>`)를 요구한다. 반환 타입을 `ValidationError?`로 바꾸면 이 38곳이 전부 타입 에러가 나고, **지역화된 메시지 없이는 고칠 수도 없다** — 메시지를 만들려면 `BuildContext`가 필요하고 그건 Phase 1의 작업이다. 그래서 신구 API를 병존시킨다.

Phase 1의 각 슬라이스는 tear-off를 클로저로 바꾸면서 전환한다:

```dart
validator: (v) => Validators.requiredAmountCode(v)?.localize(context),
```

`ValidationError.localize` 확장과 `rateOutOfRange`/`monthsOutOfRange`의 플레이스홀더 ARB 키(`AppConstants`의 상·하한이 문장에 들어간다)는 Phase 1의 S10이 만든다. **이 태스크는 enum과 `*Code` 메서드까지만** 만든다.

Phase 1이 38곳을 모두 옮긴 뒤 `@Deprecated` 메서드 4개를 삭제하고, 그때 `*Code` 접미사를 떼는 기계적 리네임을 한 번에 한다.

- [ ] **Step 1: 실패 테스트 작성**

`test/core/utils/validators_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/constants/app_constants.dart';
import 'package:house_money_calculator/core/utils/validation_error.dart';
import 'package:house_money_calculator/core/utils/validators.dart';

void main() {
  group('requiredAmountCode', () {
    test('빈 값은 amountRequired', () {
      expect(Validators.requiredAmountCode(''), ValidationError.amountRequired);
      expect(Validators.requiredAmountCode(null), ValidationError.amountRequired);
      expect(Validators.requiredAmountCode('   '), ValidationError.amountRequired);
    });

    test('숫자가 아니면 amountInvalid', () {
      expect(Validators.requiredAmountCode('abc'), ValidationError.amountInvalid);
    });

    test('음수는 amountInvalid', () {
      expect(Validators.requiredAmountCode('-1'), ValidationError.amountInvalid);
    });

    test('쉼표가 있는 정상 금액은 null', () {
      expect(Validators.requiredAmountCode('1,000,000'), isNull);
    });
  });

  group('interestRateCode', () {
    test('빈 값은 rateRequired', () {
      expect(Validators.interestRateCode(''), ValidationError.rateRequired);
    });

    test('상한 초과는 rateOutOfRange', () {
      expect(
        Validators.interestRateCode('${AppConstants.maxInterestRate + 1}'),
        ValidationError.rateOutOfRange,
      );
    });

    test('음수는 rateOutOfRange', () {
      expect(Validators.interestRateCode('-1'), ValidationError.rateOutOfRange);
    });

    test('정상 금리는 null', () {
      expect(Validators.interestRateCode('3.5'), isNull);
    });
  });

  group('monthsCode', () {
    test('빈 값은 monthsRequired', () {
      expect(Validators.monthsCode(''), ValidationError.monthsRequired);
    });

    test('상한 초과는 monthsOutOfRange', () {
      expect(
        Validators.monthsCode('${AppConstants.maxMonths + 1}'),
        ValidationError.monthsOutOfRange,
      );
    });

    test('하한 미만은 monthsOutOfRange', () {
      expect(
        Validators.monthsCode('${AppConstants.minMonths - 1}'),
        ValidationError.monthsOutOfRange,
      );
    });

    test('정상 개월수는 null', () {
      expect(Validators.monthsCode('${AppConstants.minMonths}'), isNull);
    });
  });

  group('loanNotExceedDepositCode', () {
    test('대출금이 크면 loanExceedsDeposit', () {
      expect(Validators.loanNotExceedDepositCode(200, 100),
          ValidationError.loanExceedsDeposit);
    });

    test('같거나 작으면 null', () {
      expect(Validators.loanNotExceedDepositCode(100, 100), isNull);
      expect(Validators.loanNotExceedDepositCode(50, 100), isNull);
    });
  });

  group('구형 API 병존', () {
    test('deprecated 메서드는 여전히 String을 반환한다', () {
      // ignore: deprecated_member_use_from_same_package
      final result = Validators.requiredAmount('');
      expect(result, isA<String>());
    });

    test('신구 API의 판정이 일치한다', () {
      for (final input in ['', 'abc', '-1', '1,000,000']) {
        // ignore: deprecated_member_use_from_same_package
        final legacyFailed = Validators.requiredAmount(input) != null;
        final codeFailed = Validators.requiredAmountCode(input) != null;
        expect(codeFailed, legacyFailed, reason: '입력 "$input"에서 판정이 갈렸다');
      }
    });
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/utils/validators_test.dart`
Expected: FAIL — `validation_error.dart` 없음

- [ ] **Step 3: 구현**

`lib/core/utils/validation_error.dart`:

```dart
/// 입력 검증 실패 사유. 표시 문장은 표현 계층이 지역화한다.
enum ValidationError {
  amountRequired,
  amountInvalid,
  rateRequired,
  rateOutOfRange,
  monthsRequired,
  monthsOutOfRange,
  loanExceedsDeposit,
}
```

`lib/core/utils/validators.dart` 전체 교체. **기존 4개 메서드는 본문을 그대로 두고 `@Deprecated`만 붙인다** — 판정 로직을 손대면 38개 호출부의 동작이 조용히 바뀐다. 새 `*Code` 메서드는 같은 조건을 enum으로 반환한다.

```dart
import '../constants/app_constants.dart';
import 'validation_error.dart';

class Validators {
  Validators._();

  // ---- 신규 API: 코드 반환 ----

  static ValidationError? requiredAmountCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.amountRequired;
    }
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount < 0) return ValidationError.amountInvalid;
    return null;
  }

  static ValidationError? interestRateCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.rateRequired;
    }
    final rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > AppConstants.maxInterestRate) {
      return ValidationError.rateOutOfRange;
    }
    return null;
  }

  static ValidationError? monthsCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationError.monthsRequired;
    }
    final m = int.tryParse(value);
    if (m == null || m < AppConstants.minMonths || m > AppConstants.maxMonths) {
      return ValidationError.monthsOutOfRange;
    }
    return null;
  }

  static ValidationError? loanNotExceedDepositCode(int loan, int deposit) {
    if (loan > deposit) return ValidationError.loanExceedsDeposit;
    return null;
  }

  // ---- 구형 API: 한글 메시지 반환 ----
  // FormFieldValidator<String> tear-off로 38곳에서 쓰이고 있어 제거할 수 없다.
  // Phase 1이 호출부를 (v) => ...Code(v)?.localize(context) 로 옮긴 뒤 삭제한다.

  @Deprecated('requiredAmountCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? requiredAmount(String? value) {
    if (value == null || value.trim().isEmpty) return '금액을 입력해 주세요.';
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount < 0) return '올바른 금액을 입력해 주세요.';
    return null;
  }

  @Deprecated('interestRateCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? interestRate(String? value) {
    if (value == null || value.trim().isEmpty) return '금리를 입력해 주세요.';
    final rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > AppConstants.maxInterestRate) {
      return '금리는 0 이상 ${AppConstants.maxInterestRate} 이하로 입력해 주세요.';
    }
    return null;
  }

  @Deprecated('monthsCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? months(String? value) {
    if (value == null || value.trim().isEmpty) return '거주 기간을 입력해 주세요.';
    final m = int.tryParse(value);
    if (m == null || m < AppConstants.minMonths || m > AppConstants.maxMonths) {
      return '거주 기간은 ${AppConstants.minMonths}~${AppConstants.maxMonths}개월로 입력해 주세요.';
    }
    return null;
  }

  @Deprecated('loanNotExceedDepositCode를 사용하세요. Phase 1 완료 후 제거됩니다.')
  static String? loanNotExceedDeposit(int loan, int deposit) {
    if (loan > deposit) return '대출금은 전세 보증금보다 클 수 없습니다.';
    return null;
  }
}
```

구형 메서드의 한글 문자열은 `tool/check_hardcoded.sh`에 계속 잡힌다. Phase 1이 끝나야 0이 되므로 **정상이다.**

- [ ] **Step 4: 통과 확인**

```bash
flutter test test/core/utils/validators_test.dart
flutter analyze 2>&1 | grep -E "^\s*error" | head
```

Expected: 테스트 PASS (16개), analyze error 출력 없음. 38개 tear-off 호출부가 그대로 컴파일되어야 한다.

- [ ] **Step 5: 커밋**

```bash
git add lib/core/utils/validation_error.dart lib/core/utils/validators.dart test/core/utils/validators_test.dart
git commit -m "feat: Validators에 ValidationError를 반환하는 *Code 메서드 추가

38곳이 FormFieldValidator tear-off로 쓰고 있어 기존 메서드의 반환 타입을
바꿀 수 없다. 지역화 메시지에는 BuildContext가 필요해 호출부를 지금
고칠 수도 없으므로 신구 API를 병존시키고 구형은 @Deprecated로 표시한다."
```

---

## Task 12: 전세위험 도메인 enum 리팩터링

**Files:**
- Create: `lib/domain/entities/jeonse_risk_codes.dart`
- Modify: `lib/domain/entities/jeonse_risk_result.dart`
- Modify: `lib/domain/calculators/jeonse_risk_calculator.dart`
- Modify: `test/domain/calculators/jeonse_risk_calculator_test.dart`
- Test: `test/domain/entities/jeonse_risk_codes_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces:
  - `enum JeonseRiskWarning` (11개), `enum JeonseRiskCheck` (5개), `enum JeonseRiskAction` (13개), `enum JeonseProtectionStep` (3개)
  - `JeonseRiskResult`의 `warnings`/`checklist`/`actionItems`/`protectionChecklist`가 각각 위 enum의 `List`가 된다
  - `levelDescription`, `summaryText` 필드는 **제거**된다. 표현 계층이 `level`과 `score`로부터 만든다
  - `JeonseRiskLevelLabel` 확장(한글 `label`)은 **제거**된다
  - `JeonseRiskLevel` enum(`low`/`caution`/`high`)은 유지된다

`JeonseRiskInput`의 필드는 `marketPrice`, `deposit`, `seniorDebt`, `checkedRegistry`, `ownerMatched`, `checkedTaxArrears`, `canJoinGuaranteeInsurance`, `willReportMoveIn`, `willGetFixedDate`다 (모두 named required).

- [ ] **Step 1: 실패 테스트 작성**

`test/domain/entities/jeonse_risk_codes_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/jeonse_risk_calculator.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_codes.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_input.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_result.dart';

JeonseRiskInput buildInput({
  int marketPrice = 200000000,
  int deposit = 100000000,
  int seniorDebt = 0,
  bool checkedRegistry = true,
  bool ownerMatched = true,
  bool checkedTaxArrears = true,
  bool canJoinGuaranteeInsurance = true,
  bool willReportMoveIn = true,
  bool willGetFixedDate = true,
}) {
  return JeonseRiskInput(
    marketPrice: marketPrice,
    deposit: deposit,
    seniorDebt: seniorDebt,
    checkedRegistry: checkedRegistry,
    ownerMatched: ownerMatched,
    checkedTaxArrears: checkedTaxArrears,
    canJoinGuaranteeInsurance: canJoinGuaranteeInsurance,
    willReportMoveIn: willReportMoveIn,
    willGetFixedDate: willGetFixedDate,
  );
}

void main() {
  final calculator = JeonseRiskCalculator();

  test('결과가 문자열이 아닌 코드 리스트를 담는다', () {
    final result = calculator.calculate(buildInput());
    expect(result.warnings, isA<List<JeonseRiskWarning>>());
    expect(result.checklist, isA<List<JeonseRiskCheck>>());
    expect(result.actionItems, isA<List<JeonseRiskAction>>());
    expect(result.protectionChecklist, isA<List<JeonseProtectionStep>>());
  });

  test('전세가율 90% 이상이면 해당 경고와 조치가 나온다', () {
    final result = calculator.calculate(buildInput(deposit: 190000000));
    expect(result.warnings, contains(JeonseRiskWarning.jeonseRatioOver90));
    expect(result.actionItems,
        contains(JeonseRiskAction.lowerDepositOrCheckInsurance));
  });

  test('전세가율 80%대면 80 경고만 나온다', () {
    final result = calculator.calculate(buildInput(deposit: 170000000));
    expect(result.warnings, contains(JeonseRiskWarning.jeonseRatioOver80));
    expect(result.warnings, isNot(contains(JeonseRiskWarning.jeonseRatioOver90)));
  });

  test('전세가율 70%대는 경고가 아니라 체크 항목이다', () {
    final result = calculator.calculate(buildInput(deposit: 150000000));
    expect(result.checklist, contains(JeonseRiskCheck.jeonseRatioOver70));
  });

  test('등기부 미확인이면 경고와 조치가 나온다', () {
    final result = calculator.calculate(buildInput(checkedRegistry: false));
    expect(result.warnings, contains(JeonseRiskWarning.registryUnchecked));
    expect(result.actionItems, contains(JeonseRiskAction.verifyRightsInRegistry));
  });

  test('보호 절차 체크리스트는 항상 3개다', () {
    expect(calculator.calculate(buildInput()).protectionChecklist, hasLength(3));
  });

  test('경고가 없으면 noMajorRisk 체크가 추가된다', () {
    final result = calculator.calculate(buildInput());
    expect(result.warnings, isEmpty);
    expect(result.checklist, contains(JeonseRiskCheck.noMajorRisk));
  });

  test('조치가 비면 최종 확인 조치가 들어간다', () {
    final result = calculator.calculate(buildInput());
    expect(result.actionItems, contains(JeonseRiskAction.finalCheckBeforeContract));
  });

  test('점수는 0~100이고 최악 조건은 high다', () {
    final worst = calculator.calculate(buildInput(
      deposit: 200000000,
      seniorDebt: 150000000,
      checkedRegistry: false,
      ownerMatched: false,
      checkedTaxArrears: false,
      canJoinGuaranteeInsurance: false,
      willReportMoveIn: false,
      willGetFixedDate: false,
    ));
    expect(worst.score, inInclusiveRange(0, 100));
    expect(worst.level, JeonseRiskLevel.high);
  });

  test('조치 목록에 중복이 없다', () {
    final result = calculator.calculate(
      buildInput(deposit: 190000000, seniorDebt: 100000000),
    );
    expect(result.actionItems.toSet().length, result.actionItems.length);
  });

  test('시세가 0이면 비율이 0이다', () {
    final result = calculator.calculate(buildInput(marketPrice: 0));
    expect(result.jeonseRatio, 0);
    expect(result.seniorDebtRatio, 0);
    expect(result.combinedDebtRatio, 0);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/domain/entities/jeonse_risk_codes_test.dart`
Expected: FAIL — `jeonse_risk_codes.dart` 없음

- [ ] **Step 3: enum 정의**

`lib/domain/entities/jeonse_risk_codes.dart`:

```dart
/// 전세사기 위험도 결과의 표시 항목 코드.
/// 도메인은 코드만 만들고 문장은 표현 계층이 지역화한다.

enum JeonseRiskWarning {
  jeonseRatioOver90,
  jeonseRatioOver80,
  seniorDebtOver50,
  seniorDebtOver30,
  combinedOver90,
  combinedOver80,
  registryUnchecked,
  ownerMismatch,
  guaranteeInsuranceUncertain,
  moveInNotPlanned,
  fixedDateNotPlanned,
}

enum JeonseRiskCheck {
  jeonseRatioOver70,
  seniorDebtExists,
  combinedOver70,
  taxArrearsUnchecked,
  noMajorRisk,
}

enum JeonseRiskAction {
  lowerDepositOrCheckInsurance,
  checkNearbyPricesAndInsuranceLimit,
  clearSeniorDebtBeforeBalance,
  verifySeniorDebtMaxAndClearance,
  holdOrRenegotiate,
  checkInsuranceAmountAndClearance,
  verifyRightsInRegistry,
  verifyProxyDocuments,
  requestTaxCertificate,
  checkGuaranteeEligibility,
  reconsiderIfNoMoveIn,
  reconsiderIfNoFixedDate,
  finalCheckBeforeContract,
}

enum JeonseProtectionStep {
  recheckRegistryOnClosing,
  reportMoveInAndFixedDate,
  addSpecialTerms,
}
```

- [ ] **Step 4: JeonseRiskResult 교체**

`lib/domain/entities/jeonse_risk_result.dart` 전체 교체:

```dart
import 'jeonse_risk_codes.dart';

enum JeonseRiskLevel {
  low,
  caution,
  high,
}

class JeonseRiskResult {
  final double jeonseRatio;
  final double seniorDebtRatio;
  final double combinedDebtRatio;
  final int score;
  final JeonseRiskLevel level;
  final List<JeonseRiskWarning> warnings;
  final List<JeonseRiskCheck> checklist;
  final List<JeonseRiskAction> actionItems;
  final List<JeonseProtectionStep> protectionChecklist;

  const JeonseRiskResult({
    required this.jeonseRatio,
    required this.seniorDebtRatio,
    required this.combinedDebtRatio,
    required this.score,
    required this.level,
    required this.warnings,
    required this.checklist,
    required this.actionItems,
    required this.protectionChecklist,
  });
}
```

`JeonseRiskLevelLabel` 확장과 `levelDescription`/`summaryText` 필드가 사라졌는지 확인한다.

- [ ] **Step 5: 계산기 교체**

`lib/domain/calculators/jeonse_risk_calculator.dart` 전체 교체:

```dart
import '../entities/jeonse_risk_codes.dart';
import '../entities/jeonse_risk_input.dart';
import '../entities/jeonse_risk_result.dart';

class JeonseRiskCalculator {
  JeonseRiskResult calculate(JeonseRiskInput input) {
    final jeonseRatio = _ratio(input.deposit, input.marketPrice);
    final seniorDebtRatio = _ratio(input.seniorDebt, input.marketPrice);
    final combinedDebtRatio =
        _ratio(input.deposit + input.seniorDebt, input.marketPrice);
    final warnings = <JeonseRiskWarning>[];
    final checklist = <JeonseRiskCheck>[];
    final actionItems = <JeonseRiskAction>[];
    const protectionChecklist = <JeonseProtectionStep>[
      JeonseProtectionStep.recheckRegistryOnClosing,
      JeonseProtectionStep.reportMoveInAndFixedDate,
      JeonseProtectionStep.addSpecialTerms,
    ];
    var score = 0;

    if (jeonseRatio >= 90) {
      score += 30;
      warnings.add(JeonseRiskWarning.jeonseRatioOver90);
      actionItems.add(JeonseRiskAction.lowerDepositOrCheckInsurance);
    } else if (jeonseRatio >= 80) {
      score += 20;
      warnings.add(JeonseRiskWarning.jeonseRatioOver80);
      actionItems.add(JeonseRiskAction.checkNearbyPricesAndInsuranceLimit);
    } else if (jeonseRatio >= 70) {
      score += 10;
      checklist.add(JeonseRiskCheck.jeonseRatioOver70);
    }

    if (seniorDebtRatio >= 50) {
      score += 25;
      warnings.add(JeonseRiskWarning.seniorDebtOver50);
      actionItems.add(JeonseRiskAction.clearSeniorDebtBeforeBalance);
    } else if (seniorDebtRatio >= 30) {
      score += 15;
      warnings.add(JeonseRiskWarning.seniorDebtOver30);
      actionItems.add(JeonseRiskAction.verifySeniorDebtMaxAndClearance);
    } else if (seniorDebtRatio > 0) {
      score += 8;
      checklist.add(JeonseRiskCheck.seniorDebtExists);
    }

    if (combinedDebtRatio >= 90) {
      score += 25;
      warnings.add(JeonseRiskWarning.combinedOver90);
      actionItems.add(JeonseRiskAction.holdOrRenegotiate);
    } else if (combinedDebtRatio >= 80) {
      score += 15;
      warnings.add(JeonseRiskWarning.combinedOver80);
      actionItems.add(JeonseRiskAction.checkInsuranceAmountAndClearance);
    } else if (combinedDebtRatio >= 70) {
      score += 8;
      checklist.add(JeonseRiskCheck.combinedOver70);
    }

    if (!input.checkedRegistry) {
      score += 10;
      warnings.add(JeonseRiskWarning.registryUnchecked);
      actionItems.add(JeonseRiskAction.verifyRightsInRegistry);
    }
    if (!input.ownerMatched) {
      score += 15;
      warnings.add(JeonseRiskWarning.ownerMismatch);
      actionItems.add(JeonseRiskAction.verifyProxyDocuments);
    }
    if (!input.checkedTaxArrears) {
      score += 10;
      checklist.add(JeonseRiskCheck.taxArrearsUnchecked);
      actionItems.add(JeonseRiskAction.requestTaxCertificate);
    }
    if (!input.canJoinGuaranteeInsurance) {
      score += 15;
      warnings.add(JeonseRiskWarning.guaranteeInsuranceUncertain);
      actionItems.add(JeonseRiskAction.checkGuaranteeEligibility);
    }
    if (!input.willReportMoveIn) {
      score += 10;
      warnings.add(JeonseRiskWarning.moveInNotPlanned);
      actionItems.add(JeonseRiskAction.reconsiderIfNoMoveIn);
    }
    if (!input.willGetFixedDate) {
      score += 10;
      warnings.add(JeonseRiskWarning.fixedDateNotPlanned);
      actionItems.add(JeonseRiskAction.reconsiderIfNoFixedDate);
    }

    score = score.clamp(0, 100);
    final level = score >= 60
        ? JeonseRiskLevel.high
        : score >= 30
            ? JeonseRiskLevel.caution
            : JeonseRiskLevel.low;

    if (warnings.isEmpty) {
      checklist.add(JeonseRiskCheck.noMajorRisk);
    }
    if (actionItems.isEmpty) {
      actionItems.add(JeonseRiskAction.finalCheckBeforeContract);
    }

    return JeonseRiskResult(
      jeonseRatio: jeonseRatio,
      seniorDebtRatio: seniorDebtRatio,
      combinedDebtRatio: combinedDebtRatio,
      score: score,
      level: level,
      warnings: warnings,
      checklist: checklist,
      actionItems: actionItems.toSet().toList(),
      protectionChecklist: protectionChecklist,
    );
  }

  double _ratio(int numerator, int denominator) {
    if (denominator <= 0) return 0;
    return numerator / denominator * 100;
  }
}
```

점수 가중치와 임계값은 **원본과 동일하게 유지**했다. 계산 결과가 달라지면 안 된다.

- [ ] **Step 6: 기존 테스트의 한글 단언 교체**

```bash
grep -n "[가-힣]" test/domain/calculators/jeonse_risk_calculator_test.dart
```

나오는 2건을 enum 비교로 바꾼다. 예: `expect(result.warnings, contains('전세가율이 90% 이상입니다. 보증보험 가입이 어려울 수 있어요.'))` → `expect(result.warnings, contains(JeonseRiskWarning.jeonseRatioOver90))`. 파일 상단에 `import 'package:house_money_calculator/domain/entities/jeonse_risk_codes.dart';`를 추가한다.

- [ ] **Step 7: 통과 확인**

```bash
flutter test test/domain/entities/jeonse_risk_codes_test.dart
flutter test test/domain/calculators/jeonse_risk_calculator_test.dart
```

Expected: 둘 다 PASS

- [ ] **Step 8: 커밋**

```bash
git add lib/domain/entities/jeonse_risk_codes.dart lib/domain/entities/jeonse_risk_result.dart lib/domain/calculators/jeonse_risk_calculator.dart test/domain/entities/jeonse_risk_codes_test.dart test/domain/calculators/jeonse_risk_calculator_test.dart
git commit -m "refactor: 전세위험 계산기가 한글 문자열 대신 코드 enum을 반환

도메인이 표시 문자열을 만들지 않도록 계층을 분리한다."
```

---

## Task 13: 나머지 계산기 5개 enum 리팩터링

**Files:**
- Modify: `lib/domain/calculators/monthly_expense_calculator.dart` (한글 8)
- Modify: `lib/domain/calculators/tax_deduction_calculator.dart` (4)
- Modify: `lib/domain/calculators/semi_rent_calculator.dart` (4)
- Modify: `lib/domain/calculators/rent_compare_calculator.dart` (4)
- Modify: `lib/domain/calculators/contract_renewal_calculator.dart` (3)
- Modify: 각 계산기가 반환하는 엔티티 파일
- Modify: `test/domain/calculators/rent_compare_calculator_test.dart`(한글 22), `semi_rent_calculator_test.dart`(9), `monthly_expense_calculator_test.dart`(6), `loan_interest_calculator_test.dart`(6), `contract_renewal_calculator_test.dart`(1)

**Interfaces:**
- Consumes: Task 12에서 확립한 패턴
- Produces: `lib/domain` 전체에 한글 문자열 리터럴 0건. 각 계산기마다 결과 코드 enum이 생긴다. enum 이름과 값은 각 파일의 실제 한글 문자열을 보고 정하되, Task 12과 같은 명명 규칙을 따른다 — 조건을 서술하는 lowerCamelCase.

파일마다 아래 순서를 반복한다. 한 파일을 끝낼 때마다 커밋한다.

- [ ] **Step 1: 대상 파일의 한글 문자열과 발생 조건 파악**

```bash
grep -noE "'[^']*[가-힣][^']*'" lib/domain/calculators/monthly_expense_calculator.dart
```

각 문자열이 어떤 분기에서 나오는지 읽는다. **조건 하나당 enum 값 하나**를 만든다.

- [ ] **Step 2: enum을 해당 엔티티 파일에 추가**

파일이 작으므로 별도 파일을 만들지 않고 엔티티 파일 안에 함께 둔다. Task 12의 `jeonse_risk_codes.dart`와 같은 형태다.

- [ ] **Step 3: 실패 테스트 먼저 작성**

해당 계산기 테스트 파일에 enum 반환을 기대하는 단언을 추가한다. 예:

```dart
test('결과 코드가 문자열이 아니다', () {
  final result = MonthlyExpenseCalculator().calculate(/* 기존 테스트의 입력 재사용 */);
  expect(result.notes, isA<List<MonthlyExpenseNote>>());
});
```

Run 해서 FAIL을 확인한다.

- [ ] **Step 4: 계산기가 enum을 반환하도록 수정**

문자열 리터럴을 대응 enum 값으로 바꾼다. **계산 로직(숫자)은 건드리지 않는다.**

- [ ] **Step 5: 기존 테스트의 한글 단언을 enum 비교로 교체**

```bash
grep -n "[가-힣]" test/domain/calculators/rent_compare_calculator_test.dart
```

각 단언을 바꾼다. **숫자 단언은 그대로 둔다** — 계산 결과 불변을 보증하는 회귀 테스트다.

- [ ] **Step 6: 파일 단위 커밋**

```bash
git add lib/domain test/domain
git commit -m "refactor: <계산기명>이 코드 enum을 반환하도록 변경"
```

- [ ] **Step 7: 5개 파일을 모두 끝낸 뒤 도메인 전체 검증**

```bash
grep -rhoE "'[^']*[가-힣][^']*'" lib/domain --include='*.dart' | wc -l
flutter test test/domain/
```

Expected: grep 결과 `0`, 도메인 테스트 전부 PASS

0이 아니면 남은 파일을 찾아 마저 처리한다:

```bash
grep -rlE "'[^']*[가-힣][^']*'" lib/domain --include='*.dart'
```

---

## Task 14: PDF 내보내기 지역화 시그니처

**Files:**
- Modify: `lib/core/utils/calculation_pdf_exporter.dart` (한글 7)
- Test: `test/core/utils/calculation_pdf_exporter_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces: `class PdfExportLabels` — PDF에 찍히는 고정 문구를 담는 값 객체. 내보내기 메서드가 `required PdfExportLabels labels`를 받는다. 클래스 안에 한글 문자열 리터럴이 0건이 된다.

- [ ] **Step 1: 현재 한글 문자열과 용도 파악**

```bash
grep -noE "'[^']*[가-힣][^']*'" lib/core/utils/calculation_pdf_exporter.dart
```

7건이 나온다. 각각이 PDF의 어느 부분(문서 제목, 생성일 라벨, 면책 문구 등)인지 읽고 `PdfExportLabels`의 필드 이름을 정한다. **아래 3개 필드는 예시이며, 실제 7건의 용도에 맞춰 필드 수를 늘린다.**

- [ ] **Step 2: 실패 테스트 작성**

`test/core/utils/calculation_pdf_exporter_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/utils/calculation_pdf_exporter.dart';

void main() {
  test('내보내기 라벨은 호출부가 주입한다', () {
    const labels = PdfExportLabels(
      documentTitle: 'Calculation Result',
      generatedAtLabel: 'Generated at',
      disclaimer: 'This is a reference estimate.',
    );

    expect(labels.documentTitle, 'Calculation Result');
    expect(labels.generatedAtLabel, 'Generated at');
    expect(labels.disclaimer, 'This is a reference estimate.');
  });
}
```

Step 1에서 정한 실제 필드에 맞춰 이 테스트를 조정한다.

- [ ] **Step 3: 실패 확인**

Run: `flutter test test/core/utils/calculation_pdf_exporter_test.dart`
Expected: FAIL — `PdfExportLabels` 미정의

- [ ] **Step 4: 구현**

`calculation_pdf_exporter.dart` 상단에 값 객체를 추가한다.

```dart
/// PDF에 찍히는 고정 문구. 지역화는 호출부(표현 계층)가 담당한다.
class PdfExportLabels {
  final String documentTitle;
  final String generatedAtLabel;
  final String disclaimer;

  const PdfExportLabels({
    required this.documentTitle,
    required this.generatedAtLabel,
    required this.disclaimer,
  });
}
```

내보내기 메서드 시그니처에 `required PdfExportLabels labels`를 추가하고, 본문의 한글 리터럴을 `labels.*` 참조로 바꾼다.

- [ ] **Step 5: 통과 확인**

```bash
flutter test test/core/utils/calculation_pdf_exporter_test.dart
grep -coE "'[^']*[가-힣][^']*'" lib/core/utils/calculation_pdf_exporter.dart
```

Expected: 테스트 PASS, grep 결과 `0`

- [ ] **Step 6: 커밋**

```bash
git add lib/core/utils/calculation_pdf_exporter.dart test/core/utils/calculation_pdf_exporter_test.dart
git commit -m "refactor: PDF 내보내기 문구를 호출부 주입 방식으로 변경"
```

---

## Task 15: ARB 프래그먼트 병합기

**Files:**
- Create: `tool/merge_arb.dart`
- Test: `test/tool/merge_arb_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces:
  - `typedef ArbFragment = ({String name, Map<String, dynamic> content});`
  - `Map<String, dynamic> mergeArb({required Map<String, dynamic> base, required List<ArbFragment> fragments, required Set<String> allowedNamespaces})`
  - `class ArbMergeException implements Exception` — `final String message`
  - `Future<void> main()` — `lib/l10n/fragments/*.{ko,en}.arb`를 읽어 `lib/l10n/app_{ko,en}.arb`에 병합

- [ ] **Step 1: 실패 테스트 작성**

`test/tool/merge_arb_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import '../../tool/merge_arb.dart';

void main() {
  const namespaces = {'common', 'history', 'settings'};

  test('프래그먼트 키를 베이스에 합친다', () {
    final result = mergeArb(
      base: {'@@locale': 'ko', 'commonCancel': '취소'},
      fragments: [
        (name: 's03', content: {'historyEmptyMessage': '이력이 없습니다'}),
      ],
      allowedNamespaces: namespaces,
    );

    expect(result['commonCancel'], '취소');
    expect(result['historyEmptyMessage'], '이력이 없습니다');
    expect(result['@@locale'], 'ko');
  });

  test('두 프래그먼트가 같은 키를 만들면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03', content: {'historyTitle': '이력'}),
          (name: 's04', content: {'historyTitle': '기록'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('프래그먼트가 베이스의 common 키를 덮어쓰면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko', 'commonCancel': '취소'},
        fragments: [
          (name: 's03', content: {'commonCancel': '취소하기'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('프래그먼트가 새 common 키를 만들면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03', content: {'commonWhatever': '뭔가'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('알 수 없는 네임스페이스면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03', content: {'unknownThing': '값'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('@ 메타 키도 함께 병합된다', () {
    final result = mergeArb(
      base: {'@@locale': 'ko'},
      fragments: [
        (
          name: 's03',
          content: {
            'historyTitle': '이력',
            '@historyTitle': {'description': '이력 화면 제목'},
          }
        ),
      ],
      allowedNamespaces: namespaces,
    );

    expect(result['@historyTitle'], isA<Map>());
  });

  test('에러 메시지에 프래그먼트 이름과 키가 들어간다', () {
    try {
      mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03_history', content: {'badKey': '값'}),
        ],
        allowedNamespaces: namespaces,
      );
      fail('예외가 발생해야 한다');
    } on ArbMergeException catch (e) {
      expect(e.message, contains('s03_history'));
      expect(e.message, contains('badKey'));
    }
  });

  test('프래그먼트가 없으면 베이스를 그대로 반환한다', () {
    final result = mergeArb(
      base: {'@@locale': 'ko', 'commonCancel': '취소'},
      fragments: [],
      allowedNamespaces: namespaces,
    );

    expect(result, {'@@locale': 'ko', 'commonCancel': '취소'});
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/tool/merge_arb_test.dart`
Expected: FAIL — `tool/merge_arb.dart` 없음

- [ ] **Step 3: 구현**

`tool/merge_arb.dart`:

```dart
import 'dart:convert';
import 'dart:io';

class ArbMergeException implements Exception {
  final String message;
  ArbMergeException(this.message);

  @override
  String toString() => 'ArbMergeException: $message';
}

typedef ArbFragment = ({String name, Map<String, dynamic> content});

/// 베이스 ARB에 슬라이스 프래그먼트를 합친다.
/// 중복 키, 네임스페이스 위반, common 키 재정의는 경고가 아니라 에러다.
Map<String, dynamic> mergeArb({
  required Map<String, dynamic> base,
  required List<ArbFragment> fragments,
  required Set<String> allowedNamespaces,
}) {
  final merged = Map<String, dynamic>.from(base);
  final owner = <String, String>{for (final key in base.keys) key: 'base'};

  for (final fragment in fragments) {
    for (final entry in fragment.content.entries) {
      final key = entry.key;
      if (key.startsWith('@@')) continue;

      final plainKey = key.startsWith('@') ? key.substring(1) : key;
      _checkNamespace(fragment.name, plainKey, allowedNamespaces);

      if (owner.containsKey(key)) {
        throw ArbMergeException(
          '중복 키 "$key": ${owner[key]}와 ${fragment.name}이 모두 정의했다.',
        );
      }

      merged[key] = entry.value;
      owner[key] = fragment.name;
    }
  }

  return merged;
}

void _checkNamespace(
  String fragmentName,
  String key,
  Set<String> allowedNamespaces,
) {
  if (key.startsWith('common')) {
    throw ArbMergeException(
      '$fragmentName의 "$key": common 네임스페이스는 베이스 ARB에서만 정의한다. '
      '슬라이스는 자기 feature 네임스페이스를 써야 한다.',
    );
  }

  final matched = allowedNamespaces
      .any((ns) => ns != 'common' && key.startsWith(ns));
  if (!matched) {
    throw ArbMergeException(
      '$fragmentName의 "$key": 허용되지 않은 네임스페이스다. '
      '허용 목록: ${allowedNamespaces.join(", ")}',
    );
  }
}

const _namespaces = {
  'common',
  'app',
  'settings',
  'guide',
  'history',
  'auth',
  'onboarding',
  'jeonseRisk',
  'rentCompare',
  'semiRent',
  'home',
  'scenarioCompare',
  'contractRenewal',
  'monthlyExpense',
  'loanInterest',
  'taxDeduction',
  'advanced',
  'admin',
  'shared',
  'validation',
  'pdf',
  'notification',
};

Future<void> main() async {
  for (final locale in ['ko', 'en']) {
    final baseFile = File('lib/l10n/app_$locale.arb');
    final base =
        jsonDecode(await baseFile.readAsString()) as Map<String, dynamic>;

    final dir = Directory('lib/l10n/fragments');
    final fragments = <ArbFragment>[];

    if (dir.existsSync()) {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.$locale.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final content =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        fragments.add((name: file.uri.pathSegments.last, content: content));
      }
    }

    final merged = mergeArb(
      base: base,
      fragments: fragments,
      allowedNamespaces: _namespaces,
    );

    await baseFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(merged)}\n',
    );
    stdout.writeln('$locale: ${fragments.length}개 프래그먼트 병합 완료');
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/tool/merge_arb_test.dart`
Expected: PASS (8개 테스트)

- [ ] **Step 5: 프래그먼트 디렉터리와 용어집 생성**

슬라이스가 쓸 자리를 미리 만들어 둔다. 빈 디렉터리는 git이 추적하지 않으므로 `.gitkeep`을 둔다.

```bash
mkdir -p lib/l10n/fragments
touch lib/l10n/fragments/.gitkeep
```

`lib/l10n/glossary.md`:

```markdown
# 부동산·법률 용어집 (ko → en)

Phase 1의 각 슬라이스는 오역이 사용자 피해로 이어질 수 있는 용어를 만나면
번역을 확정하지 말고 **이 표에 행을 추가**한다. en 프래그먼트에는 잠정 번역을
넣고, 확정은 Phase 2의 검수 게이트에서 일괄 처리한다.

모든 슬라이스가 이 파일을 공유하므로 **append만 한다.**
기존 행을 수정하거나 재정렬하지 않는다.

| 한국어 | 영어(후보) | 맥락 | 사용 키 | 확정 |
|---|---|---|---|---|
```

- [ ] **Step 6: 프래그먼트 없는 상태에서 실행해도 안전한지 확인**

```bash
dart run tool/merge_arb.dart
git diff --stat lib/l10n/
```

Expected: `ko: 0개 프래그먼트 병합 완료` / `en: 0개 ...`. `git diff`는 들여쓰기 정규화만 보여야 하고 키가 사라지면 안 된다.

`.gitkeep`은 `.arb` 확장자가 아니므로 병합기가 무시한다.

- [ ] **Step 7: 커밋**

```bash
git add tool/merge_arb.dart test/tool/merge_arb_test.dart lib/l10n/
git commit -m "feat: 슬라이스 ARB 프래그먼트 병합기와 용어집 틀 추가

중복 키와 네임스페이스 위반을 에러로 중단시켜 병렬 작업의 키 충돌을 막는다."
```

---

## Task 16: 잔여 스캔 스크립트

**Files:**
- Create: `tool/check_hardcoded.sh`

**Interfaces:**
- Consumes: 없음
- Produces: 실행 가능한 스크립트. 위반이 있으면 exit 1, 없으면 exit 0.

- [ ] **Step 1: 스크립트 작성**

`tool/check_hardcoded.sh`:

```bash
#!/usr/bin/env bash
# 다크모드/i18n 전환 잔여물 검사.
# Phase 1이 끝나면 모든 항목이 0이어야 한다.
set -uo pipefail

fail=0

report() {
  local label="$1"
  local hits="$2"
  echo "== $label =="
  if [ -n "$hits" ]; then
    echo "$hits" | head -40
    echo "위반: $(echo "$hits" | wc -l | tr -d ' ')건"
    fail=1
  else
    echo "0건"
  fi
  echo
}

report "AppColors 직접 참조 (팔레트 정의부 제외)" "$(
  grep -rn "AppColors\." lib/ --include='*.dart' \
    | grep -v "lib/core/theme/app_colors.dart" \
    | grep -v "lib/core/theme/app_palette.dart" \
    || true
)"

report "AppTextStyles 참조" "$(
  grep -rn "AppTextStyles\." lib/ --include='*.dart' || true
)"

report "한글 문자열 리터럴 (legal_texts.dart, l10n 제외)" "$(
  grep -rnoE "'[^']*[가-힣][^']*'" lib/ --include='*.dart' \
    | grep -v "lib/core/constants/legal_texts.dart" \
    | grep -v "lib/l10n/" \
    || true
)"

report "lib/domain 한글 리터럴" "$(
  grep -rnoE "'[^']*[가-힣][^']*'" lib/domain --include='*.dart' || true
)"

if [ "$fail" -eq 0 ]; then
  echo "통과: 잔여물 없음"
else
  echo "실패: 위 항목을 해소해야 한다"
fi
exit "$fail"
```

- [ ] **Step 2: 실행 권한 부여 및 확인**

```bash
chmod +x tool/check_hardcoded.sh
./tool/check_hardcoded.sh
```

Expected: **exit 1**. AppColors·AppTextStyles·한글 리터럴이 다수 보고되고, **`lib/domain 한글 리터럴`만 0건**이어야 한다.

domain이 0건이 아니면 Task 13이 미완이므로 돌아가서 마무리한다.

**이 스크립트가 exit 1인 것은 Phase 0에서 정상이다.** shim 방식을 택했으므로 `AppTextStyles` 정의부(위임 shim)와 `Validators`의 구형 메서드에 든 한글이 그대로 남아 있다. 이 스크립트는 Phase 0의 합격 기준이 아니라 **Phase 1의 진행률 계기판**이다. Phase 0의 빌드 합격 기준은 `flutter analyze`의 error 0건이며, 그건 Task 18이 검사한다.

- [ ] **Step 3: 커밋**

```bash
git add tool/check_hardcoded.sh
git commit -m "chore: 다크모드/i18n 전환 잔여물 검사 스크립트 추가"
```

---

## Task 17: 슬라이스 계약서 작성

**Files:**
- Create: `docs/superpowers/specs/2026-07-31-slice-contract.md`

**Interfaces:**
- Consumes: Task 1-16의 모든 산출물
- Produces: Phase 1의 10개 에이전트가 콜드 스타트할 수 있는 단일 문서

- [ ] **Step 1: 실제 API 이름 대조**

```bash
grep -n "class AppPalette\|get palette" lib/core/theme/app_palette.dart
grep -n "class AppTypography\|get typography" lib/core/theme/app_typography.dart
grep -oE '"(common|settings|app)[A-Za-z]+"' lib/l10n/app_ko.arb | sort -u
grep -n "^const _namespaces" -A 25 tool/merge_arb.dart
```

계약서에 적는 이름이 실제 코드와 다르면 10개 슬라이스가 전부 존재하지 않는 API를 대상으로 작업한다. **반드시 대조한다.**

- [ ] **Step 2: 계약서 작성**

`docs/superpowers/specs/2026-07-31-slice-contract.md`에 아래 항목을 담는다. 각 항목은 예시가 아니라 **Step 1에서 확인한 실제 값**으로 채운다.

1. **전제** — Phase 0 완료 상태에서 시작한다. 담당 파일 외에는 건드리지 않는다.
2. **치환 패턴 2종**
   - `AppColors.<name>` → `context.palette.<name>` (이름 10개 동일)
   - `AppTextStyles.<name>` → `context.typography.<name>` (이름 10개 동일)
   - `context`가 없는 곳(정적 메서드, 위젯 트리 밖)은 팔레트를 인자로 넘기거나 `Builder`로 감싼다
3. **문자열 추출 규칙**
   - 사용자에게 보이는 모든 한글 → ARB 키
   - 키 형식: `<namespace><PascalCaseName>`. namespace는 `tool/merge_arb.dart`의 `_namespaces` 목록에 있는 것만 (Step 1에서 확인한 실제 목록을 옮겨 적는다)
   - `common*` 키는 **새로 만들지 않는다.** 베이스의 7개만 쓴다: `commonCancel` `commonConfirm` `commonSave` `commonDelete` `commonClose` `commonRetry` `commonError`
   - 변수가 들어가는 문장은 ARB `placeholders` 메타를 쓴다
4. **프래그먼트 경로** — `lib/l10n/fragments/<슬라이스ID>_<이름>.ko.arb`와 `.en.arb`. 자기 슬라이스 파일 외에는 쓰지 않는다
5. **수정 금지 파일**
   - `lib/core/constants/legal_texts.dart`
   - `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb` (베이스 — 프래그먼트만 쓴다)
   - `lib/l10n/gen/` (생성물)
   - `**/*.g.dart`
   - `lib/core/theme/`, `lib/core/settings/` (Phase 0 소유)
   - `lib/features/settings/theme_locale_section.dart` (Phase 0에서 완성)
6. **번역 톤** — 한국 거주 외국인 대상. 평이한 영어. 한국 특유 개념은 짧은 설명을 덧붙인다
7. **용어집 등록 규칙** — 부동산·법률 용어를 만나면 `lib/l10n/glossary.md`에 행을 추가하고 en 프래그먼트에는 잠정 번역을 넣는다. 형식:

   ```markdown
   | 한국어 | 영어(후보) | 맥락 | 사용 키 | 확정 |
   |---|---|---|---|---|
   | 확정일자 | fixed date confirmation | 임대차 신고 | jeonseRiskFixedDate | ☐ |
   ```

   `glossary.md`는 모든 슬라이스가 공유하므로 **append만 한다.** 기존 행을 수정하거나 재정렬하지 않는다.
8. **저장 데이터 불변** — `lib/data/models/calculation_history.dart`의 저장 값 포맷을 바꾸지 않는다. 지역화는 표시 시점에만.
9. **완료 기준** — 담당 파일 범위에서:
   - `grep -n "AppColors\." <파일들>` → 0건
   - `grep -n "AppTextStyles\." <파일들>` → 0건
   - `grep -noE "'[^']*[가-힣][^']*'" <파일들>` → 0건
   - `flutter analyze`에서 담당 파일 관련 에러 0건
   - 해당 feature의 기존 테스트 통과 (한글 단언은 ARB 키 기반으로 교체)
10. **슬라이스 목록과 담당 파일** — 설계 문서 §4의 표를 옮기되, 각 슬라이스마다 **파일 전체 경로를 열거**한다. 경로 목록은 아래로 생성한다:

    ```bash
    find lib/features/history lib/features/auth -name '*.dart' | sort
    ```

- [ ] **Step 3: 계약서 자체 검증**

계약서만 읽고 슬라이스 하나를 수행할 수 있는지 점검한다. "무엇을 어떤 이름으로 바꾸는지"가 모호한 곳이 있으면 구체화한다.

- [ ] **Step 4: 커밋**

```bash
git add docs/superpowers/specs/2026-07-31-slice-contract.md
git commit -m "docs: Phase 1 슬라이스 계약서 추가"
```

---

## Task 18: Phase 0 마감 검증

**Files:** 없음 (검증만)

- [ ] **Step 1: Phase 0에서 만든 테스트 전체 통과**

```bash
flutter test test/core/ test/domain/ test/tool/ test/app_theme_locale_test.dart test/features/settings/theme_locale_section_test.dart
```

Expected: 모두 PASS

- [ ] **Step 2: 불변 보증 회귀 테스트 통과**

```bash
flutter test test/data/ test/core/utils/money_formatter_test.dart test/features/auth/
```

Expected: 모두 PASS. 실패하면 저장 포맷이나 ko 출력을 건드린 것이므로 되돌린다.

- [ ] **Step 3: 잔여 스캔 기준선 기록**

```bash
./tool/check_hardcoded.sh > /tmp/phase0_baseline.txt 2>&1 || true
tail -20 /tmp/phase0_baseline.txt
```

`lib/domain 한글 리터럴`이 **0건**임을 확인한다. 나머지 항목의 건수가 Phase 1의 시작 기준선이다.

- [ ] **Step 4: 빌드가 깨지지 않았는지 확인 (Phase 0의 핵심 합격 기준)**

```bash
flutter analyze 2>&1 | grep -E "^\s*error" | head -20
```

Expected: **출력 없음.** error가 하나라도 있으면 Global Constraints 위반이므로 Phase 1로 넘어가기 전에 고친다.

```bash
echo "deprecation 잔여: $(flutter analyze 2>&1 | grep -c 'deprecated')"
```

이 수치가 Phase 1이 옮겨야 할 호출부의 규모다 (`AppTextStyles` 135곳 + `Validators` 38곳 근처).

- [ ] **Step 5: 앱이 실제로 실행되는지 확인**

```bash
flutter run -d $(flutter devices | grep -i android | head -1 | awk -F'•' '{print $2}' | tr -d ' ')
```

Android 기기(SM G973N)에서 실행한다. 확인할 것:

1. 앱이 정상 기동한다
2. 설정 화면에 **테마**와 **언어** 항목이 보인다
3. 테마를 **다크**로 바꾸면 즉시 반영되고, 앱을 껐다 켜도 유지된다
4. 언어를 **English**로 바꾸면 설정 화면의 테마/언어 라벨이 영어로 바뀐다

3·4번이 되면 Phase 0의 목표가 달성된 것이다. 아직 전환되지 않은 화면들이 다크모드에서 라이트 색으로 보이는 것은 **예상된 상태**다 — shim이 라이트 색을 반환하고 있기 때문이며 Phase 1에서 해소된다.

- [ ] **Step 6: Phase 1 계획 작성**

Phase 0이 끝나 실제 API 이름이 확정되었다. `writing-plans` 스킬로 Phase 1(슬라이스 10개) + Phase 2(통합) 계획을 작성한다. 입력은 이 계획의 산출물과 `docs/superpowers/specs/2026-07-31-slice-contract.md`다.

---

## 다음 계획

Phase 1과 Phase 2는 이 계획이 완료된 뒤 별도 문서로 작성한다. Phase 0이 확정하는 API 이름(`context.palette`, `context.typography`, ARB 네임스페이스 목록, 프래그먼트 경로 규칙)이 Phase 1 태스크의 전제이므로, 그것들이 실제로 존재하기 전에 Phase 1을 쓰면 추측에 기반한 계획이 된다.

Phase 1은 10개 슬라이스를 격리된 worktree에서 병렬 실행하고, Phase 2는 프래그먼트 병합 → 용어집 검수 게이트 → 잔여 스캔 → 대비 검증 → 리뷰 순으로 진행한다.

**Phase 0이 끝나면 앱은 빌드되고 실행된다.** 테마 3모드와 언어 2개 전환이 실제로 동작하고 재시작 후에도 유지된다. 다만 아직 전환되지 않은 화면은 다크모드에서 라이트 색으로 보인다 — `AppTextStyles` shim이 `AppPalette.light`를 반환하기 때문이며, 이는 컴파일 에러가 아니라 조용한 오작동이므로 다음 두 계기판으로 추적한다.

- `flutter analyze`의 deprecation 경고 수 (`AppTextStyles` 135곳 + `Validators` 38곳 근처)
- `tool/check_hardcoded.sh`의 exit 1과 잔여 건수

**Phase 1이 반드시 끝내야 할 정리 두 가지:**

1. 135곳을 `context.typography`로 옮긴 뒤 `lib/core/theme/app_text_styles.dart` **삭제**
2. 38곳의 tear-off를 `(v) => Validators.*Code(v)?.localize(context)`로 옮긴 뒤 `Validators`의 `@Deprecated` 메서드 4개 **삭제**하고 `*Code` 접미사를 떼는 기계적 리네임

이 둘이 끝나야 `tool/check_hardcoded.sh`가 exit 0이 된다.
