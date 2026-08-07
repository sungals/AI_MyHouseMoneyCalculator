// 월세·주택자금 세액공제 계산 골든 스냅샷.
//
// 이 파일의 기대값은 Task 13(계산기 enum 리팩터링) 착수 **이전**의 실제
// 계산 결과를 그대로 캡처한 것이다.
//
// 이 골든을 만든 이유: `tax_deduction` 은 착수 시점에 **테스트가 하나도
// 없었다**. 다른 계산기들은 전부 테스트가 있어 숫자 단언이 회귀망 역할을
// 하지만, 이 계산기만 정수 출력 7개가 완전히 무방비였다. 세금 계산이라
// 값이 틀리면 사용자가 잘못된 환급액을 믿게 된다.
//
// Task 13 은 `message` 문자열을 코드 enum 으로 바꾼다. 문자열 내용은
// 도메인에서 사라지므로 여기서 고정할 수 없다. 대신 **동치류**로 고정한다 —
// "어떤 입력들이 서로 같은 메시지를 내는가". 동등성 비교는 String 이든
// Enum 이든 동작하므로 전환 전후 모두 유효하다.
//
// 기대값을 고쳐서 통과시키지 말 것. 깨졌다면 세금 계산이 실제로 바뀐 것이다.
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/tax_deduction_calculator.dart';
import 'package:house_money_calculator/domain/entities/tax_deduction_input.dart';
import 'package:house_money_calculator/domain/entities/tax_deduction_result.dart';

class _T {
  final int annualSalary;
  final int monthlyRent;
  final int annualLoanRepayment;
  final double incomeTaxRate;

  final int rentDeductionRate;
  final int eligibleAnnualRent;
  final int rentTaxCredit;
  final int eligibleRepayment;
  final int incomeDeductionAmount;
  final int loanTaxSaving;
  final int totalTaxBenefit;

  const _T(
    this.annualSalary,
    this.monthlyRent,
    this.annualLoanRepayment,
    this.incomeTaxRate, {
    required this.rentDeductionRate,
    required this.eligibleAnnualRent,
    required this.rentTaxCredit,
    required this.eligibleRepayment,
    required this.incomeDeductionAmount,
    required this.loanTaxSaving,
    required this.totalTaxBenefit,
  });

  String get label =>
      '급여$annualSalary/월세$monthlyRent/상환$annualLoanRepayment/세율$incomeTaxRate';
}

const _golden = <_T>[
  // 월세만, 공제율 17% 구간
  _T(30000000, 500000, 0, 6.0,
      rentDeductionRate: 17,
      eligibleAnnualRent: 6000000,
      rentTaxCredit: 1020000,
      eligibleRepayment: 0,
      incomeDeductionAmount: 0,
      loanTaxSaving: 0,
      totalTaxBenefit: 1020000),

  // 월세 + 대출상환. 상환액은 400만원에서 잘린다 (1,200만 입력 -> 400만 인정)
  _T(30000000, 500000, 12000000, 6.0,
      rentDeductionRate: 17,
      eligibleAnnualRent: 6000000,
      rentTaxCredit: 1020000,
      eligibleRepayment: 4000000,
      incomeDeductionAmount: 1600000,
      loanTaxSaving: 96000,
      totalTaxBenefit: 1116000),

  // 총급여 5,500만원 — 아직 17% 구간
  _T(55000000, 700000, 0, 15.0,
      rentDeductionRate: 17,
      eligibleAnnualRent: 8400000,
      rentTaxCredit: 1428000,
      eligibleRepayment: 0,
      incomeDeductionAmount: 0,
      loanTaxSaving: 0,
      totalTaxBenefit: 1428000),

  // 총급여 7,000만원 — 공제율이 15% 로 낮아진다
  _T(70000000, 700000, 24000000, 24.0,
      rentDeductionRate: 15,
      eligibleAnnualRent: 8400000,
      rentTaxCredit: 1260000,
      eligibleRepayment: 4000000,
      incomeDeductionAmount: 1600000,
      loanTaxSaving: 384000,
      totalTaxBenefit: 1644000),

  // 총급여 7천만원 초과 — 월세 세액공제 대상에서 제외(공제율 0).
  // 월세 인정액은 연 1,000만원에서 잘린다 (월 100만 x 12 = 1,200만 -> 1,000만)
  _T(80000000, 1000000, 30000000, 24.0,
      rentDeductionRate: 0,
      eligibleAnnualRent: 10000000,
      rentTaxCredit: 0,
      eligibleRepayment: 4000000,
      incomeDeductionAmount: 1600000,
      loanTaxSaving: 384000,
      totalTaxBenefit: 384000),

  // 전부 0 — 입력 없음
  _T(0, 0, 0, 6.0,
      rentDeductionRate: 17,
      eligibleAnnualRent: 0,
      rentTaxCredit: 0,
      eligibleRepayment: 0,
      incomeDeductionAmount: 0,
      loanTaxSaving: 0,
      totalTaxBenefit: 0),

  // 급여만 있고 공제 항목 없음
  _T(55000000, 0, 0, 15.0,
      rentDeductionRate: 17,
      eligibleAnnualRent: 0,
      rentTaxCredit: 0,
      eligibleRepayment: 0,
      incomeDeductionAmount: 0,
      loanTaxSaving: 0,
      totalTaxBenefit: 0),

  // 상환액 500만원도 400만원 상한에서 잘린다
  _T(50000000, 600000, 5000000, 15.0,
      rentDeductionRate: 17,
      eligibleAnnualRent: 7200000,
      rentTaxCredit: 1224000,
      eligibleRepayment: 4000000,
      incomeDeductionAmount: 1600000,
      loanTaxSaving: 240000,
      totalTaxBenefit: 1464000),
];

