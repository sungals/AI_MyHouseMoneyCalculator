import 'jeonse_risk_codes.dart';

enum JeonseRiskLevel {
  low,
  caution,
  high,
}

class JeonseRiskResult {
  final double jeonseRatio;
  final double seniorDebtRatio;
  final double combinedDebtRatio;
  final int score;
  final JeonseRiskLevel level;
  final List<JeonseRiskWarning> warnings;
  final List<JeonseRiskCheck> checklist;
  final List<JeonseRiskAction> actionItems;
  final List<JeonseProtectionStep> protectionChecklist;

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
  });
}
