# Play Console 배포 체크리스트

기준 버전: `1.0.2+25`

## 업로드 전 확인

- `pubspec.yaml` 버전이 `1.0.2+25`인지 확인한다.
- Android 릴리스 번들이 생성되어 있는지 확인한다.
- 산출물 경로: `build/app/outputs/bundle/release/app-release.aab`
- 앱 서명 설정이 Play App Signing 기준과 충돌하지 않는지 확인한다.
- 타겟 API level과 정책 경고를 점검한다.
- AdMob `app-ads.txt`가 Firebase Hosting 또는 운영 도메인에서 노출되는지 확인한다.

## Play Console 업로드 절차

1. Play Console에 로그인한다.
2. 대상 앱을 연다.
3. `Test and release`로 이동한다.
4. 배포 목적에 맞는 트랙을 고른다.
   - 내부 확인: `Internal testing`
   - 제한 공개: `Closed testing`
   - 점진 공개: `Production`
5. `Create new release`를 선택한다.
6. `app-release.aab`를 업로드한다.
7. 릴리스 이름과 릴리스 노트를 입력한다.
8. 경고와 정책 검토를 확인한다.
9. 필요하면 staged rollout 비율을 설정한다.
10. `Review` 후 `Start rollout` 또는 `Publish`를 진행한다.

## 릴리스 노트

아래 문구를 그대로 사용하거나 약간 줄여서 붙여넣으면 된다.

> 로그인 없이 계속하기 기능을 추가해 비회원도 계산 기능을 바로 사용할 수 있도록 개선했습니다.
> 앱 버전을 1.0.2로 업데이트하고 Android SDK 36 대응 상태를 유지했습니다.
> iOS 릴리스용 AdMob App ID와 app-ads.txt 호스팅 준비 항목을 반영했습니다.
> 정적 분석과 전체 테스트를 통과했습니다.

## 배포 후 확인

- 스토어에 최신 버전이 노출되는지 확인한다.
- 새 설치와 업데이트 설치가 정상인지 확인한다.
- 로그인 화면과 메인 진입이 의도대로 동작하는지 확인한다.
- 주요 계산기와 결과 공유/PDF 기능을 최소 한 번 확인한다.
