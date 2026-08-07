// Validators 한국어 메시지 골든 스냅샷.
//
// 이 파일의 기대값은 Task 11(enum 반환 도입) 착수 **이전**의 실제 반환값을
// 그대로 캡처한 것이다. Validators 는 앱 전반 40곳에서 쓰이고, 그중 37곳이
// `validator: Validators.xxx` 형태의 tear-off 다 — 즉 Flutter 폼이 이 문자열을
// 그대로 사용자에게 보여준다.
//
// Task 11 은 `*Code` enum 반환을 **추가**하고 기존 문자열 함수는
// `@Deprecated` shim 으로 남긴다. shim 이 살아 있는 동안 이 메시지들은
// 한 글자도 바뀌면 안 된다.
//
// 따라서 이 기대값들은 **고쳐서 통과시키면 안 된다.** 깨졌다면 사용자에게
// 보이는 문구가 실제로 바뀐 것이고, 그건 회귀다. 값을 수정하는 대신 구현을
// 되돌릴 것.
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/constants/app_constants.dart';
import 'package:house_money_calculator/core/utils/validators.dart';

/// 문자열 하나를 받는 검증기용 케이스.
class _V {
  final String fn;
  final String? input;
  final String? expected;

  const _V(this.fn, this.input, this.expected);
}

/// loanNotExceedDeposit 전용 케이스.
class _L {
  final int loan;
  final int deposit;
  final String? expected;

  const _L(this.loan, this.deposit, this.expected);
}

const _cases = <_V>[
  // requiredAmount — 빈 값과 공백은 "입력해 주세요", 파싱 실패와 음수는 "올바른"
  _V('requiredAmount', '', '금액을 입력해 주세요.'),
  _V('requiredAmount', '   ', '금액을 입력해 주세요.'),
  _V('requiredAmount', null, '금액을 입력해 주세요.'),
  _V('requiredAmount', 'abc', '올바른 금액을 입력해 주세요.'),
  _V('requiredAmount', '-1', '올바른 금액을 입력해 주세요.'),
  // 0은 통과한다. 콤마는 제거하고 파싱한다. 상한은 없다.
  _V('requiredAmount', '0', null),
  _V('requiredAmount', '1', null),
  _V('requiredAmount', '1,000', null),
  _V('requiredAmount', '1000', null),
  _V('requiredAmount', '99999999999', null),

  // interestRate — 파싱 실패도 "범위" 메시지로 흘러간다 (별도 메시지가 없다)
  _V('interestRate', '', '금리를 입력해 주세요.'),
  _V('interestRate', '  ', '금리를 입력해 주세요.'),
  _V('interestRate', null, '금리를 입력해 주세요.'),
  _V('interestRate', 'abc', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '-0.1', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '100', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '1000', '금리는 0 이상 30.0 이하로 입력해 주세요.'),
  _V('interestRate', '0', null),
  _V('interestRate', '3.5', null),

  // months — 경계 1과 600은 포함, 0과 1200은 제외
  _V('months', '', '거주 기간을 입력해 주세요.'),
  _V('months', ' ', '거주 기간을 입력해 주세요.'),
  _V('months', null, '거주 기간을 입력해 주세요.'),
  _V('months', 'abc', '거주 기간은 1~600개월로 입력해 주세요.'),
  _V('months', '0', '거주 기간은 1~600개월로 입력해 주세요.'),
  _V('months', '1200', '거주 기간은 1~600개월로 입력해 주세요.'),
  _V('months', '1', null),
  _V('months', '12', null),
  _V('months', '600', null),
];

const _loanCases = <_L>[
  _L(0, 0, null),
  _L(100, 100, null),
  _L(0, 100, null),
  _L(101, 100, '대출금은 전세 보증금보다 클 수 없습니다.'),
  _L(100, 0, '대출금은 전세 보증금보다 클 수 없습니다.'),
];

String? _call(String fn, String? input) {
  switch (fn) {
    case 'requiredAmount':
      // ignore: deprecated_member_use_from_same_package
      return Validators.requiredAmount(input);
    case 'interestRate':
      // ignore: deprecated_member_use_from_same_package
      return Validators.interestRate(input);
    case 'months':
      // ignore: deprecated_member_use_from_same_package
      return Validators.months(input);
    default:
      throw ArgumentError('알 수 없는 검증기: $fn');
  }
}

void main() {
  group('Validators 골든 스냅샷 (한국어 메시지 고정)', () {
    for (final c in _cases) {
      test('${c.fn}(${c.input == null ? 'null' : "'${c.input}'"})', () {
        expect(_call(c.fn, c.input), c.expected);
      });
    }

    for (final c in _loanCases) {
      test('loanNotExceedDeposit(${c.loan}, ${c.deposit})', () {
        expect(
          // ignore: deprecated_member_use_from_same_package
          Validators.loanNotExceedDeposit(c.loan, c.deposit),
          c.expected,
        );
      });
    }
  });

  group('메시지가 의존하는 상수', () {
    // 상수가 바뀌면 위 기대 문자열도 함께 바뀐다. 그 연결을 명시적으로 고정해
    // 두면, 상수만 바꾸고 골든을 잊는 사고를 이 테스트가 먼저 잡는다.
    test('AppConstants 값이 골든 캡처 시점과 같다', () {
      expect(AppConstants.maxInterestRate, 30.0);
      expect(AppConstants.minMonths, 1);
      expect(AppConstants.maxMonths, 600);
    });
  });
}
