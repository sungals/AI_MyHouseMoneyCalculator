# iOS App Store 배포 가이드

Flutter 앱을 App Store에 배포하는 전체 과정을 정리한 문서입니다.

---

## 사전 준비

### 1. Apple Developer 계정
- [developer.apple.com](https://developer.apple.com) 유료 멤버십 필요 ($99/년)
- Team ID 확인: Membership 탭에서 확인

### 2. App Store Connect 앱 등록
- [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → My Apps → +
- Bundle ID 등록: `com.{팀}.{앱이름}` 형식

### 3. Xcode 설정 확인
- `ios/Runner.xcodeproj/project.pbxproj`
  - `PRODUCT_BUNDLE_IDENTIFIER`: 등록한 Bundle ID와 일치 확인
  - `DEVELOPMENT_TEAM`: Apple Developer Team ID
  - `TARGETED_DEVICE_FAMILY = "1"`: iPhone only (iPad 제외 시)

---

## 1단계: Distribution 인증서 생성 (이 Mac에서 처음 배포 시)

> 다른 Mac에서 작업하던 프로젝트를 가져온 경우, 개인 키가 없어 기존 인증서 사용 불가. 새로 생성 필요.

1. **Keychain Access** 열기
2. 메뉴 → **Certificate Assistant → Request a Certificate from a Certificate Authority**
   - User Email: 본인 이메일
   - Common Name: 본인 이름
   - **Saved to disk** 선택 → CSR 파일 저장
3. [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates) → 기존 Distribution 인증서 **Revoke** → **+**
4. **Apple Distribution** 선택 → CSR 파일 업로드 → `.cer` 다운로드
5. 터미널로 설치:
   ```bash
   security import ~/Downloads/distribution.cer -k ~/Library/Keychains/login.keychain-db
   ```
6. 확인:
   ```bash
   security find-identity -v -p codesigning | grep "Apple Distribution"
   ```

---

## 2단계: Provisioning Profile 생성

1. [developer.apple.com/account/resources/profiles](https://developer.apple.com/account/resources/profiles) → **+**
2. **App Store Connect** 선택
3. App ID 선택 → Distribution 인증서 선택 → 이름 입력 → Generate
4. `.mobileprovision` 다운로드 → 더블클릭 (Xcode에 자동 등록)

---

## 3단계: App Store Connect API Key 발급 (자동화용, 1회)

1. App Store Connect → Users and Access → Integrations → **App Store Connect API**
2. **+** → 이름 입력, Role: **App Manager** → Generate
3. 저장 (재발급 불가):
   - `.p8` 파일 다운로드
   - **Key ID** 메모
   - **Issuer ID** 메모
4. `.p8` 파일을 표준 경로로 복사:
   ```bash
   mkdir -p ~/.appstoreconnect/private_keys
   cp ~/Downloads/AuthKey_XXXXXXXXXX.p8 ~/.appstoreconnect/private_keys/
   ```
5. 프로젝트 루트에 `.appstore_credentials` 파일 생성 (gitignore 처리):
   ```bash
   ASC_KEY_ID="XXXXXXXXXX"
   ASC_ISSUER_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   ASC_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_XXXXXXXXXX.p8"
   ```

---

## 4단계: 앱 메타데이터 준비

### 스크린샷 (필수)
- **6.5인치** (1284×2778px) 또는 **6.7인치** (1290×2796px) 필수
- App Store Connect에서 요구하는 슬롯 사이즈에 맞춰 준비
- 자동 캡처 스크립트:
  ```bash
  bash scripts/capture_screenshots.sh
  ```
- 사이즈 변환 (sips):
  ```bash
  sips -z 2778 1284 screenshot.png --out screenshot.png
  ```

### GitHub Pages (지원 URL / 개인정보처리방침 URL)
- `docs/index.html`: 지원 페이지
- `docs/privacy.html`: 개인정보처리방침
- GitHub 저장소 Settings → Pages → Branch: main / `/docs` 폴더
- URL: `https://{username}.github.io/{repo}/`

### 메타데이터 항목
| 항목 | 비고 |
|------|------|
| 앱 이름 | 30자 이내 |
| 부제목 | 30자 이내 |
| 설명 | 4000자 이내 |
| 키워드 | 100자 이내, 쉼표 구분 |
| 지원 URL | GitHub Pages |
| 개인정보처리방침 URL | GitHub Pages /privacy.html |
| 카테고리 | 앱 성격에 맞게 선택 |
| 연령 등급 | 설문 작성 (대부분 4+) |
| 가격 | 무료/유료 설정 |

---

## 5단계: 빌드 및 업로드 (자동화)

### 최초 빌드
```bash
flutter build ipa --release
xcodebuild -exportArchive \
  -archivePath build/ios/archive/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist ios/ExportOptions.plist \
  -allowProvisioningUpdates
```

### 이후 배포 (원클릭 자동화)
```bash
bash scripts/distribute.sh
```
> 빌드 번호 자동 증가 → IPA 빌드 → App Store Connect 업로드까지 자동 처리

### 주의사항
- `pubspec.yaml`의 `version: x.x.x+N` 에서 `+N`이 빌드 번호
- 같은 빌드 번호로 재업로드 불가 (자동화 스크립트가 자동 증가)
- `flutter build ipa` 에러(`exportArchive Copy failed`)는 무시 가능 — xcodebuild로 재실행하면 성공

---

## 6단계: App Store Connect 심사 제출

1. TestFlight 탭에서 업로드된 빌드 확인 (15~30분 소요)
2. App Version 페이지 → **Build** 섹션에서 새 빌드 선택
3. 스크린샷, 메타데이터 입력 완료 확인
4. **Add for Review** 클릭

### 심사 전 체크리스트
- [ ] 스크린샷 업로드 (iPhone 필수 슬롯 충족)
- [ ] 앱 설명, 키워드 입력
- [ ] 지원 URL, 개인정보처리방침 URL 입력
- [ ] 연령 등급 설문 완료
- [ ] 가격 설정
- [ ] 빌드 선택
- [ ] `ITSAppUsesNonExemptEncryption = false` (Info.plist)
- [ ] PrivacyInfo.xcprivacy 포함 확인

---

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `.cer` 키체인 설치 안 됨 | 개인 키 없음 (다른 Mac의 CSR 사용) | 이 Mac에서 CSR 새로 생성 후 재발급 |
| 업로드 시 빌드 번호 에러 | 이전과 같은 빌드 번호 | `pubspec.yaml`의 `+N` 증가 후 재빌드 |
| iPad 스크린샷 요구 | 이전 빌드가 iPad 지원 | 새 iPhone-only 빌드 App Store Connect에서 선택 |
| 앱 강제 종료 후 실행 안 됨 | debug 빌드 특성 | `flutter run --profile` 또는 release 빌드 사용 |
| exportArchive Copy failed | flutter 빌드 툴 파싱 오류 | xcodebuild로 직접 export 실행 (실제론 성공) |
