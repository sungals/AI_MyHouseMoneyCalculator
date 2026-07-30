import 'package:hive/hive.dart';

part 'calculation_history.g.dart';

enum CalculationType {
  rentCompare,
  semiRent,
  loanInterest,
  monthlyExpense,
  taxDeduction,
  dsrDti,
  brokerageFee,
  acquisitionTax,
  contractRenewal,
  jeonseRisk,
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
      case CalculationType.dsrDti:
        return 'DSR/DTI 계산';
      case CalculationType.brokerageFee:
        return '중개보수 계산';
      case CalculationType.acquisitionTax:
        return '취득세 계산';
      case CalculationType.contractRenewal:
        return '계약 갱신 계산';
      case CalculationType.jeonseRisk:
        return '전세사기 위험도 체크';
    }
  }
}

// Hive type/field 번호는 기존 사용자 로컬 데이터와 호환된다.
// 새 필드를 추가할 때 기존 번호를 바꾸거나 재사용하면 저장된 이력을 읽지 못할 수 있다.
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

  @HiveField(8)
  final String memo;

  @HiveField(9)
  final bool isFavorite;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final DateTime? deletedAt;

  CalculationHistory({
    required this.id,
    required this.typeIndex,
    required this.title,
    required this.summary,
    required this.input,
    required this.result,
    required this.createdAt,
    this.syncedAt,
    this.memo = '',
    this.isFavorite = false,
    DateTime? updatedAt,
    this.deletedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  CalculationType get type => CalculationType.values[typeIndex];
  bool get isDeleted => deletedAt != null;

  CalculationHistory copyWith({
    String? id,
    int? typeIndex,
    String? title,
    String? summary,
    Map<String, dynamic>? input,
    Map<String, dynamic>? result,
    DateTime? createdAt,
    DateTime? syncedAt,
    String? memo,
    bool? isFavorite,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
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
      memo: memo ?? this.memo,
      isFavorite: isFavorite ?? this.isFavorite,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }

  String get featureType {
    // 원격 저장소에는 enum index 대신 안정적인 문자열 key를 저장한다.
    // enum 순서가 바뀌는 리팩터링이 필요하면 이 매핑도 함께 migration해야 한다.
    const types = [
      'rent_compare',
      'semi_rent',
      'loan_interest',
      'monthly_expense',
      'tax_deduction',
      'dsr_dti',
      'brokerage_fee',
      'acquisition_tax',
      'contract_renewal',
      'jeonse_risk',
    ];
    return types[typeIndex];
  }

  Map<String, dynamic> toRemoteJson() {
    return {
      'id': id,
      'feature_type': featureType,
      'title': title,
      'summary': summary,
      'input_data': input,
      'result_data': result,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'memo': memo,
      'is_favorite': isFavorite,
      'synced_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  factory CalculationHistory.fromRemoteJson(Map<String, dynamic> json) {
    // 원격 DB의 feature_type 문자열을 앱 내부 enum index로 되돌린다.
    const featureTypeMap = {
      'rent_compare': 0,
      'semi_rent': 1,
      'loan_interest': 2,
      'monthly_expense': 3,
      'tax_deduction': 4,
      'dsr_dti': 5,
      'brokerage_fee': 6,
      'acquisition_tax': 7,
      'contract_renewal': 8,
      'jeonse_risk': 9,
    };
    final createdAt = DateTime.parse(json['created_at'] as String);
    return CalculationHistory(
      id: json['id'] as String,
      typeIndex: featureTypeMap[json['feature_type'] as String] ?? 0,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      input: Map<String, dynamic>.from(json['input_data'] as Map? ?? {}),
      result: Map<String, dynamic>.from(json['result_data'] as Map? ?? {}),
      createdAt: createdAt,
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
      memo: json['memo'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : createdAt,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }
}
