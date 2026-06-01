# Play Console 배포 체크리스트

기준 버전: `1.0.1+15`

## 업로드 전 확인

- `pubspec.yaml` 버전이 `1.0.1+15`인지 확인한다.
- Android 릴리스 번들이 생성되어 있는지 확인한다.
- 산출물 경로: `build/app/outputs/bundle/release/app-release.aab`
- 앱 서명 설정이 Play App Signing 기준과 충돌하지 않는지 확인한다.
- 타겟 API level과 정책 경고를 점검한다.

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

> 전세사기 위험도 체크를 강화하고, 권장 조치와 보호 절차를 추가했습니다.
> 계산 결과 공유, PDF 내보내기, 결과 액션 UI를 공통화했습니다.
> 전세 vs 월세 비교와 복수 시나리오 비교를 더 보기 쉽게 정리했습니다.
> 로그인 우회 문제를 수정하고, Android/iOS 실기기 자동화 테스트를 통과했습니다.

## 배포 후 확인

- 스토어에 최신 버전이 노출되는지 확인한다.
- 새 설치와 업데이트 설치가 정상인지 확인한다.
- 로그인 화면과 메인 진입이 의도대로 동작하는지 확인한다.
- 주요 계산기와 결과 공유/PDF 기능을 최소 한 번 확인한다.
