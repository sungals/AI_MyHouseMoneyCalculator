# Phase 1 슬라이스 계약서

**작성:** 2026-07-31 (Phase 0 Task 17 산출물)
**대상:** Phase 1의 10개 슬라이스 에이전트 (S1~S10)
**상위 문서:** `docs/superpowers/specs/2026-07-31-darkmode-i18n-design.md`

이 문서 하나만 읽고 담당 슬라이스를 처음부터 끝까지 수행할 수 있어야 한다.
설계 문서를 다시 읽을 필요는 없다. 아래 이름들은 전부 **현재 코드에서 대조한
실제 값**이다.

---

## 1. 전제

- Phase 0은 끝났다. `context.palette` / `context.typography` / `gen_l10n` 배선 /
  Hive 설정 프로바이더 / 도메인 enum 리팩터링 / ARB 병합기가 **이미 존재한다.**
- 각 슬라이스는 **격리된 worktree**에서 병렬로 돈다. 다른 슬라이스의 작업 결과를
  볼 수 없다.
- **담당 파일 외에는 건드리지 않는다.** 슬라이스 간 파일 교집합은 0이다
  (§12 목록). 예외는 `lib/l10n/glossary.md` 하나뿐이며 append만 한다.
- 한 슬라이스가 하는 일은 두 가지를 **같은 파일에서 동시에** 하는 것이다:
  ① 하드코딩된 색·스타일을 테마 기반으로 치환, ② 한글 문자열을 ARB로 추출.

---

## 2. 치환 패턴 ① — 색

```dart
AppColors.<name>   →   context.palette.<name>
```

이름 10개가 그대로 대응한다. 새로 외울 것이 없다.

| `AppColors.` | `context.palette.` | 현재 참조 수(lib 전체) |
|---|---|---|
| `primary` | `primary` | 70 |
| `background` | `background` | 36 |
| `surface` | `surface` | 36 |
| `textPrimary` | `textPrimary` | 25 |
| `textSecondary` | `textSecondary` | 55 |
| `positive` | `positive` | 20 |
| `warning` | `warning` | 20 |
| `danger` | `danger` | 33 |
| `divider` | `divider` | 11 |
| `cardBorder` | `cardBorder` | 36 |

- `AppPalette`는 `ThemeExtension<AppPalette>`이고, 확장 게터는
  `lib/core/theme/app_palette.dart`의 `extension AppPaletteContext on BuildContext`가
  제공한다. 임포트는 그 파일 하나면 된다.
- `AppColors.dark*` (10개)는 **팔레트 정의부에서만** 쓴다. 슬라이스는 쓰지 않는다.
- `const` 위젯 안에서 쓰던 색은 `context.palette`가 런타임 값이므로
  **해당 위젯의 `const`를 떼야 한다.** 컴파일 에러로 잡힌다.

```dart
// before
Container(color: AppColors.surface, ...)
// after
Container(color: context.palette.surface, ...)
```

## 3. 치환 패턴 ② — 텍스트 스타일

```dart
AppTextStyles.<name>   →   context.typography.<name>
```

이름 10개가 그대로 대응한다.

`heading1` `heading2` `heading3` `resultAmount` `resultAmountPositive`
`body` `bodySecondary` `label` `caption` `disclaimer`

- `AppTypography`는 `ThemeExtension<AppTypography>`이고, 확장 게터는
  `lib/core/theme/app_typography.dart`의
  `extension AppTypographyContext on BuildContext`가 제공한다.
- `AppTextStyles`는 `@Deprecated`가 붙어 있지만 **컴파일은 된다.** 라이트 색이
  고정되어 있어 다크모드에서 조용히 틀린다. 경고를 무시하지 마라.
- `.copyWith(...)`를 쓰던 곳은 그대로 이어 쓸 수 있다:
  `context.typography.body.copyWith(fontWeight: FontWeight.w600)`

## 4. `context`가 없는 곳

정적 메서드, 위젯 트리 밖, `initState`, 콜백 바깥 등에서는 셋 중 하나를 쓴다.
**우선순위 순이다.**

1. **인자로 넘긴다** — 헬퍼 메서드 시그니처에 `AppPalette palette` /
   `AppTypography typography`를 추가한다. 가장 단순하고 테스트하기 쉽다.

   ```dart
   Widget _row(String label, String value, AppPalette palette) { ... }
   // 호출부
   _row(l10n.jeonseRiskDepositLabel, v, context.palette)
   ```

