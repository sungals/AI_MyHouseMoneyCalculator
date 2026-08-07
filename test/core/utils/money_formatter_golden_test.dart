// MoneyFormatter 한국어 출력 골든 스냅샷.
//
// 이 파일의 기대값은 Task 10(로케일 분기) 착수 **이전**의 실제 출력을 그대로
// 캡처한 것이다. 계획서의 전역 제약이 "MoneyFormatter 의 한국어 출력은 문자
// 단위로 동일해야 한다"이고, 앱 전반 14개 파일 157곳이 이 함수를 지난다.
//
// 따라서 이 기대값들은 **고쳐서 통과시키면 안 된다.** 여기가 깨졌다면 한국어
// 출력이 실제로 바뀐 것이고, 그건 회귀다. 값을 수정하는 대신 구현을 되돌릴 것.
// (의도적으로 표기를 바꾸는 별도 결정이 있다면 그때만 사람이 갱신한다.)
import 'package:flutter_test/flutter_test.dart';
import 'package:house_money_calculator/core/utils/money_formatter.dart';

/// 한 입력값에 대한 세 함수의 기대 출력.
class _G {
  final int input;
  final String format;
  final String formatWithWon;
  final String formatKorean;

  const _G(this.input, this.format, this.formatWithWon, this.formatKorean);
}

const _golden = <_G>[
  // 0과 음수 — formatKorean 은 빈 문자열을 돌려준다
  _G(0, '0', '0원', ''),
  _G(-1, '-1', '-1원', ''),
  _G(-10000, '-10,000', '-10,000원', ''),

  // 만원 미만 — 원 단위 그대로
  _G(1, '1', '1원', '1원'),
  _G(9, '9', '9원', '9원'),
  _G(10, '10', '10원', '10원'),
  _G(999, '999', '999원', '999원'),
  _G(1000, '1,000', '1,000원', '1,000원'),
  _G(1001, '1,001', '1,001원', '1,001원'),
  _G(9999, '9,999', '9,999원', '9,999원'),
  _G(1234, '1,234', '1,234원', '1,234원'),

  // 만 단위 — 만원 미만 나머지는 버린다
  _G(10000, '10,000', '10,000원', '1만원'),
  _G(10001, '10,001', '10,001원', '1만원'),
  _G(19999, '19,999', '19,999원', '1만원'),
  _G(20000, '20,000', '20,000원', '2만원'),
  _G(12345, '12,345', '12,345원', '1만원'),
  _G(123456, '123,456', '123,456원', '12만원'),
  _G(1234567, '1,234,567', '1,234,567원', '123만원'),

  // 천 단위 묶음이 들어가는 만 단위
  _G(12340000, '12,340,000', '12,340,000원', '1천234만원'),
  _G(12345678, '12,345,678', '12,345,678원', '1천234만원'),
  _G(50000000, '50,000,000', '50,000,000원', '5천만원'),
  _G(99990000, '99,990,000', '99,990,000원', '9천999만원'),
  _G(99999999, '99,999,999', '99,999,999원', '9천999만원'),

  // 억 단위
  _G(100000000, '100,000,000', '100,000,000원', '1억'),
  _G(100000001, '100,000,001', '100,000,001원', '1억'),
  _G(100010000, '100,010,000', '100,010,000원', '1억1만원'),
  _G(123456789, '123,456,789', '123,456,789원', '1억2천345만원'),
  _G(305000000, '305,000,000', '305,000,000원', '3억500만원'),
  _G(1000000000, '1,000,000,000', '1,000,000,000원', '10억'),
  _G(10000000000, '10,000,000,000', '10,000,000,000원', '100억'),
  _G(123456789012, '123,456,789,012', '123,456,789,012원',
      '1천234억5천678만원'),
];

void main() {
  group('MoneyFormatter 골든 스냅샷 (한국어 출력 고정)', () {
    for (final g in _golden) {
      test('${g.input} -> format', () {
        expect(MoneyFormatter.format(g.input), g.format);
      });

      test('${g.input} -> formatWithWon', () {
        expect(MoneyFormatter.formatWithWon(g.input), g.formatWithWon);
      });

      test('${g.input} -> formatKorean', () {
        expect(MoneyFormatter.formatKorean(g.input), g.formatKorean);
      });
    }
  });

  group('MoneyFormatter.parse 왕복', () {
    test('formatWithWon 출력을 parse 하면 원래 값으로 돌아온다', () {
      for (final g in _golden) {
        if (g.input < 0) continue;
        expect(
          MoneyFormatter.parse(g.formatWithWon),
          g.input,
          reason: '입력 ${g.input}',
        );
      }
    });

    test('빈 문자열과 쓰레기 입력은 0이다', () {
      expect(MoneyFormatter.parse(''), 0);
      expect(MoneyFormatter.parse('   '), 0);
      expect(MoneyFormatter.parse('abc'), 0);
      expect(MoneyFormatter.parse('원'), 0);
    });
  });
}
