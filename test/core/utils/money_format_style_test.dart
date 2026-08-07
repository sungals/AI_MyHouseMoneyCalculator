import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/utils/money_format_style.dart';
import 'package:house_money_calculator/core/utils/money_formatter.dart';

void main() {
  group('moneyStyleFor', () {
    test('en은 western이다', () {
      expect(moneyStyleFor(const Locale('en')), MoneyFormatStyle.western);
    });

    test('ko는 korean이다', () {
      expect(moneyStyleFor(const Locale('ko')), MoneyFormatStyle.korean);
    });

    test('null은 korean으로 폴백한다', () {
      expect(moneyStyleFor(null), MoneyFormatStyle.korean);
    });
  });

  group('formatCompact - korean', () {
    test('기존 formatKorean과 완전히 같은 출력을 낸다', () {
      for (final amount in [0, 3500, 10000, 20000000, 105000000, 320000000]) {
        expect(
          MoneyFormatter.formatCompact(amount, MoneyFormatStyle.korean),
          MoneyFormatter.formatKorean(amount),
          reason: '금액 $amount에서 ko 출력이 달라졌다',
        );
      }
    });
  });

  group('formatCompact - western', () {
    test('억/만/원 단위를 쓰지 않는다', () {
      final result =
          MoneyFormatter.formatCompact(320000000, MoneyFormatStyle.western);
      expect(result, isNot(contains('억')));
      expect(result, isNot(contains('만')));
      expect(result, isNot(contains('원')));
    });

    test('통화를 KRW로 표기한다', () {
      expect(MoneyFormatter.formatCompact(320000000, MoneyFormatStyle.western),
          startsWith('KRW '));
    });

    test('백만 단위는 M을 쓴다', () {
      expect(MoneyFormatter.formatCompact(320000000, MoneyFormatStyle.western),
          'KRW 320M');
    });

    test('십억 단위는 B를 쓴다', () {
      expect(MoneyFormatter.formatCompact(2500000000, MoneyFormatStyle.western),
          'KRW 2.5B');
    });

    test('천 단위는 K를 쓴다', () {
      expect(MoneyFormatter.formatCompact(35000, MoneyFormatStyle.western),
          'KRW 35K');
    });

    test('천 미만은 단위 없이 표기한다', () {
      expect(MoneyFormatter.formatCompact(500, MoneyFormatStyle.western),
          'KRW 500');
    });

    test('0 이하는 빈 문자열이다', () {
      expect(MoneyFormatter.formatCompact(0, MoneyFormatStyle.western), '');
      expect(MoneyFormatter.formatCompact(-1, MoneyFormatStyle.western), '');
    });
  });

  group('formatCompact - western rounding rule', () {
    test('반올림 규칙: 소수점 첫째 자리까지 표시하되, 정수면 소수점 제거', () {
      // K 단위에서 소수가 되는 경우
      expect(MoneyFormatter.formatCompact(1234, MoneyFormatStyle.western),
          'KRW 1.2K');
      expect(MoneyFormatter.formatCompact(1560, MoneyFormatStyle.western),
          'KRW 1.6K');

      // K 단위에서 정수가 되는 경우
      expect(MoneyFormatter.formatCompact(1000, MoneyFormatStyle.western),
          'KRW 1K');
      expect(MoneyFormatter.formatCompact(2000, MoneyFormatStyle.western),
          'KRW 2K');
    });

    test('M 단위에서도 같은 규칙을 적용한다', () {
      // M 단위에서 소수가 되는 경우
      expect(MoneyFormatter.formatCompact(1234000, MoneyFormatStyle.western),
          'KRW 1.2M');
      expect(MoneyFormatter.formatCompact(1560000, MoneyFormatStyle.western),
          'KRW 1.6M');

      // M 단위에서 정수가 되는 경우
      expect(MoneyFormatter.formatCompact(1000000, MoneyFormatStyle.western),
          'KRW 1M');
      expect(MoneyFormatter.formatCompact(2000000, MoneyFormatStyle.western),
          'KRW 2M');
    });

    test('B 단위에서도 같은 규칙을 적용한다', () {
      // B 단위에서 정수가 되는 경우
      expect(MoneyFormatter.formatCompact(1000000000, MoneyFormatStyle.western),
          'KRW 1B');

      // B 단위에서 소수가 되는 경우
      expect(MoneyFormatter.formatCompact(1234000000, MoneyFormatStyle.western),
          'KRW 1.2B');
    });

    test('반올림으로 1000이 되면 다음 단위로 승격한다', () {
      // K → M 승격: 999999 / 1000 = 999.999 → 1000K가 아니라 1M
      expect(MoneyFormatter.formatCompact(999999, MoneyFormatStyle.western),
          'KRW 1M');

      // M → B 승격: 999999999 / 1000000 = 999.999999 → 1000M이 아니라 1B
      expect(MoneyFormatter.formatCompact(999999999, MoneyFormatStyle.western),
          'KRW 1B');

      // 승격 경계 아래: 999500은 999.5K로 승격하지 않음
      expect(MoneyFormatter.formatCompact(999500, MoneyFormatStyle.western),
          'KRW 999.5K');
    });

    test('정확한 단위 경계값을 올바르게 포맷한다', () {
      // K 단위 시작: 1000원 = 1K
      expect(MoneyFormatter.formatCompact(1000, MoneyFormatStyle.western),
          'KRW 1K');

      // M 단위 시작: 1,000,000원 = 1M
      expect(MoneyFormatter.formatCompact(1000000, MoneyFormatStyle.western),
          'KRW 1M');

      // B 단위 시작: 1,000,000,000원 = 1B
      expect(MoneyFormatter.formatCompact(1000000000, MoneyFormatStyle.western),
          'KRW 1B');
    });
  });
}
