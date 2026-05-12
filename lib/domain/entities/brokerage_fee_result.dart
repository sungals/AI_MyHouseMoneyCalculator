class BrokerageFeeResult {
  final int fee;
  final double rate;
  final int? cap;

  const BrokerageFeeResult({
    required this.fee,
    required this.rate,
    required this.cap,
  });
}
