import 'package:flutter_test/flutter_test.dart';

import '../../tool/merge_arb.dart';

void main() {
  const namespaces = {'common', 'history', 'settings'};

  test('프래그먼트 키를 베이스에 합친다', () {
    final result = mergeArb(
      base: {'@@locale': 'ko', 'commonCancel': '취소'},
      fragments: [
        (name: 's03', content: {'historyEmptyMessage': '이력이 없습니다'}),
      ],
      allowedNamespaces: namespaces,
    );

    expect(result['commonCancel'], '취소');
    expect(result['historyEmptyMessage'], '이력이 없습니다');
    expect(result['@@locale'], 'ko');
  });

  test('두 프래그먼트가 같은 키를 만들면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03', content: {'historyTitle': '이력'}),
          (name: 's04', content: {'historyTitle': '기록'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('프래그먼트가 베이스의 common 키를 덮어쓰면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko', 'commonCancel': '취소'},
        fragments: [
          (name: 's03', content: {'commonCancel': '취소하기'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('프래그먼트가 새 common 키를 만들면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03', content: {'commonWhatever': '뭔가'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('알 수 없는 네임스페이스면 에러', () {
    expect(
      () => mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03', content: {'unknownThing': '값'}),
        ],
        allowedNamespaces: namespaces,
      ),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('@ 메타 키도 함께 병합된다', () {
    final result = mergeArb(
      base: {'@@locale': 'ko'},
      fragments: [
        (
          name: 's03',
          content: {
            'historyTitle': '이력',
            '@historyTitle': {'description': '이력 화면 제목'},
          }
        ),
      ],
      allowedNamespaces: namespaces,
    );

    expect(result['@historyTitle'], isA<Map>());
  });

  test('에러 메시지에 프래그먼트 이름과 키가 들어간다', () {
    try {
      mergeArb(
        base: {'@@locale': 'ko'},
        fragments: [
          (name: 's03_history', content: {'badKey': '값'}),
        ],
        allowedNamespaces: namespaces,
      );
      fail('예외가 발생해야 한다');
    } on ArbMergeException catch (e) {
      expect(e.message, contains('s03_history'));
      expect(e.message, contains('badKey'));
    }
  });

  test('프래그먼트가 없으면 베이스를 그대로 반환한다', () {
    final result = mergeArb(
      base: {'@@locale': 'ko', 'commonCancel': '취소'},
      fragments: [],
      allowedNamespaces: namespaces,
    );

    expect(result, {'@@locale': 'ko', 'commonCancel': '취소'});
  });
}
