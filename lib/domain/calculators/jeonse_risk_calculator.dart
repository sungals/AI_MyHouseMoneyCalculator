import '../entities/jeonse_risk_input.dart';
import '../entities/jeonse_risk_result.dart';

class JeonseRiskCalculator {
  JeonseRiskResult calculate(JeonseRiskInput input) {
    final jeonseRatio = _ratio(input.deposit, input.marketPrice);
    final seniorDebtRatio = _ratio(input.seniorDebt, input.marketPrice);
    final combinedDebtRatio =
        _ratio(input.deposit + input.seniorDebt, input.marketPrice);
    final warnings = <String>[];
    final checklist = <String>[];
    var score = 0;

    if (jeonseRatio >= 90) {
      score += 30;
      warnings.add('전세가율이 90% 이상입니다. 보증보험 가입이 어려울 수 있어요.');
    } else if (jeonseRatio >= 80) {
      score += 20;
      warnings.add('전세가율이 80% 이상입니다. 시세와 보증보험 가능 여부를 재확인하세요.');
    } else if (jeonseRatio >= 70) {
      score += 10;
      checklist.add('전세가율이 70% 이상입니다. 주변 실거래가를 추가로 확인하세요.');
    }

    if (seniorDebtRatio >= 50) {
      score += 25;
      warnings.add('선순위채권/근저당 비율이 50% 이상입니다.');
    } else if (seniorDebtRatio >= 30) {
      score += 15;
      warnings.add('선순위채권/근저당 비율이 30% 이상입니다.');
    } else if (seniorDebtRatio > 0) {
      score += 8;
      checklist.add('선순위채권이 있습니다. 말소 조건을 계약서에 명확히 남기세요.');
    }

    if (combinedDebtRatio >= 90) {
      score += 25;
      warnings.add('보증금과 선순위채권 합계가 주택가액의 90% 이상입니다.');
    } else if (combinedDebtRatio >= 80) {
      score += 15;
      warnings.add('보증금과 선순위채권 합계가 주택가액의 80% 이상입니다.');
    } else if (combinedDebtRatio >= 70) {
      score += 8;
      checklist.add('보증금과 선순위채권 합계가 70% 이상입니다.');
    }

    if (!input.checkedRegistry) {
      score += 10;
      warnings.add('등기부등본 확인이 필요합니다.');
    }
    if (!input.ownerMatched) {
      score += 15;
      warnings.add('계약 상대방과 등기상 소유자 일치 여부를 확인해야 합니다.');
    }
    if (!input.checkedTaxArrears) {
      score += 10;
      checklist.add('임대인 국세/지방세 체납 여부를 확인하세요.');
    }
    if (!input.canJoinGuaranteeInsurance) {
      score += 15;
      warnings.add('전세보증금 반환보증 가입 가능 여부가 불확실합니다.');
    }
    if (!input.willReportMoveIn) {
      score += 10;
      warnings.add('전입신고 예정이 아니면 대항력 확보가 어려울 수 있습니다.');
    }
    if (!input.willGetFixedDate) {
      score += 10;
      warnings.add('확정일자 예정이 아니면 우선변제권 확보가 어려울 수 있습니다.');
    }

    score = score.clamp(0, 100);
    final level = score >= 60
        ? JeonseRiskLevel.high
        : score >= 30
            ? JeonseRiskLevel.caution
            : JeonseRiskLevel.low;

    if (warnings.isEmpty) {
      checklist.add('현재 입력값 기준 큰 위험 신호는 낮습니다. 잔금일 등기부 재확인은 필요합니다.');
    }

    return JeonseRiskResult(
      jeonseRatio: jeonseRatio,
      seniorDebtRatio: seniorDebtRatio,
      combinedDebtRatio: combinedDebtRatio,
      score: score,
      level: level,
      warnings: warnings,
      checklist: checklist,
      summaryText: '전세사기 위험도 ${level.label} · $score점',
    );
  }

  double _ratio(int numerator, int denominator) {
    if (denominator <= 0) return 0;
    return numerator / denominator * 100;
  }
}
