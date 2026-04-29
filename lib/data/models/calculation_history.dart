import 'package:hive/hive.dart';

part 'calculation_history.g.dart';

enum CalculationType {
  rentCompare,
  semiRent,
  loanInterest,
  monthlyExpense,
  taxDeduction,
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
      case CalculationType.taxDeduction:
        return '세금 공제 계산';
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

  @HiveField(7)
  final DateTime? syncedAt;

  CalculationHistory({
    required this.id,
    required this.typeIndex,
    required this.title,
    required this.summary,
    required this.input,
    required this.result,
    required this.createdAt,
    this.syncedAt,
  });

  CalculationType get type => CalculationType.values[typeIndex];

  CalculationHistory copyWith({
    String? id,
    int? typeIndex,
    String? title,
    String? summary,
    Map<String, dynamic>? input,
    Map<String, dynamic>? result,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return CalculationHistory(
      id: id ?? this.id,
      typeIndex: typeIndex ?? this.typeIndex,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      input: input ?? Map.from(this.input),
      result: result ?? Map.from(this.result),
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  String get featureType {
    const types = [
      'rent_compare',
      'semi_rent',
      'loan_interest',
      'monthly_expense',
      'tax_deduction',
    ];
    return types[typeIndex];
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'feature_type': featureType,
      'title': title,
      'summary': summary,
      'input_data': input,
      'result_data': result,
      'created_at': createdAt.toUtc().toIso8601String(),
      'synced_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  factory CalculationHistory.fromSupabaseJson(Map<String, dynamic> json) {
    const featureTypeMap = {
      'rent_compare': 0,
      'semi_rent': 1,
      'loan_interest': 2,
      'monthly_expense': 3,
      'tax_deduction': 4,
    };
    return CalculationHistory(
      id: json['id'] as String,
      typeIndex: featureTypeMap[json['feature_type'] as String] ?? 0,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      input: Map<String, dynamic>.from(json['input_data'] as Map? ?? {}),
      result: Map<String, dynamic>.from(json['result_data'] as Map? ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }
}