2. **`Builder`로 감싼다** — `showDialog` / `showModalBottomSheet` 내부처럼 새
   `context`가 필요한 곳.

3. **`build`에서 지역 변수로 뽑는다** — 같은 `build` 안에서 여러 번 쓸 때.

   ```dart
   final palette = context.palette;
   final typo = context.typography;
   ```

`AppPalette.light` / `AppTypography.light`를 직접 참조하는 우회는 **금지**한다.
다크모드에서 조용히 틀린다.

---

## 5. 문자열 추출 규칙

### 5.1 무엇을 추출하는가

**사용자에게 보이는 모든 한글**을 ARB 키로 옮긴다. 로그 메시지, 주석,
`debugPrint` 인자는 대상이 아니다.

### 5.2 키 이름

형식: `<namespace><PascalCaseName>`

```
historyEmptyMessage      settingsThemeLabel      jeonseRiskHighWarning
```

namespace는 `tool/merge_arb.dart`의 `_namespaces`에 있는 것만 쓸 수 있다.
병합기가 위반을 **에러로 중단**시킨다. 실제 목록(22개):

```
common   app       settings   guide      history    auth
onboarding          jeonseRisk           rentCompare
semiRent            home                 scenarioCompare
contractRenewal     monthlyExpense       loanInterest
taxDeduction        advanced             admin       shared
validation          pdf                  notification
```

슬라이스별로 쓸 namespace는 §12 표에 지정되어 있다. 다른 슬라이스의
namespace를 쓰면 Phase 2 병합에서 소유권이 꼬인다.

### 5.3 `common*` 키 — 새로 만들 수 없다

베이스 `lib/l10n/app_ko.arb`에 **정확히 7개**가 확정되어 있다. 그대로 쓴다.

| 키 | ko | en |
|---|---|---|
| `commonCancel` | 취소 | Cancel |
| `commonConfirm` | 확인 | OK |
| `commonSave` | 저장 | Save |
| `commonDelete` | 삭제 | Delete |
| `commonClose` | 닫기 | Close |
| `commonRetry` | 다시 시도 | Retry |
| `commonError` | 오류가 발생했습니다 | Something went wrong |

프래그먼트에 `common`으로 시작하는 키를 넣으면 병합기가 다음 에러로 중단한다:

```
ArbMergeException: <프래그먼트>의 "commonXxx": common 네임스페이스는
베이스 ARB에서만 정의한다. 슬라이스는 자기 feature 네임스페이스를 써야 한다.
```

같은 문구가 필요하지만 7개에 없으면 **자기 namespace로 만든다.**
예: `historyDeleteAllConfirm`.

베이스 ARB에는 이 7개 외에 `appTitle`과 `settingsTheme*` / `settingsLanguage*`
8개가 있다. `settings*` 8개는 Phase 0이 완성한 `theme_locale_section.dart`
전용이므로 슬라이스는 참조하지 않는다.

### 5.4 변수가 들어가는 문장

ARB `placeholders` 메타를 쓴다. 문자열 연결로 조립하지 않는다 —
어순이 언어마다 다르다.

```json
"historyItemCount": "{count}건",
"@historyItemCount": {
  "description": "이력 목록 헤더의 건수",
  "placeholders": { "count": { "type": "int" } }
}
```

```dart
Text(l10n.historyItemCount(items.length))
```

타입은 `int` `double` `String` `DateTime`을 쓴다. `DateTime`은 `format` 지정이
필요하다(`"format": "yMd"`).

### 5.5 프래그먼트 파일

경로: `lib/l10n/fragments/<슬라이스ID>_<이름>.ko.arb` / `.en.arb`

```
lib/l10n/fragments/s01_app_guide.ko.arb              s01_app_guide.en.arb
lib/l10n/fragments/s02_settings.ko.arb               s02_settings.en.arb
lib/l10n/fragments/s03_history.ko.arb                s03_history.en.arb
lib/l10n/fragments/s04_auth.ko.arb                   s04_auth.en.arb
lib/l10n/fragments/s05_onboarding_jeonse.ko.arb      s05_onboarding_jeonse.en.arb
lib/l10n/fragments/s06_rent_semi.ko.arb              s06_rent_semi.en.arb
lib/l10n/fragments/s07_home_scenario_renewal.ko.arb  s07_home_scenario_renewal.en.arb
lib/l10n/fragments/s08_expense_loan_tax.ko.arb       s08_expense_loan_tax.en.arb
lib/l10n/fragments/s09_advanced_admin.ko.arb         s09_advanced_admin.en.arb
lib/l10n/fragments/s10_shared_core.ko.arb            s10_shared_core.en.arb
```

