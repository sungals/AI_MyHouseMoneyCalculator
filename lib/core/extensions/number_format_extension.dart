import 'package:intl/intl.dart';

extension NumberFormatExtension on num {
  String get wonFormat {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(this)}원';
  }

  String get commaFormat {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(this);
  }
}

extension IntFormatExtension on int {
  String get wonFormat {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(this)}원';
  }

  String get commaFormat {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(this);
  }
}
