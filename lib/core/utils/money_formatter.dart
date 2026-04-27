import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final _formatter = NumberFormat('#,###', 'ko_KR');

  static String format(int amount) => _formatter.format(amount);

  static String formatWithWon(int amount) => '${_formatter.format(amount)}원';

  static int parse(String text) {
    final cleaned = text.replaceAll(',', '').replaceAll('원', '').trim();
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }
}