**자기 슬라이스의 두 파일 외에는 쓰지 않는다.** `app_ko.arb` / `app_en.arb`는
베이스이므로 직접 편집 금지다(§6).

프래그먼트 형식 — `@@locale`은 필수, ko에는 `description`을 붙인다:

```json
{
  "@@locale": "ko",
  "historyEmptyMessage": "저장된 계산 이력이 없습니다",
  "@historyEmptyMessage": { "description": "이력 목록이 비었을 때" }
}
```

```json
{
  "@@locale": "en",
  "historyEmptyMessage": "No saved calculations yet"
}
```

en 프래그먼트에는 `@키` 메타를 넣지 않는다 — 병합기가 `@`를 뗀 이름으로
namespace를 검사하므로 넣어도 통과하지만 중복이라 불필요하다.

### 5.6 화면에서 키 읽기

```dart
import '../../l10n/gen/app_localizations.dart';   // 상대 경로는 파일 위치에 맞춘다

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return Text(l10n.historyEmptyMessage);
}
```

`AppLocalizations.of(context)`는 **non-nullable**이다(`l10n.yaml`의
`nullable-getter: false`). `!`나 `?.`를 붙이지 마라.

### 5.7 컴파일이 되게 하는 로컬 루프

`lib/l10n/gen/`은 **베이스 ARB에서만** 생성되어 커밋되어 있다. 프래그먼트에 키를
추가해도 `l10n.<새키>`는 바로 컴파일되지 않는다. 작업 중에는 로컬에서
병합·생성한다.

```bash
dart run tool/merge_arb.dart     # 프래그먼트 → app_ko.arb / app_en.arb
flutter gen-l10n                 # → lib/l10n/gen/
flutter analyze
```

**커밋 직전에 반드시 원복한다.** 병합은 Phase 2의 일이다.

```bash
git checkout -- lib/l10n/app_ko.arb lib/l10n/app_en.arb lib/l10n/gen/
git status   # 담당 파일 + 자기 프래그먼트 2개 + glossary.md 만 남아야 한다
```

### 5.8 슬라이스 경계를 넘는 키는 없다

**다른 슬라이스의 프래그먼트 키에 의존하는 코드를 쓰지 않는다.** 각 worktree에는
자기 프래그먼트만 있으므로, 남의 키를 참조하면 `flutter analyze`가 통과할 수 없다.

경계를 넘어 쓸 수 있는 것은 **베이스 ARB에 이미 커밋된 키**뿐이다:
`appTitle`, `common*` 7개.

이 규칙이 §7 유예 목록의 근거다.

---

## 6. 수정 금지 파일

| 경로 | 이유 |
|---|---|
| `lib/core/constants/legal_texts.dart` | 약관 원문 49개. 한국어 유지 |
| `lib/l10n/app_ko.arb`, `lib/l10n/app_en.arb` | 베이스. 프래그먼트로만 추가 |
| `lib/l10n/gen/**` | 생성물 |
| `**/*.g.dart` | 생성물 (`calculation_history.g.dart` 포함) |
| `lib/core/theme/**` | Phase 0 소유 (팔레트·타이포·테마 조립) |
| `lib/core/settings/**` | Phase 0 소유 (Hive 프로바이더) |
| `lib/features/settings/theme_locale_section.dart` | Phase 0에서 완성 |
| `lib/app.dart`, `lib/main.dart` | Phase 0에서 배선 완료 |
| `l10n.yaml`, `pubspec.yaml`, `tool/**` | 기반 설정 |

`lib/l10n/glossary.md`만이 공유 파일이고, **append만** 허용된다(§9).

---

## 7. Phase 1에서 손대지 않는 것 (Phase 2로 유예)

아래는 **호출부가 여러 슬라이스에 흩어져 있어** 격리된 worktree에서 안전하게
바꿀 수 없다. 담당 슬라이스도 그대로 둔다. 이 파일들의 한글은 §11 완료 기준의
예외다.

