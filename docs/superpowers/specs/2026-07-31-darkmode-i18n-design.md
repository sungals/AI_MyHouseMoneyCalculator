# 다크모드 + 다국어(ko/en) 설계

- 작성일: 2026-07-31
- 브랜치 기준: `codex/guide-update`
- 상태: 승인됨 (구현 계획 수립 대기)

## 1. 목표와 배경

앱은 현재 라이트 테마·한국어 단일 언어로만 동작한다. 두 가지를 함께 도입한다.

1. **다크모드** — 시스템/라이트/다크 3지선다
2. **다국어(한국어 + 영어)** — 대상 사용자는 **한국 거주 외국인**

대상 사용자를 한국 거주 외국인으로 잡았기 때문에, 영어화의 핵심 가치는 계산기 UI 자체가 아니라 **전세·반전세·확정일자 같은 한국 특유 개념의 설명**에 있다. 따라서 앱 사용법 가이드가 번역 범위에 반드시 포함된다.

### 실측 규모

| 항목 | 수치 |
|---|---|
| `AppColors.` 직접 참조 | 355곳 |
| `AppTextStyles.` 참조 (색상이 박제된 const) | 135곳 |
| 다크모드 전환 총 면적 | **약 490곳** |
| 한글 문자열 리터럴 | 1040개 / 118개 중 63개 파일 |
| 번역 대상 (약관 49개 제외) | **약 990개** |

## 2. 범위

### 포함

- 다크모드 전체 (모든 화면, 약 490개 전환 지점)
- 영어 번역: 계산기 11종, 홈, 설정, 이력, 인증, 온보딩, **앱 사용법 가이드**
- 테마·언어 설정 UI 및 영속화
- 도메인 계층의 표시 문자열 반환 구조 리팩터링

### 제외 (YAGNI)

- **약관·개인정보처리방침 번역** — `lib/core/constants/legal_texts.dart`(49개)는 법적 원문이므로 한국어 유지
- RTL 레이아웃
- 3번째 언어
- 다크모드 전용 이미지/아이콘 에셋
- Firestore에 저장된 공지사항 **콘텐츠** 번역 (서버 데이터, 별건)
- 골든 테스트

## 3. 기반 구조

### 3.1 색상 토큰 — `ThemeExtension`

`AppColors`의 시맨틱 이름 10개를 **그대로 유지**한다. `positive`/`warning`/`danger`/`cardBorder`는 Material 3 `ColorScheme`에 대응 슬롯이 없으므로 `ColorScheme`으로 흡수시키지 않는다.

```
lib/core/theme/app_colors.dart    raw const 값. light/dark 두 세트를 보유
lib/core/theme/app_palette.dart   AppPalette extends ThemeExtension<AppPalette>
                                  .light / .dark 인스턴스, copyWith, lerp
                                  BuildContext.palette 확장 게터
```

**치환 패턴은 단 하나다.**

```dart
AppColors.textPrimary        →  context.palette.textPrimary
```

이 선택의 근거는 미학이 아니라 **병렬화 가능성**이다. 시맨틱 이름을 유지하면 490곳의 수정이 전부 기계적 치환이 되고, 판단이 개입하지 않으므로 여러 에이전트가 동시에 작업해도 결과가 수렴한다. `ColorScheme` 롤로 재매핑하는 방식은 490번의 개별 판단을 요구하여 병렬 작업 시 일관성이 붕괴한다.

**예외** — `app_theme.dart` 내부에서 `ThemeData`를 조립할 때는 `context`가 없으므로 raw 상수를 직접 참조한다. 이는 정상이며 잔여 스캔에서 제외한다.

#### 다크 팔레트

Phase 0에서 WCAG AA(본문 대비 4.5:1, 큰 텍스트 3:1)를 검증한 뒤 확정한다. 아래는 초안이다.

| 토큰 | light | dark |
|---|---|---|
| `primary` | `#1F4FFF` | `#7C9CFF` |
| `background` | `#F7F8FA` | `#0F1115` |
| `surface` | `#FFFFFF` | `#181B21` |
| `textPrimary` | `#111827` | `#F3F4F6` |
| `textSecondary` | `#6B7280` | `#9CA3AF` |
| `positive` | `#16A34A` | `#4ADE80` |
| `warning` | `#F59E0B` | `#FBBF24` |
| `danger` | `#DC2626` | `#F87171` |
| `divider` | `#E5E7EB` | `#2A2F3A` |
| `cardBorder` | `#F3F4F6` | `#232833` |

