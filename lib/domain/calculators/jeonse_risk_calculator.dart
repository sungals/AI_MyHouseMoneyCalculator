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
    final actionItems = <String>[];
    final protectionChecklist = <String>[
      '계약 당일과 잔금일 등기부등본을 다시 발급받아 변동 사항을 확인하세요.',
      '전입신고와 확정일자는 잔금 지급 직후 처리하세요.',
      '특약에 선순위채권 말소, 보증보험 가입 협조, 체납 확인 협조를 명시하세요.',
    ];
    var score = 0;

    if (jeonseRatio >= 90) {
      score += 30;
      warnings.add('전세가율이 90% 이상입니다. 보증보험 가입이 어려울 수 있어요.');
      actionItems.add('보증금을 낮추거나 보증보험 가능 여부를 먼저 확인한 뒤 계약하세요.');
    } else if (jeonseRatio >= 80) {
      score += 20;
      warnings.add('전세가율이 80% 이상입니다. 시세와 보증보험 가능 여부를 재확인하세요.');
      actionItems.add('동일 단지/인근 실거래가와 보증보험 한도를 추가 확인하세요.');
    } else if (jeonseRatio >= 70) {
      score += 10;
      checklist.add('전세가율이 70% 이상입니다. 주변 실거래가를 추가로 확인하세요.');
    }

    if (seniorDebtRatio >= 50) {
      score += 25;
      warnings.add('선순위채권/근저당 비율이 50% 이상입니다.');
      actionItems.add('잔금 전 근저당 말소 조건을 특약으로 넣고 증빙을 확인하세요.');
    } else if (seniorDebtRatio >= 30) {
      score += 15;
      warnings.add('선순위채권/근저당 비율이 30% 이상입니다.');
      actionItems.add('선순위채권의 채권최고액과 실제 말소 가능 여부를 확인하세요.');
    } else if (seniorDebtRatio > 0) {
      score += 8;
      checklist.add('선순위채권이 있습니다. 말소 조건을 계약서에 명확히 남기세요.');
    }

    if (combinedDebtRatio >= 90) {
      score += 25;
      warnings.add('보증금과 선순위채권 합계가 주택가액의 90% 이상입니다.');
      actionItems.add('깡통전세 가능성이 높으므로 계약 보류 또는 조건 재협상을 권장합니다.');
    } else if (combinedDebtRatio >= 80) {
      score += 15;
      warnings.add('보증금과 선순위채권 합계가 주택가액의 80% 이상입니다.');
      actionItems.add('보증보험 가입 가능 금액과 선순위채권 말소 여부를 확인하세요.');
    } else if (combinedDebtRatio >= 70) {
      score += 8;
      checklist.add('보증금과 선순위채권 합계가 70% 이상입니다.');
    }

    if (!input.checkedRegistry) {
      score += 10;
      warnings.add('등기부등본 확인이 필요합니다.');
      actionItems.add('소유권, 근저당, 가압류, 신탁 등 권리관계를 등기부에서 확인하세요.');
    }
    if (!input.ownerMatched) {
      score += 15;
      warnings.add('계약 상대방과 등기상 소유자 일치 여부를 확인해야 합니다.');
      actionItems.add('대리 계약이면 위임장, 인감증명서, 신분증을 대조하세요.');
    }
    if (!input.checkedTaxArrears) {
      score += 10;
      checklist.add('임대인 국세/지방세 체납 여부를 확인하세요.');
      actionItems.add('임대인 납세증명서 또는 체납 열람 동의를 요청하세요.');
    }
    if (!input.canJoinGuaranteeInsurance) {
      score += 15;
      warnings.add('전세보증금 반환보증 가입 가능 여부가 불확실합니다.');
      actionItems.add('HUG/SGI/HF 반환보증 가입 가능 여부를 계약 전 확인하세요.');
    }
    if (!input.willReportMoveIn) {
      score += 10;
      warnings.add('전입신고 예정이 아니면 대항력 확보가 어려울 수 있습니다.');
      actionItems.add('전입신고가 어려운 계약은 보증금 보호가 약해질 수 있어 재검토하세요.');
    }
    if (!input.willGetFixedDate) {
      score += 10;
      warnings.add('확정일자 예정이 아니면 우선변제권 확보가 어려울 수 있습니다.');
      actionItems.add('확정일자를 받을 수 없는 계약 조건은 재검토하세요.');
    }

    score = score.clamp(0, 100);
    final level = score >= 60
        ? JeonseRiskLevel.high
        : score >= 30
            ? JeonseRiskLevel.caution
            : JeonseRiskLevel.low;
    final levelDescription = switch (level) {
      JeonseRiskLevel.low => '입력값 기준 위험 신호는 낮지만, 잔금 직전 권리관계 재확인은 필요합니다.',
      JeonseRiskLevel.caution =>
        '계약 전 추가 확인이 필요한 항목이 있습니다. 특약과 보증보험 가능성을 점검하세요.',
      JeonseRiskLevel.high => '보증금 회수 위험이 클 수 있습니다. 계약 보류 또는 전문가 검토를 권장합니다.',
    };

    if (warnings.isEmpty) {
      checklist.add('현재 입력값 기준 큰 위험 신호는 낮습니다. 잔금일 등기부 재확인은 필요합니다.');
    }
    if (actionItems.isEmpty) {
      actionItems.add('계약 전 등기부, 세금 체납, 보증보험 가능 여부를 최종 확인하세요.');
    }

    return JeonseRiskResult(
      jeonseRatio: jeonseRatio,
      seniorDebtRatio: seniorDebtRatio,
      combinedDebtRatio: combinedDebtRatio,
      score: score,
      level: level,
      warnings: warnings,
      checklist: checklist,
      actionItems: actionItems.toSet().toList(),
      protectionChecklist: protectionChecklist,
      levelDescription: levelDescription,
      summaryText: '전세사기 위험도 ${level.label} · $score점',
    );
  }

  double _ratio(int numerator, int denominator) {
    if (denominator <= 0) return 0;
    return numerator / denominator * 100;
  }
}
