enum BrokerageTransactionType {
  sale,
  lease,
}

class BrokerageFeeInput {
  final BrokerageTransactionType transactionType;
  final int transactionAmount;

  const BrokerageFeeInput({
    required this.transactionType,
    required this.transactionAmount,
  });
}
