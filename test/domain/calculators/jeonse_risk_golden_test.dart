// 전세위험 계산 골든 스냅샷.
//
// 이 파일의 기대값은 Task 12(도메인 enum 리팩터링) 착수 **이전**의 실제
// 계산 결과를 그대로 캡처한 것이다.
//
// Task 12 는 `warnings`/`checklist`/`actionItems`/`protectionChecklist` 를
// 한국어 문자열 리스트에서 enum 리스트로 바꾸고, `levelDescription` 과
// `summaryText` 를 제거한다. 문자열은 표현 계층으로 옮겨간다.
//
// 그 리팩터링을 넘어 **반드시 그대로여야 하는 것**을 여기서 고정한다:
//
//   1. 숫자 결과 4개 (jeonseRatio, seniorDebtRatio, combinedDebtRatio, score)
//   2. 위험 등급 (level)
//   3. 네 리스트의 **길이**와 중복 없음
//
// 3번이 이 파일의 핵심이다. 리스트 길이는 리팩터링 불변량이라 enum 전환
// 전후 모두 컴파일되고, 항목이 누락되거나 중복 추가되면 즉시 깨진다.
// 문자열 내용 자체는 도메인에서 사라지므로 여기서 고정할 수 없다 —
// 그건 Phase 1 이 ARB 로 옮길 때 용어집 게이트가 담당한다.
//
// 기대값을 고쳐서 통과시키지 말 것. 깨졌다면 계산이 실제로 바뀐 것이다.
// 부동소수점 값도 그대로다. 산술을 "정리"하면 여기가 먼저 깨진다.
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/domain/calculators/jeonse_risk_calculator.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_input.dart';
import 'package:house_money_calculator/domain/entities/jeonse_risk_result.dart';

class _C {
  final int marketPrice;
  final int deposit;
  final int seniorDebt;
  final bool checkedRegistry;
  final bool ownerMatched;
  final bool checkedTaxArrears;
  final bool canJoinGuaranteeInsurance;
  final bool willReportMoveIn;
  final bool willGetFixedDate;

  final double jeonseRatio;
  final double seniorDebtRatio;
  final double combinedDebtRatio;
  final int score;
  final JeonseRiskLevel level;
  final int warnings;
  final int checklist;
  final int actionItems;
  final int protection;

  const _C(
    this.marketPrice,
    this.deposit,
    this.seniorDebt,
    this.checkedRegistry,
    this.ownerMatched,
    this.checkedTaxArrears,
    this.canJoinGuaranteeInsurance,
    this.willReportMoveIn,
    this.willGetFixedDate, {
    required this.jeonseRatio,
    required this.seniorDebtRatio,
    required this.combinedDebtRatio,
    required this.score,
    required this.level,
    required this.warnings,
    required this.checklist,
    required this.actionItems,
    required this.protection,
  });

  String get label => '$marketPrice/$deposit/$seniorDebt '
      '${checkedRegistry ? 'R' : '-'}${ownerMatched ? 'O' : '-'}'
      '${checkedTaxArrears ? 'T' : '-'}${canJoinGuaranteeInsurance ? 'I' : '-'}'
      '${willReportMoveIn ? 'M' : '-'}${willGetFixedDate ? 'F' : '-'}';
}

