import 'package:hive/hive.dart';

part 'calculation_history.g.dart';

enum CalculationType {
  rentCompare,
  semiRent,
  loanInterest,
  monthlyExpense,
}

extension CalculationTypeLabel on CalculationType {
  String get label {
    switch (this) {
      case CalculationType.rentCompare:
        return '전세 vs 월세 비교';
      case CalculationType.semiRent:
        return '반전세 계산';
      case CalculationType.loanInterest:
        return '대출이자 계산';
      case CalculationType.monthlyExpense:
        return '월 고정비 계산';
    }
  }
}

@HiveType(typeId: 0)
class CalculationHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int typeIndex;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String summary;

  @HiveField(4)
  final Map<String, dynamic> input;

  @HiveField(5)
  final Map<String, dynamic> result;

  @HiveField(6)
  final DateTime createdAt;

  CalculationHistory({
    required this.id,
    required this.typeIndex,
    required this.title,
    required this.summary,
    required this.input,
    required this.result,
    required this.createdAt,
  });

  CalculationType get type => CalculationType.values[typeIndex];
}