| 대상 | 호출부 | 유예 이유 |
|---|---|---|
| `lib/core/utils/validators.dart`의 구형 API (`requiredAmount` `interestRate` `months` `loanNotExceedDeposit`) | 39곳 / S5~S9 | 이관하려면 `validation*` 키가 필요한데 그 키는 S10 프래그먼트에 있다. §5.8 위반 |
| `lib/core/utils/pdf_export_labels_ko.dart` (`kKoreanPdfExportLabels`) | 10곳 / S5·S6·S7·S8·S9 | 위와 같음. `pdf*` 키가 S10 프래그먼트에 있다 |
| `lib/features/rent_compare/rent_compare_localizations.dart` | S6 + `scenario_compare_screen.dart`(S7) | 시그니처를 바꾸면 S7이 깨진다 |
| `lib/core/utils/money_formatter.dart`, `lib/core/extensions/number_format_extension.dart` | 전 슬라이스 | 여기의 `억` `만원` `천` `원`은 UI 문구가 아니라 **한국어 표기 형식 그 자체**다. `test/core/utils/money_formatter_golden_test.dart`가 ko 출력을 고정한다 |
| `lib/core/theme/app_colors.dart`, `app_palette.dart`, `app_text_styles.dart` | — | 팔레트 정의부와 구형 shim. 마지막 호출부가 사라진 뒤 Phase 2에서 삭제 |

이미 코드에 신규 API가 준비되어 있지만 **켜는 것은 Phase 2다.** 참고:

- `Validators.requiredAmountCode` / `interestRateCode` / `monthsCode` /
  `loanNotExceedDepositCode` → `ValidationError` enum
  (`lib/core/utils/validation_error.dart`, 7개 값)
- `MoneyFormatter.formatCompact(amount, style)` +
  `moneyStyleFor(locale)` (`lib/core/utils/money_format_style.dart`)

**금액 포맷 확정 규칙** (Phase 2에서 적용):

- ko 출력은 현행과 **바이트 단위로 동일**하다 (`1억2천만원` 형태).
- en 출력은 서구식 축약 — `MoneyFormatStyle.western` →
  `KRW 1.2M`, `KRW 35K`, `KRW 2.5B`. 소수 첫째 자리 반올림, `.0`은 제거,
  반올림 후 1000 이상이면 상위 단위로 승격.
- 통화는 **KRW 고정**. 환율 변환은 하지 않는다.

---

## 8. 번역 톤 (en 프래그먼트)

- 독자는 **한국에 거주하는 외국인**이다. 부동산 계약을 실제로 하려는 사람이다.
- **평이한 영어.** 짧은 문장. 법률 영어체를 흉내내지 않는다.
- 한국 특유의 제도는 **음차 + 짧은 설명**을 붙인다.
  예: `jeonse (large-deposit lease)`, `wolse (monthly rent)`
- 단위·통화는 KRW 그대로 둔다. 달러로 환산하지 않는다.
- 버튼·라벨은 문장부호 없이, 문장은 마침표를 찍는다 (ko 원문 관례를 따른다).
- 부동산·법률 용어는 **확정하지 말고 용어집에 올린다** (§9).

---

## 9. 용어집 등록 규칙

오역이 곧 사용자 피해가 되는 부동산·법률 용어(전세권 설정, 확정일자, 대항력,
우선변제권, 근저당, 임차권등기명령 등)를 만나면:

1. en 프래그먼트에는 **잠정 번역**을 넣는다 (빈칸으로 두지 않는다).
2. `lib/l10n/glossary.md` 표에 **행을 추가**한다.

```markdown
| 한국어 | 영어(후보) | 맥락 | 사용 키 | 확정 |
|---|---|---|---|---|
| 확정일자 | fixed date confirmation | 임대차 신고 | jeonseRiskFixedDate | ☐ |
```

- `사용 키`는 그 용어가 등장하는 ARB 키를 적는다. 여러 개면 쉼표로 나열한다.
- `확정`은 `☐`로 둔다. 체크는 Phase 2의 사용자 검수 게이트에서 한다.
- **`glossary.md`는 모든 슬라이스가 공유하므로 append만 한다.**
  기존 행을 수정하거나 재정렬하지 않는다. 파일 끝에 붙이면 된다.

---

## 10. 저장 데이터 불변

`lib/data/models/calculation_history.dart`의 **저장 값 포맷을 바꾸지 않는다.**
이미 사용자 기기의 Hive에 레코드가 쌓여 있다. 필드 이름, 타입, `typeId`,
저장되는 문자열 값 어느 것도 건드리지 않는다.

