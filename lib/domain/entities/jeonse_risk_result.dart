enum JeonseRiskLevel {
  low,
  caution,
  high,
}

extension JeonseRiskLevelLabel on JeonseRiskLevel {
  String get label {
    switch (this) {
      case JeonseRiskLevel.low:
        return '낮음';
      case JeonseRiskLevel.caution:
        return '주의';
      case JeonseRiskLevel.high:
        return '높음';
    }
  }
}

class JeonseRiskResult {
  final double jeonseRatio;
  final double seniorDebtRatio;
  final double combinedDebtRatio;
  final int score;
  final JeonseRiskLevel level;
  final List<String> warnings;
  final List<String> checklist;
  final List<String> actionItems;
  final List<String> protectionChecklist;
  final String levelDescription;
  final String summaryText;

  const JeonseRiskResult({
    required this.jeonseRatio,
    required this.seniorDebtRatio,
    required this.combinedDebtRatio,
    required this.score,
    required this.level,
    required this.warnings,
    required this.checklist,
    required this.actionItems,
    required this.protectionChecklist,
    required this.levelDescription,
    required this.summaryText,
  });
}
