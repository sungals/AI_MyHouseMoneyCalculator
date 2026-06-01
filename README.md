# 어떤비용

주거비와 생활금융 비용을 계산하고 저장/공유할 수 있는 Flutter 앱입니다.

현재 버전: `1.0.1+15`

## 주요 기능

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
- 결과 공유 및 PDF 내보내기
- Supabase 로그인 및 계산 이력 동기화
- 공지사항 조회/읽음 처리/관리자 작성
- Firebase Cloud Messaging 공지 푸시
- PIN/생체인증 잠금
- AdMob 결과 화면 배너

## 기술 스택

| 영역 | 사용 기술 |
| --- | --- |
| Framework | Flutter, Dart |
| 상태 관리 | Riverpod |
| 라우팅 | go_router |
| 로컬 저장 | Hive |
| 백엔드 | Supabase Auth, Database, Storage, Edge Functions |
| 푸시 | Firebase Cloud Messaging, flutter_local_notifications |
| 광고 | Google Mobile Ads |
| 공유/PDF | share_plus, pdf, printing, screenshot |
| 인증 보조 | local_auth |

## 시작하기

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

## 프로젝트 구조

```text
lib/
├── main.dart                        # Firebase, Supabase, Hive, AdMob, 알림 초기화
├── app.dart                         # MaterialApp, 라우터, 오프라인 배너, 생명주기 처리
├── connectivity/                    # 네트워크 연결 상태
├── core/
│   ├── ads/                         # AdMob 서비스와 광고 단위 ID
│   ├── analytics/                   # 분석 서비스
│   ├── config/                      # Supabase 설정
│   ├── constants/                   # 앱 상수, 약관, 면책 문구
│   ├── notifications/               # FCM, 로컬 알림, 공지 realtime
│   ├── purchase/                    # 구매 서비스
│   ├── theme/                       # 앱 색상, 텍스트 스타일, 테마
│   └── utils/                       # 포매터, 공유, PDF, validator
├── data/
│   ├── local/                       # Hive 저장소
│   ├── models/                      # CalculationHistory, Notice
│   ├── remote/                      # Supabase 원격 저장소
│   └── repositories/                # local/remote 조합 repository
├── domain/
│   ├── calculators/                 # 순수 계산 로직
│   └── entities/                    # 계산 입력/결과 모델
├── features/                        # 화면 단위 기능
├── providers/                       # 공통 provider
├── router/                          # go_router 설정과 인증 redirect
└── shared/widgets/                  # 공통 UI 위젯
```

추가 디렉터리:

```text
test/                               # 단위/위젯 테스트
integration_test/                   # 기기 기반 smoke/screenshot 테스트
supabase/migrations/                # Supabase DB/RLS/function/storage policy
supabase/functions/send-notice-push # 공지 푸시 Edge Function
docs/                               # 배포/인수인계/스토어 문서
scripts/                            # 배포, 스크린샷 보조 스크립트
```

## 앱 흐름

앱 시작점은 `lib/main.dart`입니다.

초기화 흐름:

1. Flutter binding 초기화
2. AdMob 초기화
3. Firebase 및 background message handler 초기화
4. Hive 초기화 및 box open
5. Supabase 초기화
6. stale push token 정리
7. 로컬 알림 서비스 초기화
8. `ProviderScope`로 앱 실행

라우팅과 인증 게이트는 `lib/router/app_router.dart`에서 관리합니다.

- 온보딩 미완료 사용자는 `/onboarding`으로 이동
- 로그인하지 않았고 로그인 건너뛰기 상태가 아니면 `/login`으로 이동
- 관리자 경로는 Supabase 로그인과 관리자 이메일을 확인
- PIN 잠금 상태에서는 `/pin-login` 또는 `/biometric-login`으로 이동

## 계산기 구현 패턴

계산 기능은 대체로 다음 구조를 따릅니다.

```text
domain/entities/*_input.dart
domain/entities/*_result.dart
domain/calculators/*_calculator.dart
features/<feature>/*_controller.dart
features/<feature>/*_screen.dart
```

화면은 입력값을 만들고 controller를 통해 계산합니다. 계산 결과는 `CalculationHistoryRepository`를 통해 Hive에 먼저 저장하고, Supabase 동기화가 가능하면 원격에도 저장합니다.

새 계산기를 추가할 때는 다음 파일도 함께 확인해야 합니다.

- `lib/data/models/calculation_history.dart`
- `lib/features/home/calculator_menu.dart`
- `lib/router/app_router.dart`
- `lib/features/settings/app_guide_screen.dart`
- 관련 테스트 파일

Hive 모델 필드를 추가할 때는 `@HiveField` 번호를 재사용하지 말고 generated 파일을 갱신합니다.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 데이터와 동기화

계산 이력은 로컬 우선 구조입니다.

- `CalculationHistoryStore`: Hive 로컬 저장
- `CalculationHistoryRemoteStore`: Supabase CRUD
- `CalculationHistoryRepository`: 로컬 저장, 원격 동기화, 삭제 tombstone 처리

원칙:

- 계산 결과는 먼저 로컬에 저장합니다.
- 원격 저장 실패는 계산/저장 흐름을 막지 않습니다.
- 로그인 시 로컬 이력을 Supabase로 마이그레이션/동기화합니다.
- 삭제는 원격 삭제 성공 시 로컬에서도 완전 삭제합니다.
- 오프라인 삭제는 `deletedAt`으로 표시하고 다음 sync에서 처리합니다.

## 배포

Android:

- applicationId: `com.sungals.houseMoneyCalculator`
- compileSdk/targetSdk: `35`
- release signing: `android/key.properties`
- 체크리스트: `docs/play-console-checklist.md`

iOS:

- 배포 가이드: `docs/ios-deployment-guide.md`
- App Store 체크리스트: `docs/app-store-connect-checklist.md`
- 자동 업로드 스크립트: `scripts/distribute.sh`

주의: `scripts/distribute.sh`는 실행 시 `pubspec.yaml`의 빌드 번호를 자동으로 1 증가시킵니다.

## 문서

새 개발자 인수인계용 상세 문서는 다음 파일을 기준으로 보면 됩니다.

- `docs/project-handoff.md`

배포 관련 문서:

- `docs/play-console-checklist.md`
- `docs/play-store-release-notes-2026-05-19.md`
- `docs/ios-deployment-guide.md`
- `docs/app-store-connect-checklist.md`

## 환경/비밀값 주의

다음 값은 로컬 또는 각 콘솔에서 관리하고 repository에 커밋하지 않습니다.

- Android release keystore
- `android/key.properties`
- App Store Connect API private key
- `.appstore_credentials` 또는 `appstore_credentials`
- Supabase service role key
- Firebase/Google 콘솔 관리자 권한

Supabase anon key는 클라이언트 공개 키 성격이므로 앱에 포함되어 있습니다. 실제 접근 제어는 Supabase RLS policy로 보호해야 합니다.

## 릴리스 전 권장 체크

```bash
flutter analyze
flutter test
flutter build appbundle --release
```

iOS 배포 전에는 인증서/프로비저닝이 설정된 개발 머신에서 IPA archive/export를 별도로 확인합니다.