한글 10개는 **저장 값이 아니라 표시 라벨로 쓰이는 경우에만** 지역화한다.
지역화는 **표시 시점에** 한다 — 저장된 코드/값 → ARB 키 매핑을 표현 계층에 둔다.

`calculation_history.g.dart`는 생성 파일이므로 수정 금지다.
`test/data/models/calculation_history_test.dart`가 회귀를 잡는다.

---

## 11. 완료 기준

담당 파일 범위 안에서 전부 만족해야 한다. `<파일들>`은 §12의 자기 슬라이스 목록
(§7 유예 파일 제외).

```bash
# ① 색 참조 0건
grep -n "AppColors\." <파일들>

# ② 텍스트 스타일 참조 0건
grep -n "AppTextStyles\." <파일들>

# ③ 한글 리터럴 0건
grep -noE "'[^']*[가-힣][^']*'" <파일들>

# ④ 정적 분석 — 담당 파일 관련 에러/경고 0건
dart run tool/merge_arb.dart && flutter gen-l10n && flutter analyze

# ⑤ 관련 테스트 통과
flutter test <해당 테스트 파일>
```

추가 조건:

- ARB 키는 ko/en **양쪽 프래그먼트에 같은 키 집합**으로 들어간다. 개수가 다르면
  안 된다.
- `dart run tool/merge_arb.dart`가 에러 없이 끝난다 (중복 키·namespace 위반 0).
- 기존 테스트의 한글 단언은 **ARB 키 기반으로 교체**한다. 한글 문자열을 그대로
  기대하는 단언을 남기지 않는다.
- ④는 로컬 확인용이다. **커밋 전 `git checkout -- lib/l10n/app_ko.arb
  lib/l10n/app_en.arb lib/l10n/gen/`으로 원복한다** (§5.7).

전역 스캔 스크립트 `bash tool/check_hardcoded.sh`가 있다. Phase 1이 전부 병합된
뒤 §7 예외를 제외하고 0건이 되어야 한다. 슬라이스 단독 실행 시에는 남의 파일
위반이 함께 잡히므로, 자기 파일 라인만 보면 된다.

---

## 12. 슬라이스 목록과 담당 파일

부하 = 해당 파일들의 `AppColors 참조 + AppTextStyles 참조 + 한글 리터럴` 합계
(2026-07-31 측정, Phase 0 리팩터링 반영 후). 목록에 없는 파일은 건드리지 않는다.
부하 0인 파일도 소유권 명확화를 위해 열거한다.

### S1 — 앱 가이드 (부하 206) · namespace `guide`

프래그먼트: `s01_app_guide.ko.arb` / `.en.arb`

```
lib/features/settings/app_guide_screen.dart                      206
```

1342줄 단일 파일. 전체 부하의 약 1/7. `AppColors` 55 + `AppTextStyles` 26 +
한글 125. `AppConstants.appName` 호출부 1곳을 `l10n.appTitle`로 바꾼다(§12 S10 참고).

### S2 — 설정 나머지 (부하 98) · namespace `settings`

프래그먼트: `s02_settings.ko.arb` / `.en.arb`

```
lib/features/settings/settings_screen.dart                        46
lib/features/settings/account_manage_screen.dart                  22
lib/features/settings/notices_screen.dart                         13
lib/features/settings/notice_detail_screen.dart                   11
lib/features/settings/legal_document_screen.dart                   6
```

- `theme_locale_section.dart`는 **Phase 0 소유**다. 이 슬라이스 범위가 아니다.
- `legal_document_screen.dart`는 화면 자체(제목·버튼)만 다룬다. 그것이 표시하는
  `legal_texts.dart` 원문은 수정 금지다.
- 베이스의 `settingsTheme*` / `settingsLanguage*` 8개 키와 이름이 겹치지 않게
  한다. 겹치면 병합기가 중복 키 에러로 중단한다.
- `settings_screen.dart`의 `AppConstants.appName` 1곳 → `l10n.appTitle`.

### S3 — 이력 (부하 147) · namespace `history`

프래그먼트: `s03_history.ko.arb` / `.en.arb`

```
lib/features/history/history_detail_screen.dart                  116
lib/features/history/history_screen.dart                          31
```

`history_detail_screen.dart`의 한글 102개 상당수가 저장 이력의 표시 라벨이다.
§10을 먼저 읽어라 — 저장 값은 그대로 두고 표시 시점에만 매핑한다.

