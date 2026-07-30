# App Store Connect 제출 체크리스트

최종 확인일: 2026년 7월 30일

## URL

- 개인정보 처리방침 URL: `https://sungals.github.io/AI_MyHouseMoneyCalculator/privacy.html`
- 고객지원 URL: `https://sungals.github.io/AI_MyHouseMoneyCalculator/`

GitHub Pages URL은 `docs/` 변경사항이 `main` 브랜치에 푸시되고 Pages 배포가 완료된 뒤 최신 내용으로 표시된다.

## App Privacy 입력 권장값

이 앱은 로그인, 계산 기록 동기화, 공지 푸시 기능 때문에 "데이터 수집 없음"으로 제출하면 안 된다.

수집 데이터 유형:

- Contact Info > Email Address
  - 사용 목적: App Functionality, Account Management
  - 사용자와 연결됨: 예
  - 추적 목적 사용: 아니오
- Identifiers > User ID
  - 사용 목적: App Functionality, Account Management
  - 사용자와 연결됨: 예
  - 추적 목적 사용: 아니오
- User Content > Other User Content
  - 대상: 계산 입력값, 계산 결과, 저장 제목, 메모, 즐겨찾기
  - 사용 목적: App Functionality
  - 사용자와 연결됨: 예
  - 추적 목적 사용: 아니오
- Identifiers > Device ID 또는 Other Identifiers
  - 대상: Firebase 푸시 토큰
  - 사용 목적: App Functionality
  - 사용자와 연결됨: 예
  - 추적 목적 사용: 아니오
- Usage Data > Other Usage Data
  - 대상: 공지사항 읽음 여부
  - 사용 목적: App Functionality
  - 사용자와 연결됨: 예
  - 추적 목적 사용: 아니오

광고 추적, 타사 데이터 브로커 제공, 다른 회사 앱/웹사이트 간 추적 목적으로 사용하는 코드는 현재 확인되지 않았다. 따라서 App Tracking Transparency 목적의 추적으로는 표시하지 않는 방향이 맞다.

## TestFlight 업로드 준비

1. App Store Connect API 키를 생성한다.
2. `.appstore_credentials.example`을 `.appstore_credentials`로 복사한다.
3. `.appstore_credentials`에 `ASC_KEY_ID`, `ASC_ISSUER_ID`를 입력한다.
4. API private key 파일을 다음 위치에 둔다.

```bash
~/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8
```

5. Xcode에 `3NUQ46Q42B` 팀의 Apple Distribution 인증서와 `com.sungals.houseMoneyCalculator` App Store 프로비저닝 프로파일이 준비되어 있어야 한다.
6. 아래 명령으로 빌드번호를 올리고 IPA 생성 및 TestFlight 업로드를 실행한다.

```bash
./scripts/distribute.sh
```

## 현재 앱 설정

- 앱 버전: `1.0.2+26`
- iOS release AdMob App ID: `ios/Flutter/Release.xcconfig`의 `GAD_APPLICATION_IDENTIFIER`
- 비회원 사용: 로그인 화면의 `로그인 없이 계속하기`로 홈 진입 가능

## 심사 대응 노트

2026년 7월 29일 App Review에서 `Guideline 2.1(a) - Performance - App Completeness`로 로그인 또는 계정 생성 시 에러 메시지가 표시된다는 지적을 받았다.

재제출 전 확인:

- Firebase Authentication에서 App Review 전용 계정을 생성하고 이메일 인증 완료 상태로 둔다.
- Firebase Authentication의 Email/Password provider가 활성화되어 있는지 확인한다.
- Firestore 보안 규칙이 로그인 사용자와 관리자 이메일 기준으로 동작하는지 확인한다.
- 필요 시 `firebase deploy --only firestore`로 저장소의 보안 규칙과 인덱스를 배포한다.
- iOS release 빌드에서 `로그인 없이 계속하기`, 리뷰 계정 로그인, 신규 회원가입 이메일 인증 안내가 각각 정상 표시되는지 확인한다.
- App Store Connect의 Review Notes에 리뷰 계정과 비회원 사용 경로를 명확히 적는다.

Review Notes 예시:

```text
The app can be used without signing in.

To use the app without an account:
1. Launch the app.
2. Tap "로그인 없이 계속하기".
3. The main calculator screen opens.

To test account features, please use the review account below:
Email: appreview@example.com
Password: ReviewPassword123!

Account features are used for synced calculation history. If you create a new account, the app may ask for email verification before sign-in.
```

## 현재 로컬 확인 결과

- `flutter analyze`: 통과
- `flutter test`: 통과
- `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist`: archive 생성 성공, IPA export 실패

실패 원인:

- App Store Connect API 자격증명 파일 `.appstore_credentials` 없음
- 현재 Mac/Xcode에서 `sungals@gmail.com` Apple 계정 로그인 실패
- `3NUQ46Q42B` 팀의 iOS Distribution/Apple Distribution 인증서 또는 App Store 프로비저닝 프로파일 없음

생성된 archive:

```text
build/ios/archive/Runner.xcarchive
```