`primary`의 원색 `#1F4FFF`는 어두운 배경에서 대비가 부족하므로 다크에서 밝은 변형을 쓴다.

### 3.2 타이포그래피 — `ThemeExtension`

`AppTextStyles`의 10개 스타일은 전부 `static const TextStyle(color: AppColors.…)` 형태로 **색이 박제**되어 있다. `const`이므로 `Theme.of(context)` 주입이 문법적으로 불가능하다. 색상과 동일하게 `ThemeExtension`으로 전환한다.

```
lib/core/theme/app_typography.dart   AppTypography extends ThemeExtension<AppTypography>
                                     10개 TextStyle을 AppPalette로부터 조립
                                     BuildContext.typography 확장 게터
```

**치환 패턴:**

```dart
AppTextStyles.heading1       →  context.typography.heading1
```

대상 스타일: `heading1` `heading2` `heading3` `resultAmount` `resultAmountPositive` `body` `bodySecondary` `label` `caption` `disclaimer`

색을 단순히 제거하고 상속에 맡기는 방식은 채택하지 않는다. `bodySecondary`/`label`/`caption`/`disclaimer`는 `textSecondary`, `resultAmount`는 `primary`, `resultAmountPositive`는 `positive`로 서로 다른 색을 갖고 있어, 상속에 맡기면 135곳에서 색이 조용히 바뀐다.

### 3.3 i18n 배선

Flutter 공식 `gen_l10n`을 사용한다. `intl: ^0.19.0`이 이미 의존성에 있으므로 신규 런타임 의존성은 SDK 제공 `flutter_localizations`뿐이다.

```
l10n.yaml                  arb-dir: lib/l10n
                           template-arb-file: app_ko.arb
                           output-localization-file: app_localizations.dart
                           synthetic-package: false
                           output-dir: lib/l10n/gen
pubspec.yaml               dependencies: flutter_localizations (sdk: flutter)
                           flutter: generate: true
lib/l10n/app_ko.arb        템플릿 (원본)
lib/l10n/app_en.arb
lib/l10n/fragments/        슬라이스별 ARB 프래그먼트 (5.1절)
lib/l10n/glossary.md       용어집 — 사용자 검수 게이트 산출물
tool/merge_arb.dart        프래그먼트 병합기
```

ARB 프래그먼트 형식:

```json
{
  "@@locale": "ko",
  "historyEmptyMessage": "저장된 계산 이력이 없습니다",
  "@historyEmptyMessage": { "description": "이력 목록이 비었을 때" },
  "historyItemCount": "{count}건",
  "@historyItemCount": {
    "placeholders": { "count": { "type": "int" } }
  }
}
```

### 3.4 설정 상태

기존 Hive `app_settings` 박스를 재사용한다. 이 박스는 `main.dart`에서 `runApp` 전에 이미 열리므로 추가 초기화가 필요 없다.

```
lib/core/settings/theme_mode_notifier.dart   키 'theme_mode'  값 system|light|dark  (기본 system)
lib/core/settings/locale_notifier.dart       키 'locale'      값 system|ko|en       (기본 system)
```

두 notifier 모두 Riverpod. 기존 코드베이스가 `flutter_riverpod`을 쓰고 있으므로 패턴을 따른다. 기존 키(`login_skipped`, `onboarding_done`, PIN·생체·공지 관련)는 변경하지 않는다.

### 3.5 `app.dart` 배선

`MaterialApp.router`에 다음을 추가한다.

- `darkTheme: AppTheme.dark`
- `themeMode:` — `themeModeNotifierProvider` 구독
- `locale:` — `localeNotifierProvider` 구독 (system이면 `null`)
- `localizationsDelegates:` — `AppLocalizations.localizationsDelegates`
- `supportedLocales:` — `[Locale('ko'), Locale('en')]`
- `localeResolutionCallback:` — 미지원 로케일은 `ko`로 폴백

기존 `title: '어떤비용'`은 상수라 로케일을 따라가지 못하므로 **`onGenerateTitle`로 교체**한다.

### 3.6 도메인 계층 리팩터링

계산기 7개 파일이 사용자 표시용 한글을 직접 반환하고 있다. ARB 접근에는 `BuildContext`가 필요하므로 도메인이 문자열을 만들 수 없다.

