import '../entities/brokerage_fee_input.dart';
import '../entities/brokerage_fee_result.dart';

class BrokerageFeeCalculator {
  BrokerageFeeResult calculate(BrokerageFeeInput input) {
    final bracket = input.transactionType == BrokerageTransactionType.sale
        ? _saleBracket(input.transactionAmount)
        : _leaseBracket(input.transactionAmount);
    final rawFee = (input.transactionAmount * bracket.rate).round();

    return BrokerageFeeResult(
      fee: bracket.cap == null ? rawFee : rawFee.clamp(0, bracket.cap!),
      rate: bracket.rate,
      cap: bracket.cap,
    );
  }

  _FeeBracket _saleBracket(int amount) {
    if (amount < 50000000) return const _FeeBracket(0.006, 250000);
    if (amount < 200000000) return const _FeeBracket(0.005, 800000);
    if (amount < 900000000) return const _FeeBracket(0.004, null);
    if (amount < 1200000000) return const _FeeBracket(0.005, null);
    if (amount < 1500000000) return const _FeeBracket(0.006, null);
    return const _FeeBracket(0.007, null);
  }

  _FeeBracket _leaseBracket(int amount) {
    if (amount < 50000000) return const _FeeBracket(0.005, 200000);
    if (amount < 100000000) return const _FeeBracket(0.004, 300000);
    if (amount < 600000000) return const _FeeBracket(0.003, null);
    if (amount < 1200000000) return const _FeeBracket(0.004, null);
    if (amount < 1500000000) return const _FeeBracket(0.005, null);
    return const _FeeBracket(0.006, null);
  }
}

class _FeeBracket {
  final double rate;
  final int? cap;

  const _FeeBracket(this.rate, this.cap);
}
