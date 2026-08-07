import 'package:intl/intl.dart';

import 'money_format_style.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final _formatter = NumberFormat('#,###', 'ko_KR');

  static String format(int amount) => _formatter.format(amount);

  static String formatWithWon(int amount) => '${_formatter.format(amount)}원';

  static String formatKorean(int amount) {
    if (amount <= 0) return '';

    final eok = amount ~/ 100000000;
    final man = (amount % 100000000) ~/ 10000;
    final won = amount % 10000;
    final parts = <String>[];

    if (eok > 0) parts.add('${_formatKoreanChunk(eok)}억');
    if (man > 0) parts.add('${_formatKoreanChunk(man)}만원');
    if (won > 0 && eok == 0 && man == 0) {
      parts.add('${_formatter.format(won)}원');
    }

    return parts.join();
  }

  static int parse(String text) {
    final cleaned = text.replaceAll(',', '').replaceAll('원', '').trim();
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }

  /// 로케일에 맞는 축약 표기. korean은 기존 formatKorean과 동일하다.
  static String formatCompact(int amount, MoneyFormatStyle style) {
    return switch (style) {
      MoneyFormatStyle.korean => formatKorean(amount),
      MoneyFormatStyle.western => _formatWestern(amount),
    };
  }

  /// 서구식 축약 표기: K(천), M(백만), B(십억) 단위.
  /// 반올림 규칙: 소수점 첫째 자리까지 반올림하되, 결과가 정수면 소수점을 제거한다.
  /// 예: 1234 → "1.2K", 35000 → "35K", 2500000000 → "2.5B"
  static String _formatWestern(int amount) {
    if (amount <= 0) return '';
    if (amount >= 1000000000) return 'KRW ${_trim(amount / 1000000000)}B';
    if (amount >= 1000000) return 'KRW ${_trim(amount / 1000000)}M';
    if (amount >= 1000) return 'KRW ${_trim(amount / 1000)}K';
    return 'KRW $amount';
  }

  /// 소수 첫째 자리까지 쓰되 .0은 떼어낸다.
  static String _trim(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.truncateToDouble()
        ? rounded.truncate().toString()
        : rounded.toString();
  }

  static String _formatKoreanChunk(int value) {
    final thousands = value ~/ 1000;
    final remainder = value % 1000;

    if (thousands == 0) return value.toString();
    if (remainder == 0) return '$thousands천';
    return '$thousands천$remainder';
  }
}