| 파일 | 한글 리터럴 |
|---|---|
| `lib/domain/calculators/jeonse_risk_calculator.dart` | 36 |
| `lib/domain/calculators/monthly_expense_calculator.dart` | 8 |
| `lib/domain/calculators/tax_deduction_calculator.dart` | 4 |
| `lib/domain/calculators/semi_rent_calculator.dart` | 4 |
| `lib/domain/calculators/rent_compare_calculator.dart` | 4 |
| `lib/domain/entities/jeonse_risk_result.dart` | 3 |
| `lib/domain/calculators/contract_renewal_calculator.dart` | 3 |

**도메인은 타입 코드(enum)를 반환하고, 표현 계층이 enum → 지역화 문자열로 매핑한다.** 이는 i18n을 위한 우회가 아니라 그 자체로 계층 분리를 바로잡는 개선이다. 리팩터링 후 `lib/domain` 전체에 한글 리터럴이 0개가 되어야 한다.

매핑은 각 feature의 표현 계층에 확장 메서드로 둔다. 예: `lib/features/jeonse_risk/jeonse_risk_l10n.dart`.

### 3.7 별도 취급이 필요한 지점

| 파일 | 문제 | 처리 |
|---|---|---|
| `lib/core/utils/money_formatter.dart` | "억", "만원" 단위. 한국식 만 단위 체계는 영어에 직역되지 않음 | 로케일별 포맷 전략 분기. **규칙 3가지: (a) ko 출력은 현행과 바이트 단위로 동일할 것, (b) en 출력에 억/만 단위를 쓰지 않고 서구식 K/M/B 단위를 쓸 것, (c) 통화는 KRW로 고정하고 환율 변환을 하지 않을 것.** 구체 포맷(예: `1.2억` → `KRW 120M`)은 Phase 0에서 확정해 계약서에 명시한다 |
| `lib/core/extensions/number_format_extension.dart` | 위와 동일 계열 | `money_formatter`와 같은 전략 사용 |
| `lib/core/utils/validators.dart` | 검증 에러 메시지 7개. validator에 `BuildContext`가 없음 | 에러 코드(enum) 반환으로 변경, 표시 시점에 지역화 |
| `lib/core/utils/calculation_pdf_exporter.dart` | PDF 출력물 문자열 7개 | 호출부에서 지역화된 문자열을 주입받도록 시그니처 변경 |
| `lib/data/models/calculation_history.dart` | 한글 10개. 저장된 이력의 표시 라벨 | **저장 값은 건드리지 않는다.** 기존 저장 데이터와의 호환이 깨지므로 표시 시점에만 매핑 |
| `lib/core/constants/legal_texts.dart` | 약관 원문 49개 | **수정 금지.** 한국어 유지 |

`calculation_history.dart`는 특히 주의한다. 이미 사용자 기기에 저장된 이력 레코드가 존재하므로, 저장 포맷을 바꾸면 기존 데이터가 깨진다.

## 4. 슬라이스 분할

부하 지표 = `AppColors 참조 + AppTextStyles 참조 + 한글 리터럴`

| 슬라이스 | 담당 경로 | 부하 |
|---|---|---|
| **S1** | `lib/features/settings/app_guide_screen.dart` 단독 | 206 |
| **S2** | `lib/features/settings/` 나머지 5파일 (`settings_screen`, `account_manage_screen`, `notices_screen`, `notice_detail_screen`, `legal_document_screen`) | 95 |
| **S3** | `lib/features/history/` | 147 |
| **S4** | `lib/features/auth/` (12파일) | 134 |
| **S5** | `lib/features/onboarding/` + `lib/features/jeonse_risk/` | 152 |
| **S6** | `lib/features/rent_compare/` + `lib/features/semi_rent/` | 151 |
| **S7** | `lib/features/home/` + `lib/features/scenario_compare/` + `lib/features/contract_renewal/` | 133 |
| **S8** | `lib/features/monthly_expense/` + `lib/features/loan_interest/` + `lib/features/tax_deduction/` | 134 |
| **S9** | `lib/features/advanced_calculators/` + `lib/features/admin/` | 126 |
| **S10** | `lib/shared/` (11파일) + `lib/features/shared/main_shell.dart` + `lib/core/` 잔여 + `lib/data/` | 140 |

S10의 "`lib/core/` 잔여"는 아래 파일로 한정한다. `lib/core/theme/`와 `lib/core/settings/`는 Phase 0이 소유하므로 **S10의 범위가 아니다**.

