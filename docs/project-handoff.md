# 어떤비용 프로젝트 인수인계 문서

최종 확인일: 2026-06-01  
현재 앱 버전: `1.0.1+15`

## 1. 프로젝트 개요

`어떤비용`은 Flutter 기반 생활금융 계산 앱이다. 주거 계약, 대출, 세금, 고정비와 관련된 계산을 빠르게 수행하고, 결과를 저장/공유/PDF 내보내기할 수 있다.

주요 기능은 다음과 같다.

- 전세 vs 월세 비교
- 복수 시나리오 비교
- 계약 갱신 5% 상한 계산
- 전세사기 위험도 체크
- 반전세 계산
- 대출이자 계산
- 월 고정비 계산
- 연말정산 세액공제 계산
- DSR/DTI 계산
- 중개보수 계산
- 취득세 계산
- 계산 이력 저장, 메모, 즐겨찾기, 삭제
- Supabase 로그인 및 계산 이력 동기화
- 공지사항 조회/읽음 처리/관리자 작성
- Firebase Cloud Messaging 기반 공지 푸시
- PIN/생체인증 잠금
- AdMob 결과 화면 배너

## 2. 기술 스택

| 영역 | 사용 기술 |
| --- | --- |
| 앱 프레임워크 | Flutter, Dart |
| 상태 관리 | Riverpod `StateNotifierProvider`, `Provider`, `FutureProvider`, `StreamProvider` |
| 라우팅 | `go_router` |
| 로컬 저장 | Hive |
| 원격 백엔드 | Supabase Auth, Database, Storage, Edge Functions |
| 푸시 | Firebase Cloud Messaging, `flutter_local_notifications` |
| 광고 | Google Mobile Ads |
| 공유/문서 | `share_plus`, `pdf`, `printing`, `screenshot` |
| 인증 보조 | `local_auth`, PIN 해시 저장 |

## 3. 실행 방법

기본 실행:

```bash
flutter pub get
flutter run
```

연결된 기기 확인:

```bash
flutter devices
```

정적 분석과 테스트:

```bash
flutter analyze
flutter test
```

Android 릴리스 번들 생성:

```bash
flutter build appbundle --release
```

생성 산출물:

```text
build/app/outputs/bundle/release/app-release.aab
```

iOS 배포는 [ios-deployment-guide.md](ios-deployment-guide.md)를 기준으로 진행한다. 자동 업로드 스크립트는 `scripts/distribute.sh`에 있으며, 실행 시 `pubspec.yaml`의 빌드 번호를 자동으로 1 증가시킨다.

## 4. 프로젝트 구조

주요 디렉터리:

```text
lib/
├── app.dart                         # MaterialApp, 라우터, 오프라인 배너, 앱 생명주기 처리
├── main.dart                        # Firebase, Supabase, Hive, AdMob, 알림 초기화
├── connectivity/                    # 네트워크 연결 상태
├── core/
│   ├── ads/                         # AdMob 서비스와 광고 단위 ID
│   ├── analytics/                   # 분석 서비스 placeholder
│   ├── config/                      # Supabase URL/anon key
│   ├── constants/                   # 앱 상수, 약관, 면책 문구
│   ├── notifications/               # Firebase push, local notification, realtime notice
│   ├── purchase/                    # 구매 서비스 placeholder
│   ├── theme/                       # 색상, 텍스트 스타일, 테마
│   └── utils/                       # 포매터, PDF export, 공유, validation
├── data/
│   ├── local/                       # Hive 계산 이력 저장소
│   ├── models/                      # CalculationHistory, Notice
│   ├── remote/                      # Supabase 계산 이력 저장소
│   └── repositories/                # local/remote 조합 repository
├── domain/
│   ├── calculators/                 # 순수 계산 로직
│   └── entities/                    # 계산 입력/결과 모델
├── features/                        # 화면 단위 feature
├── providers/                       # 공통 repository/provider
├── router/                          # go_router 설정과 인증 redirect
└── shared/widgets/                  # 공통 UI 위젯
```

테스트:

```text
test/                               # 단위/위젯 테스트
integration_test/                   # 기기 기반 smoke/screenshot 테스트
```

Supabase:

```text
supabase/migrations/                # DB/RLS/function/storage policy 마이그레이션
supabase/functions/send-notice-push # 공지 푸시 Edge Function
```

