# 집돈계산기 (House Money Calculator)

주거비 관련 각종 비용을 쉽고 빠르게 계산할 수 있는 Flutter 앱입니다.

## 주요 기능

### 1. 전세 vs 월세 비교
- 전세대출 이자와 월세 중 실제로 유리한 쪽을 비교
- 기회비용(예금이율)까지 고려한 정확한 총비용 계산
- 거주 기간별 시나리오 지원

### 2. 반전세 계산
- 보증금 일부를 월세로 전환한 반전세 계약의 적정성 확인
- 전월세 전환율 기준 적정 월세와의 차이 계산

### 3. 대출이자 계산
- 대출금액·연이율·기간 입력 → 월 이자·총 이자 즉시 계산
- 단리(이자만 납부) 방식

### 4. 월 고정비 계산
- 주거비·관리비·통신비·교통비·보험료·구독료·식비·기타 8개 항목
- 월 합계 및 연간 총 지출 계산
- 빠른 입력 버튼: +100만 / -100만 / +10만 / -10만 / +1만 / -1만

## 기술 스택

| 항목 | 내용 |
|------|------|
| Framework | Flutter 3.x, Dart 3.5.1 |
| 상태 관리 | flutter_riverpod 2.5.1 (StateNotifierProvider) |
| 라우팅 | go_router 14.x |
| 로컬 저장 | Hive 2.2.3 + hive_flutter |
| UI | Material 3 |

## 아키텍처

```
lib/
├── core/
│   ├── constants/       # 앱 상수
│   ├── theme/           # 색상, 텍스트 스타일, 테마
│   └── utils/           # 숫자 포매터 등 유틸
├── data/
│   ├── local/           # Hive 기반 계산 이력 저장소
│   └── models/          # 데이터 모델 (CalculationHistory)
├── domain/
│   ├── calculators/     # 순수 계산 로직 (비즈니스 레이어)
│   └── entities/        # 입력/결과 엔티티
├── features/
│   ├── home/            # 홈 화면 (탭 네비게이션)
│   ├── onboarding/      # 앱 최초 실행 튜토리얼 (5페이지 PageView)
│   ├── rent_compare/    # 전세 vs 월세 비교
│   ├── semi_rent/       # 반전세 계산
│   ├── loan_interest/   # 대출이자 계산
│   ├── monthly_expense/ # 월 고정비 계산
│   └── tax_deduction/   # 세금 공제 계산
├── router/              # go_router 설정 + 온보딩 게이트
└── shared/
    └── widgets/         # 공통 위젯
        ├── money_input_field.dart   # 숫자 입력 + 슬라이더 + 빠른 조정 버튼
        ├── help_icon.dart           # 섹션별 도움말 아이콘 (AlertDialog)
        ├── primary_button.dart
        ├── disclaimer_box.dart
        └── slider_rate_field.dart
```

## 주요 위젯

### MoneyInputField
금액 입력에 특화된 공통 위젯입니다.
- 자동 천단위 콤마 포매팅
- 슬라이더 연동 (`sliderMax` 지정 시)
- 빠른 조정 버튼 (`quickButtonAmounts`로 단위 커스터마이징 가능)
  - 기본값: +1억 / -1억 / +1천만 / -1천만 / +100만 / -100만
  - 월 고정비 화면: +100만 / -100만 / +10만 / -10만 / +1만 / -1만

### HelpIcon
섹션 제목 옆에 배치하는 도움말 아이콘입니다.
- 탭 시 AlertDialog로 상세 설명 표시
- 각 계산 화면의 주요 섹션에 적용됨

### OnboardingScreen
앱 최초 실행 시 5페이지 튜토리얼을 보여줍니다.
- Hive `app_settings` 박스의 `onboarding_done` 키로 완료 여부 관리
- 완료 후 GoRouter `redirect`에서 자동으로 홈 화면으로 이동
- 건너뛰기 버튼으로 즉시 진입 가능

## 시작하기

```bash
# 의존성 설치
flutter pub get

# iOS 실행
flutter run -d <iOS_device_id>

# Android 실행
flutter run -d <Android_device_id>

# 연결된 기기 목록 확인
flutter devices
```

## 환경 요구사항

- Flutter 3.x 이상
- Dart 3.5.1 이상
- iOS 14.0 이상 / Android API 21 이상