```
lib/core/ads/ad_service.dart                        lib/core/utils/calculation_pdf_exporter.dart
lib/core/constants/app_constants.dart               lib/core/utils/money_formatter.dart
lib/core/constants/disclaimer_texts.dart            lib/core/utils/share_helper.dart
lib/core/extensions/number_format_extension.dart    lib/core/utils/validators.dart
lib/core/notifications/firebase_push_service.dart
lib/core/notifications/local_notification_service.dart
lib/core/notifications/notice_realtime_service.dart
```

`lib/core/constants/legal_texts.dart`는 수정 금지 파일이므로 제외한다. `lib/data/models/calculation_history.g.dart`는 생성 파일이므로 제외한다.

각 슬라이스는 담당 파일에서 **다크모드 치환과 문자열 추출을 함께** 수행한다. 관심사가 아니라 파일 소유권으로 나누었으므로 슬라이스 간 파일 교집합이 없다.

S1이 단독인 이유: `app_guide_screen.dart`는 1342줄에 AppColors 55 + AppTextStyles 26 + 한글 125개로, 단일 파일이면서 전체 부하의 약 1/6을 차지한다.

S2에서 `legal_document_screen.dart`는 화면 자체(제목·버튼 등)만 다루고, 그것이 표시하는 `legal_texts.dart` 원문은 건드리지 않는다.

## 5. 병렬 실행의 실패 지점과 방어

파일 소유권만 분리하면 안전하다는 것은 사실이 아니다. 두 곳이 샌다.

### 5.1 ARB는 공유 자원이다

10개 슬라이스가 모두 `app_ko.arb` 하나에 키를 추가하면 파일 소유권 분리가 무의미해지고 병합 충돌이 확정된다.

**방어:** 각 슬라이스는 자기 프래그먼트에만 쓴다.

```
lib/l10n/fragments/s01_app_guide.ko.arb   /  s01_app_guide.en.arb
lib/l10n/fragments/s02_settings.ko.arb    /  s02_settings.en.arb
...
lib/l10n/fragments/s10_shared_core.ko.arb /  s10_shared_core.en.arb
```

프래그먼트 파일도 슬라이스 전용이므로 배타성이 유지된다. Phase 2에서 `tool/merge_arb.dart`가 `app_ko.arb` / `app_en.arb`로 병합한다.

### 5.2 키 이름이 충돌한다

두 에이전트가 각자 `cancel`, `confirm`, `save`를 만들면 병합 시 같은 키에 다른 값이 온다.

**방어 — 네임스페이스 규칙:**

- 모든 키는 **feature 접두어 필수**: `historyEmptyMessage`, `settingsThemeLabel`, `jeonseRiskHighWarning`
- 공용 키는 Phase 0에서 `common*` 접두어로 **미리 확정해 배포**한다 (`commonCancel`, `commonConfirm`, `commonSave`, `commonDelete`, `commonClose`, `commonRetry`, `commonError` 등)
- **슬라이스는 `common*` 키를 새로 만들 수 없다.** 필요하면 자기 네임스페이스로 만든다
- `tool/merge_arb.dart`는 네임스페이스 위반과 중복 키를 **에러로 중단**시킨다

### 5.3 슬라이스 계약서

Phase 0의 산출물로 `docs/superpowers/specs/2026-07-31-slice-contract.md`를 작성한다. 각 에이전트가 **이 문서만 읽고 콜드 스타트**할 수 있어야 한다. 포함 내용:

- 치환 패턴 2종 (`context.palette.*`, `context.typography.*`)
- ARB 키 네이밍 규칙과 `common*` 확정 목록
- 프래그먼트 파일 경로 규칙
- 수정 금지 파일 목록 (`legal_texts.dart`, `*.g.dart`, `lib/l10n/gen/`)
- 번역 톤: 한국 거주 외국인 대상. 평이한 영어. 한국 특유 개념은 용어집 준수
- 용어집 등록 규칙 (5.4절)
- 완료 기준: 담당 파일에 `AppColors.` 0건, `AppTextStyles.` 0건, 한글 리터럴 0건, `flutter analyze` 통과

### 5.4 용어집 검수 게이트

990개 중에는 오역이 곧 사용자 피해로 이어지는 부동산·법률 용어가 섞여 있다 (전세권 설정, 확정일자, 대항력, 우선변제권, 근저당, 임차권등기명령 등).