### S4 — 인증 (부하 136) · namespace `auth`

프래그먼트: `s04_auth.ko.arb` / `.en.arb`

```
lib/features/auth/login_screen.dart                               38
lib/features/auth/auth_notifier.dart                              18
lib/features/auth/pin/pin_setup_screen.dart                       17
lib/features/auth/pin/biometric_setup_screen.dart                 16
lib/features/auth/pin/pin_change_screen.dart                      15
lib/features/auth/pin/biometric_login_screen.dart                 14
lib/features/auth/pin/pin_login_screen.dart                       14
lib/features/auth/pin/randomized_pin_pad.dart                      3
lib/features/auth/pin/biometric_auth_service.dart                  1
lib/features/auth/auth_state.dart                                  0
lib/features/auth/pin/pin_notifier.dart                            0
lib/features/auth/pin/pin_state.dart                               0
```

- `auth_notifier.dart`(18)와 `biometric_auth_service.dart`(1)는 위젯이 아니라
  `BuildContext`가 없다. **에러 코드(enum)를 상태에 담고 화면에서 지역화한다** —
  Phase 0이 도메인 계산기에 적용한 것과 같은 패턴이다.
- `login_screen.dart`의 `AppConstants.appName` 1곳 → `l10n.appTitle`.
- 테스트: `test/features/auth/auth_notifier_test.dart`

### S5 — 온보딩 + 전세 위험도 (부하 192) · namespace `onboarding`, `jeonseRisk`

프래그먼트: `s05_onboarding_jeonse.ko.arb` / `.en.arb`

```
lib/features/onboarding/onboarding_screen.dart                    77
lib/features/jeonse_risk/jeonse_risk_screen.dart                  76
lib/features/jeonse_risk/jeonse_risk_localizations.dart           39
lib/features/jeonse_risk/jeonse_risk_controller.dart               0
```

- 설계 문서의 152보다 늘었다. Phase 0이 `jeonse_risk_calculator.dart`의 한글을
  enum으로 빼면서 문구가 `jeonse_risk_localizations.dart`로 옮겨왔기 때문이다.
- `JeonseRiskLocalizations`는 **S5 안에서만** 쓰인다(호출부 전부
  `jeonse_risk_screen.dart`). 시그니처를 `AppLocalizations`를 받도록 바꿔도 안전하다.
  enum 정의는 `lib/domain/entities/jeonse_risk_codes.dart`에 있다(수정 금지).
- **용어집 등록이 가장 많이 필요한 슬라이스다.** 확정일자·대항력·우선변제권·
  근저당·전입신고·보증보험이 전부 여기 있다. §9를 반드시 지켜라.
- `kKoreanPdfExportLabels` 호출부와 구형 `Validators` 호출부 3곳은 §7에 따라
  **그대로 둔다.**
- 테스트: `test/features/jeonse_risk/jeonse_risk_screen_test.dart`

### S6 — 월세 비교 + 반전세 (부하 161) · namespace `rentCompare`, `semiRent`

프래그먼트: `s06_rent_semi.ko.arb` / `.en.arb`

```
lib/features/semi_rent/semi_rent_screen.dart                      60
lib/features/rent_compare/rent_compare_screen.dart                55
lib/features/rent_compare/widgets/rent_compare_result_card.dart   43
lib/features/rent_compare/rent_compare_localizations.dart          3   ← §7 유예
lib/features/rent_compare/rent_compare_controller.dart             0
lib/features/semi_rent/semi_rent_controller.dart                   0
```

`rent_compare_localizations.dart`는 §7 유예 대상이다 — `scenario_compare_screen.dart`
(S7)가 임포트하므로 시그니처를 바꾸면 S7이 깨진다. **파일은 소유하되 수정하지
않는다.** 한글 3개는 Phase 2에서 처리한다.

### S7 — 홈 + 시나리오 비교 + 계약 갱신 (부하 137) · namespace `home`, `scenarioCompare`, `contractRenewal`

프래그먼트: `s07_home_scenario_renewal.ko.arb` / `.en.arb`

```
lib/features/scenario_compare/scenario_compare_screen.dart        51
lib/features/home/calculator_menu.dart                            42
lib/features/contract_renewal/contract_renewal_screen.dart        34
lib/features/home/home_screen.dart                                 7
lib/features/home/calculator_category_screen.dart                  3
lib/features/contract_renewal/contract_renewal_controller.dart     0
```