## 5. 앱 초기화 흐름

진입점은 [main.dart](../lib/main.dart)이다.

초기화 순서:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. AdMob 초기화
3. Firebase 초기화 및 background message handler 등록
4. Hive 초기화
5. `CalculationHistoryAdapter` 등록
6. `app_settings` 박스 열기
7. `calculation_history` 박스 열기
8. Supabase 초기화
9. 미인증 상태에서 stale push token 정리
10. 로컬 알림 서비스 초기화
11. `ProviderScope`로 앱 실행

테스트에서는 `bootstrap()`의 옵션으로 광고/알림/session 초기화 동작을 일부 끌 수 있다.

## 6. 라우팅과 인증 게이트

라우터는 [app_router.dart](../lib/router/app_router.dart)에 있다.

주요 redirect 규칙:

- 온보딩 완료 전에는 `/onboarding`으로 이동한다.
- 온보딩 완료 후 로그인하지 않았고 `login_skipped`가 false이면 `/login`으로 이동한다.
- `/admin/*` 경로는 Supabase 세션이 있어야 하며, 이메일이 `AppConstants.adminEmail`과 같아야 접근 가능하다.
- 로그인 상태에서 PIN이 설정되어 있고 잠금 상태이면 `/biometric-login` 또는 `/pin-login`으로 보낸다.
- 잠금 해제 후 원래 가려던 경로는 `consumePendingRouteAfterUnlock()`로 복원한다.

주요 라우트:

| 경로 | 화면 |
| --- | --- |
| `/` | MainShell |
| `/onboarding` | 온보딩 |
| `/login` | 로그인/회원가입 |
| `/rent-compare` | 전세 vs 월세 비교 |
| `/scenario-compare` | 복수 시나리오 비교 |
| `/contract-renewal` | 계약 갱신 계산 |
| `/jeonse-risk` | 전세사기 위험도 체크 |
| `/semi-rent` | 반전세 계산 |
| `/loan-interest` | 대출이자 계산 |
| `/monthly-expense` | 월 고정비 계산 |
| `/tax-deduction` | 연말정산 세액공제 |
| `/dsr-dti` | DSR/DTI 계산 |
| `/brokerage-fee` | 중개보수 계산 |
| `/acquisition-tax` | 취득세 계산 |
| `/history`, `/history/:id` | 계산 이력 |
| `/settings` | 설정 |
| `/notices`, `/notices/:id` | 공지 |
| `/admin/notices` | 관리자 공지 목록 |

## 7. Feature 구현 패턴

계산기 기능은 대체로 같은 구조를 따른다.

1. `domain/entities/*_input.dart`에 입력값 모델을 둔다.
2. `domain/entities/*_result.dart`에 결과 모델을 둔다.
3. `domain/calculators/*_calculator.dart`에 순수 계산 로직을 둔다.
4. `features/<feature>/*_controller.dart`에서 `StateNotifier`로 계산 결과 상태를 관리한다.
5. `features/<feature>/*_screen.dart`에서 입력 UI, 계산 실행, 결과 표시, 이력 저장을 처리한다.
6. 계산 이력 저장 시 `CalculationHistory`를 만들고 `calculationHistoryRepositoryProvider`를 통해 저장한다.

새 계산기를 추가할 때 함께 수정해야 하는 곳:

- `domain/entities/`
- `domain/calculators/`
- `features/<new_feature>/`
- `lib/data/models/calculation_history.dart`
  - `CalculationType`
  - `label`
  - `featureType`
  - `fromSupabaseJson()`의 `featureTypeMap`
- `lib/features/home/calculator_menu.dart`
- `lib/router/app_router.dart`
- `lib/features/settings/app_guide_screen.dart`
- 관련 테스트 파일

`CalculationHistory`는 Hive type이므로 필드 추가 시 `@HiveField` 번호를 절대 재사용하지 않는다. 필드를 추가한 뒤에는 generator를 실행한다.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 8. 데이터 저장과 동기화

계산 이력 모델은 [calculation_history.dart](../lib/data/models/calculation_history.dart)에 있다.

저장소 구조:

- `CalculationHistoryStore`: Hive 로컬 저장
- `CalculationHistoryRemoteStore`: Supabase CRUD
- `CalculationHistoryRepository`: 로컬 우선 저장, 원격 동기화, 충돌 처리

