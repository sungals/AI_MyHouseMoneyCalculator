import 'package:intl/intl.dart';

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

  static String _formatKoreanChunk(int value) {
    final thousands = value ~/ 1000;
    final remainder = value % 1000;

    if (thousands == 0) return value.toString();
    if (remainder == 0) return '$thousands천';
    return '$thousands천$remainder';
  }
}