void main() {
  final calculator = TaxDeductionCalculator();

  TaxDeductionResult run(_T t) => calculator.calculate(
        TaxDeductionInput(
          annualSalary: t.annualSalary,
          monthlyRent: t.monthlyRent,
          annualLoanRepayment: t.annualLoanRepayment,
          incomeTaxRate: t.incomeTaxRate,
        ),
      );

  group('세액공제 계산 골든 — 숫자 결과', () {
    for (final t in _golden) {
      test(t.label, () {
        final r = run(t);

        expect(r.rentDeductionRate, t.rentDeductionRate,
            reason: 'rentDeductionRate');
        expect(r.eligibleAnnualRent, t.eligibleAnnualRent,
            reason: 'eligibleAnnualRent');
        expect(r.rentTaxCredit, t.rentTaxCredit, reason: 'rentTaxCredit');
        expect(r.eligibleRepayment, t.eligibleRepayment,
            reason: 'eligibleRepayment');
        expect(r.incomeDeductionAmount, t.incomeDeductionAmount,
            reason: 'incomeDeductionAmount');
        expect(r.loanTaxSaving, t.loanTaxSaving, reason: 'loanTaxSaving');
        expect(r.totalTaxBenefit, t.totalTaxBenefit, reason: 'totalTaxBenefit');
      });
    }
  });

  group('합계는 구성요소의 합이다', () {
    for (final t in _golden) {
      test(t.label, () {
        final r = run(t);

        expect(r.totalTaxBenefit, r.rentTaxCredit + r.loanTaxSaving);
      });
    }
  });

  group('메시지 동치류 (enum 전환 불변량)', () {
    // Task 13 이 message 를 코드 enum 으로 바꾼다. 문자열 내용은 도메인에서
    // 사라지므로 고정할 수 없지만, "어떤 입력들이 같은 분류에 속하는가" 는
    // 동등성 비교라 String / Enum 양쪽에서 동작한다.
    //
    // _golden 인덱스: 0,1,2,3,7 = 혜택 있음 / 4 = 7천만원 초과 제외 /
    //                 5,6 = 공제 항목 입력 없음
    test('공제 항목이 없는 두 입력은 같은 분류다', () {
      expect(run(_golden[5]).message, run(_golden[6]).message);
    });

    test('혜택 있음은 혜택 없음과 다른 분류다', () {
      expect(run(_golden[0]).message, isNot(run(_golden[5]).message));
      expect(run(_golden[3]).message, isNot(run(_golden[5]).message));
    });

    test('7천만원 초과 제외는 나머지 둘과 모두 다른 분류다', () {
      expect(run(_golden[4]).message, isNot(run(_golden[5]).message));
      expect(run(_golden[4]).message, isNot(run(_golden[0]).message));
    });
  });
}