저장 정책:

- 계산 결과는 먼저 Hive에 저장한다.
- 원격 저장 실패는 사용자 플로우를 막지 않는다.
- 원격 저장에 성공하면 `syncedAt`을 갱신한다.
- 삭제는 원격 삭제 성공 시 로컬에서도 완전 삭제한다.
- 오프라인 삭제는 `deletedAt`으로 tombstone 처리 후 이후 sync에서 원격 삭제한다.
- 로그인 시 로컬 이력을 원격으로 migrate/sync한다.

Supabase 주요 테이블:

- `calculation_history`
- `notices`
- `notice_reads`
- `push_tokens`

관련 마이그레이션은 `supabase/migrations/`에 있다.

## 9. 인증, PIN, 생체인증

Supabase Auth는 [auth_notifier.dart](../lib/features/auth/auth_notifier.dart)에서 관리한다.

지원 흐름:

- 이메일 회원가입
- 이메일 로그인
- 로그아웃
- 계정 삭제 RPC 호출
- 비회원/로그인 건너뛰기 플래그
- 로그인 성공 시 로컬 이력 원격 동기화

PIN은 [pin_notifier.dart](../lib/features/auth/pin/pin_notifier.dart)에서 관리한다.

- PIN 값은 원문 저장이 아니라 해시로 저장한다.
- 저장 위치는 Hive `app_settings`이다.
- 앱이 background/paused/detached 상태로 가면 재실행 시 잠금 상태로 전환한다.

생체인증은 [biometric_auth_service.dart](../lib/features/auth/pin/biometric_auth_service.dart)에서 `local_auth`로 처리한다.

## 10. 공지와 푸시

공지 데이터는 Supabase `notices` 테이블에서 읽는다.

사용자 기능:

- 공지 목록 조회
- 공지 상세 조회
- 로그인 사용자의 읽음 상태 저장
- Supabase realtime stream 기반 목록 갱신

관리자 기능:

- 관리자 이메일은 [app_constants.dart](../lib/core/constants/app_constants.dart)의 `adminEmail`이다.
- `/admin/notices`에서 공지 목록, 생성, 수정, 삭제를 처리한다.
- 공지 이미지는 Supabase Storage bucket `notice-images`를 사용한다.

푸시:

- 앱 시작 후 로그인 상태면 `FirebasePushService.start()`가 FCM 토큰을 Supabase `push_tokens`에 등록한다.
- 로그아웃 시 push token 등록을 정리한다.
- 백그라운드 알림 수신 시 미인증 사용자는 알림을 표시하지 않는다.
- 공지 클릭 시 `AppRouter.openNoticeFromPush()`가 공지 상세 또는 목록으로 이동한다.

## 11. 광고, 공유, PDF

광고:

- AdMob 초기화는 `main.dart`에서 수행한다.
- 광고 단위 ID는 `lib/core/ads/ad_unit_ids.dart`에서 관리한다.
- 결과 화면 공통 광고 배너는 `shared/widgets/result_ad_banner.dart`를 사용한다.

공유/PDF:

- 결과 공유 버튼은 `shared/widgets/result_action_buttons.dart`를 사용한다.
- 텍스트 공유는 `core/utils/share_helper.dart`를 사용한다.
- PDF 생성은 `core/utils/calculation_pdf_exporter.dart`를 사용한다.

## 12. 테스트 전략

기본 검증:

```bash
flutter analyze
flutter test
```

현재 테스트 범위:

- 계산기 순수 로직 단위 테스트
- `CalculationHistory` 모델/serialization 테스트
- repository 동기화 테스트
- 인증 notifier 테스트
- 홈/전세사기 화면 위젯 테스트
- 전체 계산기 smoke integration test
- 로그인/스크린샷/iOS 릴리스 smoke integration test

릴리스 전 최소 권장:

```bash
flutter analyze
flutter test
flutter build appbundle --release
```

iOS는 인증서/프로비저닝 환경이 맞는 개발 머신에서 IPA archive/export까지 확인한다.

## 13. Android 배포

현재 Android 설정:

- applicationId: `com.sungals.houseMoneyCalculator`
- compileSdk: `36`
- targetSdk: `36`
- Java/Kotlin target: `17`
- release signing: `android/key.properties` 기반