**규칙:** Phase 1의 에이전트는 이런 용어를 만나면 번역을 **확정하지 않고** `lib/l10n/glossary.md`에 후보로 등록한다. 프래그먼트에는 임시 번역을 넣되 용어집 항목과 키를 연결한다.

Phase 2에서 사용자가 **약 40개 용어만** 한 번에 검수하고, 승인된 대응표를 전체 프래그먼트에 일괄 반영한다. 사용자가 990개를 검토하지 않아도 되도록 하는 것이 이 게이트의 목적이다.

용어집 형식:

```markdown
| 한국어 | 영어(후보) | 맥락 | 사용 키 | 확정 |
|---|---|---|---|---|
| 확정일자 | fixed date confirmation | 임대차 계약 신고 | jeonseRiskFixedDate | ☐ |
```

## 6. 실행 순서

```
Phase 0  기반 (순차, 단독 실행)
         팔레트 · 타이포 · ARB 배선 · 프로바이더 · app.dart 배선
         도메인 enum 리팩터링 · 병합기 · common* 키 확정 · 슬라이스 계약서
         → flutter analyze 통과 + 빌드 통과 확인
                    │
Phase 1  슬라이스 (병렬 10)
         S1~S10, 각자 격리된 worktree
                    │
Phase 2  통합 (순차)
         ① 프래그먼트 병합 + flutter gen-l10n
         ② 용어집 검수 게이트 (사용자 개입, 약 40개)
         ③ 잔여 스캔 0건 확인
         ④ 대비 검증 · 테스트 · 코드 리뷰
```

Phase 0이 끝나기 전에 Phase 1을 시작하면 모든 슬라이스가 존재하지 않는 API를 대상으로 작업하게 되므로, 이 순서는 타협 대상이 아니다.

**용어집 검수가 유일한 사용자 개입 지점이다.**

## 7. 에러 처리

- **Hive에 손상된 값** — `theme_mode`/`locale`에 예상치 못한 값이 있으면 `system`으로 폴백한다. 폴백은 조용히 삼키지 않고 로그를 남긴다
- **미지원 로케일** — `localeResolutionCallback`에서 `ko`로 폴백
- **ARB 키 누락** — `gen_l10n`이 템플릿(`app_ko.arb`) 기준으로 코드를 생성하므로 키 누락은 **빌드 타임 컴파일 에러**로 잡힌다. `app_en.arb`에 누락된 키는 런타임에 `ko` 값으로 폴백된다
- **병합기** — 중복 키, 네임스페이스 위반, 잘못된 JSON을 만나면 경고가 아니라 **에러로 중단**한다

## 8. 테스트

- **도메인 enum 단위 테스트** — 계산기 7개가 올바른 enum을 반환하는지. 리팩터링의 회귀 방지
- **위젯 테스트** — 테마 3모드(system/light/dark) 렌더, 로케일 2개(ko/en) 렌더
- **설정 영속화 테스트** — Hive 저장·복원, 손상된 값 폴백
- **잔여 스캔 스크립트** `tool/check_hardcoded.sh` — `AppColors.` 참조(테마 조립부 제외)와 한글 리터럴(`legal_texts.dart` 제외)이 0건인지 검증. CI에서 실행
- **대비 검증** — 다크 팔레트 조합이 WCAG AA를 만족하는지 (Phase 0에서 1회, Phase 2에서 최종)

기존 테스트 17개는 전부 통과해야 한다.

## 9. 완료 기준

- [ ] 테마 3모드가 전 화면에서 정상 동작하고 앱 재시작 후에도 유지됨
- [ ] 언어 전환이 전 화면에 즉시 반영되고 앱 재시작 후에도 유지됨
- [ ] `lib/` 내 `AppColors.` 참조 0건 (`app_theme.dart` 조립부 제외)
- [ ] `lib/` 내 `AppTextStyles.` 참조 0건
- [ ] `lib/` 내 한글 리터럴 0건 (`legal_texts.dart` 제외)
- [ ] `lib/domain` 내 한글 리터럴 0건
- [ ] 용어집 약 40개 항목이 사용자 승인 완료
- [ ] 다크 팔레트가 WCAG AA 충족
- [ ] `flutter analyze` 무경고, 기존 17개 테스트 + 신규 테스트 통과
- [ ] 기존 저장 이력 데이터가 깨지지 않음