- `calculator_menu.dart`의 한글 32개는 계산기 이름·설명이다. 전 화면의 진입점
  라벨이므로 en 번역 품질이 특히 중요하다.
- `scenario_compare_screen.dart`는 `RentCompareLocalizations`(S6)와
  `kKoreanPdfExportLabels`(S10)를 임포트한다. **두 호출부 모두 바꾸지 않는다**(§7).
- `home_screen.dart`의 `AppConstants.appName` 1곳 → `l10n.appTitle`.
- 테스트: `test/features/home/home_screen_test.dart`

### S8 — 월 지출 + 대출 이자 + 세액 공제 (부하 145) · namespace `monthlyExpense`, `loanInterest`, `taxDeduction`

프래그먼트: `s08_expense_loan_tax.ko.arb` / `.en.arb`

```
lib/features/tax_deduction/tax_deduction_screen.dart              52
lib/features/monthly_expense/monthly_expense_screen.dart          51
lib/features/loan_interest/loan_interest_screen.dart              42
lib/features/monthly_expense/monthly_expense_controller.dart       0
lib/features/loan_interest/loan_interest_controller.dart           0
lib/features/tax_deduction/tax_deduction_controller.dart           0
```

세 화면 모두 `kKoreanPdfExportLabels`와 구형 `Validators`를 쓴다. §7에 따라
그대로 둔다. `tax_deduction_screen.dart`는 `wonFormat` 확장도 쓰는데 역시
그대로 둔다.

### S9 — 고급 계산기 + 관리자 (부하 126) · namespace `advanced`, `admin`

프래그먼트: `s09_advanced_admin.ko.arb` / `.en.arb`

```
lib/features/admin/admin_notice_form_screen.dart                  35
lib/features/advanced_calculators/acquisition_tax_screen.dart     30
lib/features/advanced_calculators/brokerage_fee_screen.dart       28
lib/features/admin/admin_notices_screen.dart                      18
lib/features/advanced_calculators/dsr_dti_screen.dart             15
```

관리자 화면도 일반 사용자에게 노출될 수 있으므로 예외 없이 지역화한다.
취득세·중개보수는 법정 요율 용어가 많다 — 용어집 등록 대상이다(§9).

### S10 — 공용 위젯 + core 잔여 + data (부하 111) · namespace `shared`, `notification`

프래그먼트: `s10_shared_core.ko.arb` / `.en.arb`

```
lib/features/shared/main_shell.dart                               18
lib/shared/widgets/money_input_field.dart                         15
lib/data/models/calculation_history.dart                          10
lib/shared/widgets/slider_rate_field.dart                          7
lib/shared/widgets/result_summary_card.dart                        6
lib/shared/widgets/disclaimer_box.dart                             4
lib/shared/widgets/help_icon.dart                                  4
lib/shared/widgets/result_ad_banner.dart                           4
lib/core/constants/disclaimer_texts.dart                           4
lib/core/notifications/local_notification_service.dart             4
lib/shared/widgets/result_action_buttons.dart                      3
lib/shared/widgets/offline_banner.dart                             2
lib/core/notifications/firebase_push_service.dart                  2
lib/shared/widgets/percent_input_field.dart                        1
lib/core/constants/app_constants.dart                              1
lib/shared/widgets/app_scaffold.dart                               0
lib/shared/widgets/primary_button.dart                             0
lib/core/ads/ad_service.dart                                       0
lib/core/notifications/notice_realtime_service.dart                0
lib/core/utils/calculation_pdf_exporter.dart                       0
lib/core/utils/share_helper.dart                                   0
lib/data/local/calculation_history_store.dart                      0
lib/data/models/notice.dart                                        0
lib/data/remote/calculation_history_remote_store.dart              0
lib/data/repositories/calculation_history_repository.dart          0
lib/data/repositories/notice_repository.dart                       0
```

**소유하지만 Phase 1에서 수정하지 않는 파일**(§7):

```
lib/core/utils/validators.dart                                    11
lib/core/utils/money_formatter.dart                                7
lib/core/utils/pdf_export_labels_ko.dart                           6
lib/core/extensions/number_format_extension.dart                   2
```