const _golden = <_C>[
  // 전세가율 50%, 전부 체크 완료 — 최저 위험
  _C(200000000, 100000000, 0, true, true, true, true, true, true,
      jeonseRatio: 50.0,
      seniorDebtRatio: 0.0,
      combinedDebtRatio: 50.0,
      score: 0,
      level: JeonseRiskLevel.low,
      warnings: 0,
      checklist: 1,
      actionItems: 1,
      protection: 3),

  // 전세가율 90% — 체크를 다 해도 주의
  _C(200000000, 180000000, 0, true, true, true, true, true, true,
      jeonseRatio: 90.0,
      seniorDebtRatio: 0.0,
      combinedDebtRatio: 90.0,
      score: 55,
      level: JeonseRiskLevel.caution,
      warnings: 2,
      checklist: 0,
      actionItems: 2,
      protection: 3),

  // 전세가율 95% + 선순위 + 전부 미체크 — 최고 위험, 점수 상한
  _C(200000000, 190000000, 20000000, false, false, false, false, false, false,
      jeonseRatio: 95.0,
      seniorDebtRatio: 10.0,
      combinedDebtRatio: 105.0,
      score: 100,
      level: JeonseRiskLevel.high,
      warnings: 7,
      checklist: 2,
      actionItems: 8,
      protection: 3),

  // 선순위 있음, 나머지 양호 — 나누어떨어지지 않는 비율
  _C(300000000, 150000000, 50000000, true, true, true, true, true, true,
      jeonseRatio: 50.0,
      seniorDebtRatio: 16.666666666666664,
      combinedDebtRatio: 66.66666666666666,
      score: 8,
      level: JeonseRiskLevel.low,
      warnings: 0,
      checklist: 2,
      actionItems: 1,
      protection: 3),

  // 소유자 불일치 하나로 caution 을 넘어 high 로
  _C(300000000, 270000000, 0, true, false, true, true, true, true,
      jeonseRatio: 90.0,
      seniorDebtRatio: 0.0,
      combinedDebtRatio: 90.0,
      score: 70,
      level: JeonseRiskLevel.high,
      warnings: 3,
      checklist: 0,
      actionItems: 3,
      protection: 3),

  // 전세가율 정확히 100% — 경계값
  _C(100000000, 100000000, 0, true, true, true, true, true, true,
      jeonseRatio: 100.0,
      seniorDebtRatio: 0.0,
      combinedDebtRatio: 100.0,
      score: 55,
      level: JeonseRiskLevel.caution,
      warnings: 2,
      checklist: 0,
      actionItems: 2,
      protection: 3),

  // 낮은 전세가율이지만 등기·보험·확정일자 누락
  _C(500000000, 250000000, 100000000, false, true, true, false, true, false,
      jeonseRatio: 50.0,
      seniorDebtRatio: 20.0,
      combinedDebtRatio: 70.0,
      score: 51,
      level: JeonseRiskLevel.caution,
      warnings: 3,
      checklist: 2,
      actionItems: 3,
      protection: 3),

  // 중간 구간 혼합
  _C(200000000, 140000000, 30000000, true, true, false, true, false, true,
      jeonseRatio: 70.0,
      seniorDebtRatio: 15.0,
      combinedDebtRatio: 85.0,
      score: 53,
      level: JeonseRiskLevel.caution,
      warnings: 2,
      checklist: 3,
      actionItems: 3,
      protection: 3),
];

void main() {
  final calculator = JeonseRiskCalculator();

  JeonseRiskResult run(_C c) => calculator.calculate(
        JeonseRiskInput(
          marketPrice: c.marketPrice,
          deposit: c.deposit,
          seniorDebt: c.seniorDebt,
          checkedRegistry: c.checkedRegistry,
          ownerMatched: c.ownerMatched,
          checkedTaxArrears: c.checkedTaxArrears,
          canJoinGuaranteeInsurance: c.canJoinGuaranteeInsurance,
          willReportMoveIn: c.willReportMoveIn,
          willGetFixedDate: c.willGetFixedDate,
        ),
      );

  group('전세위험 계산 골든 — 숫자 결과와 등급', () {
    for (final c in _golden) {
      test(c.label, () {
        final r = run(c);

        expect(r.jeonseRatio, c.jeonseRatio, reason: 'jeonseRatio');
        expect(r.seniorDebtRatio, c.seniorDebtRatio, reason: 'seniorDebtRatio');
        expect(r.combinedDebtRatio, c.combinedDebtRatio,
            reason: 'combinedDebtRatio');
        expect(r.score, c.score, reason: 'score');
        expect(r.level, c.level, reason: 'level');
      });
    }
  });

  group('전세위험 계산 골든 — 항목 개수 (enum 전환 불변량)', () {
    for (final c in _golden) {
      test(c.label, () {
        final r = run(c);

        expect(r.warnings.length, c.warnings, reason: 'warnings');
        expect(r.checklist.length, c.checklist, reason: 'checklist');
        expect(r.actionItems.length, c.actionItems, reason: 'actionItems');
        expect(r.protectionChecklist.length, c.protection,
            reason: 'protectionChecklist');
      });
    }
  });

  group('항목에 중복이 없다', () {
    // enum 전환 시 매핑 실수로 같은 항목이 두 번 들어가는 것을 막는다.
    // 문자열이든 enum 이든 동등성 비교가 되므로 전환 전후 모두 유효하다.
    for (final c in _golden) {
      test(c.label, () {
        final r = run(c);

        expect(r.warnings.toSet().length, r.warnings.length,
            reason: 'warnings 에 중복이 있다');
        expect(r.checklist.toSet().length, r.checklist.length,
            reason: 'checklist 에 중복이 있다');
        expect(r.actionItems.toSet().length, r.actionItems.length,
            reason: 'actionItems 에 중복이 있다');
        expect(
          r.protectionChecklist.toSet().length,
          r.protectionChecklist.length,
          reason: 'protectionChecklist 에 중복이 있다',
        );
      });
    }
  });
}