버전은 `pubspec.yaml`의 `version: x.y.z+N`을 따른다.

- `x.y.z`: versionName
- `N`: versionCode

배포 전 체크리스트는 [play-console-checklist.md](play-console-checklist.md)를 따른다.

## 14. iOS 배포

iOS 배포 문서:

- [ios-deployment-guide.md](ios-deployment-guide.md)
- [app-store-connect-checklist.md](app-store-connect-checklist.md)

ExportOptions:

- `ios/ExportOptions.plist`
- method: `app-store-connect`
- signingStyle: `automatic`
- teamID: `3NUQ46Q42B`

자동 배포 스크립트:

```bash
bash scripts/distribute.sh
```

주의:

- 스크립트는 빌드 번호를 자동 증가시킨다.
- App Store Connect API key 설정이 필요하다.
- `.appstore_credentials` 또는 `appstore_credentials` 파일을 참조한다.

## 15. 환경/비밀값

Supabase URL과 anon key는 [supabase_config.dart](../lib/core/config/supabase_config.dart)에 들어 있다. anon key는 클라이언트 공개 키 성격이지만, 권한은 반드시 Supabase RLS 정책으로 보호해야 한다.

로컬에만 있어야 하는 값:

- Android release keystore
- `android/key.properties`
- App Store Connect API private key
- `.appstore_credentials` 또는 `appstore_credentials`
- Google/Firebase 콘솔 관리 권한
- Supabase service role key

이 값들은 repository에 커밋하지 않는다.

## 16. 유지보수 시 주의사항

- 계산 로직은 가능한 `domain/calculators`에 순수 함수처럼 유지한다.
- 화면에서 계산식을 직접 구현하지 않는다.
- Hive 모델 필드 번호는 변경/재사용하지 않는다.
- Supabase 테이블 변경 시 migration과 RLS policy를 함께 작성한다.
- 로그인/비회원/오프라인 상태 모두에서 계산 저장이 막히지 않아야 한다.
- 관리자 기능은 `adminEmail`과 Supabase RLS 정책 양쪽에서 보호되어야 한다.
- 새 기능 추가 시 사용자 가이드와 README의 기능 목록도 같이 갱신한다.
- 결과 화면에 저장/공유/PDF/광고 배치 패턴을 맞춘다.
- 릴리스 전 `flutter analyze`, `flutter test`, Android AAB 또는 iOS archive를 확인한다.

## 17. 빠른 문제 해결

의존성 문제:

```bash
flutter clean
flutter pub get
```

Hive generated 파일이 맞지 않을 때:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Android signing 오류:

- `android/key.properties` 존재 여부 확인
- `storeFile`, `storePassword`, `keyAlias`, `keyPassword` 확인

iOS export 오류:

- `ios/ExportOptions.plist` 확인
- Apple Developer team/provisioning 확인
- `docs/ios-deployment-guide.md`의 `xcodebuild -exportArchive` 절차 확인

푸시가 오지 않을 때:

- Firebase 설정 파일 존재 여부 확인
- 사용자가 로그인 상태인지 확인
- `push_tokens` 테이블에 토큰이 등록되어 있는지 확인
- Supabase Edge Function 환경변수와 FCM 권한 확인

공지 관리가 막힐 때:

- 로그인 이메일이 `AppConstants.adminEmail`과 같은지 확인
- Supabase RLS admin policy 확인
- `notices`, `notice-images` 권한 확인

## 18. 새 개발자 추천 온보딩 순서

1. `README.md`와 이 문서를 읽는다.
2. `flutter pub get` 후 `flutter analyze`, `flutter test`를 실행한다.
3. `lib/main.dart`, `lib/app.dart`, `lib/router/app_router.dart`를 읽어 앱 시작 흐름을 파악한다.
4. `lib/domain/calculators`의 계산 로직과 테스트를 함께 읽는다.
5. `CalculationHistoryRepository`를 읽어 로컬/원격 저장 방식을 이해한다.
6. Supabase migration을 읽어 서버 데이터 구조와 RLS를 확인한다.
7. 작은 계산기 기능 하나를 기준으로 `input -> calculator -> controller -> screen -> history save` 흐름을 따라간다.