- `lib/core/theme/`와 `lib/core/settings/`는 **Phase 0 소유**다. S10 범위가 아니다.
- `lib/core/constants/legal_texts.dart`(한글 49)는 수정 금지다.
- `calculation_history.g.dart`는 생성 파일이므로 제외한다.
- 알림 문구(`local_notification_service.dart`, `firebase_push_service.dart`)는
  `notification` namespace를 쓴다. `BuildContext`가 없는 서비스이므로 호출부에서
  지역화된 문자열을 주입받도록 시그니처를 바꾼다 — Phase 0이
  `calculation_pdf_exporter.dart`에 적용한 `PdfExportLabels` 패턴과 같다.
- `app_constants.dart`의 `appName = '어떤비용'` 상수는 **삭제한다.** 호출부 4곳
  (S1·S2·S4·S7)이 각자 `l10n.appTitle`로 옮긴다. `appTitle`은 베이스 ARB에 있으므로
  §5.8을 위반하지 않는다.
- 테스트: `test/data/models/calculation_history_test.dart`,
  `test/data/repositories/calculation_history_repository_test.dart`

### 어느 슬라이스도 소유하지 않는 파일

아래는 부하가 0(색 참조·스타일 참조·한글 리터럴 모두 없음)이라 Phase 1에서 할
일이 없다. 목록에 없다고 누락된 것이 아니다.

```
lib/connectivity/connectivity_notifier.dart
lib/providers/calculation_history_provider.dart
lib/providers/notice_provider.dart
lib/router/app_router.dart
lib/core/ads/ad_unit_ids.dart
lib/core/analytics/analytics_service.dart
lib/core/purchase/purchase_service.dart
lib/core/theme/app_theme.dart          (Phase 0 소유이기도 함)
lib/core/utils/money_format_style.dart (Phase 0 산출물)
lib/core/utils/validation_error.dart   (Phase 0 산출물)
lib/domain/**                          (Phase 0에서 한글 0건 달성)
```

`lib/domain` 전체의 한글 리터럴은 이미 0건이다. 계산기는 enum 코드를 반환하고
표현 계층이 매핑한다 — 슬라이스는 `lib/domain`을 수정하지 않는다.

### 부하 합계

| S1 | S2 | S3 | S4 | S5 | S6 | S7 | S8 | S9 | S10 | 합 |
|---|---|---|---|---|---|---|---|---|---|---|
| 206 | 98 | 147 | 136 | 192 | 161 | 137 | 145 | 126 | 111 | 1459 |

10개 슬라이스가 다루는 `.dart` 파일은 77개이고 교집합은 0이다.

---

## 13. 커밋

한 슬라이스는 커밋을 여러 번 나눠도 되지만, 마지막 상태에서 다음만 변경되어
있어야 한다.

```
<담당 .dart 파일들>
lib/l10n/fragments/<슬라이스ID>_*.ko.arb
lib/l10n/fragments/<슬라이스ID>_*.en.arb
lib/l10n/glossary.md            (행 추가만)
test/**                         (담당 파일 관련 테스트만)
```

`lib/l10n/app_ko.arb` / `app_en.arb` / `lib/l10n/gen/`이 `git status`에 보이면
**원복하지 않은 것이다**(§5.7).

---

## 14. 자주 틀리는 지점

| 증상 | 원인 | 대응 |
|---|---|---|
| `const` 관련 컴파일 에러 | `context.palette`는 런타임 값 | 해당 위젯의 `const` 제거 (§2) |
| 다크모드에서 색이 안 바뀜 | `AppPalette.light`를 직접 참조 | `context.palette`로 교체 (§4) |
| `ArbMergeException: common 네임스페이스는…` | 프래그먼트에 `common*` 키 | 자기 namespace로 이름 변경 (§5.3) |
| `ArbMergeException: 허용되지 않은 네임스페이스` | 오타 또는 목록에 없는 접두어 | §5.2의 22개 목록과 대조 |
| `ArbMergeException: 중복 키` | 베이스나 다른 프래그먼트와 충돌 | 자기 namespace 접두어 확인 |
| `l10n.<키>` undefined | 병합·생성을 안 돌림 | §5.7 로컬 루프 실행 |
| 다른 슬라이스 파일이 깨짐 | 공유 헬퍼 시그니처 변경 | §7 유예 목록 확인 |
| ko 출력이 골든 테스트와 달라짐 | 금액 포맷을 건드림 | §7 — 금액 포맷은 Phase 1 범위 밖 |
| `git status`에 `lib/l10n/gen/` | 커밋 전 원복 누락 | `git checkout -- lib/l10n/gen/` (§13) |
