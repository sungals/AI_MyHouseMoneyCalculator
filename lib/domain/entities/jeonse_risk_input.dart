class JeonseRiskInput {
  final int marketPrice;
  final int deposit;
  final int seniorDebt;
  final bool checkedRegistry;
  final bool ownerMatched;
  final bool checkedTaxArrears;
  final bool canJoinGuaranteeInsurance;
  final bool willReportMoveIn;
  final bool willGetFixedDate;

  const JeonseRiskInput({
    required this.marketPrice,
    required this.deposit,
    required this.seniorDebt,
    required this.checkedRegistry,
    required this.ownerMatched,
    required this.checkedTaxArrears,
    required this.canJoinGuaranteeInsurance,
    required this.willReportMoveIn,
    required this.willGetFixedDate,
  });
}
