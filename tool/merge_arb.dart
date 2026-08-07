import 'dart:convert';
import 'dart:io';

class ArbMergeException implements Exception {
  final String message;
  ArbMergeException(this.message);

  @override
  String toString() => 'ArbMergeException: $message';
}

typedef ArbFragment = ({String name, Map<String, dynamic> content});

/// 베이스 ARB에 슬라이스 프래그먼트를 합친다.
/// 중복 키, 네임스페이스 위반, common 키 재정의는 경고가 아니라 에러다.
Map<String, dynamic> mergeArb({
  required Map<String, dynamic> base,
  required List<ArbFragment> fragments,
  required Set<String> allowedNamespaces,
}) {
  final merged = Map<String, dynamic>.from(base);
  final owner = <String, String>{for (final key in base.keys) key: 'base'};

  for (final fragment in fragments) {
    for (final entry in fragment.content.entries) {
      final key = entry.key;
      if (key.startsWith('@@')) continue;

      final plainKey = key.startsWith('@') ? key.substring(1) : key;
      _checkNamespace(fragment.name, plainKey, allowedNamespaces);

      if (owner.containsKey(key)) {
        throw ArbMergeException(
          '중복 키 "$key": ${owner[key]}와 ${fragment.name}이 모두 정의했다.',
        );
      }

      merged[key] = entry.value;
      owner[key] = fragment.name;
    }
  }

  return merged;
}

void _checkNamespace(
  String fragmentName,
  String key,
  Set<String> allowedNamespaces,
) {
  if (key.startsWith('common')) {
    throw ArbMergeException(
      '$fragmentName의 "$key": common 네임스페이스는 베이스 ARB에서만 정의한다. '
      '슬라이스는 자기 feature 네임스페이스를 써야 한다.',
    );
  }

  final matched =
      allowedNamespaces.any((ns) => ns != 'common' && key.startsWith(ns));
  if (!matched) {
    throw ArbMergeException(
      '$fragmentName의 "$key": 허용되지 않은 네임스페이스다. '
      '허용 목록: ${allowedNamespaces.join(", ")}',
    );
  }
}

const _namespaces = {
  'common',
  'app',
  'settings',
  'guide',
  'history',
  'auth',
  'onboarding',
  'jeonseRisk',
  'rentCompare',
  'semiRent',
  'home',
  'scenarioCompare',
  'contractRenewal',
  'monthlyExpense',
  'loanInterest',
  'taxDeduction',
  'advanced',
  'admin',
  'shared',
  'validation',
  'pdf',
  'notification',
};

Future<void> main() async {
  for (final locale in ['ko', 'en']) {
    final baseFile = File('lib/l10n/app_$locale.arb');
    final base =
        jsonDecode(await baseFile.readAsString()) as Map<String, dynamic>;

    final dir = Directory('lib/l10n/fragments');
    final fragments = <ArbFragment>[];

    if (dir.existsSync()) {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.$locale.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final content =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        fragments.add((name: file.uri.pathSegments.last, content: content));
      }
    }

    final merged = mergeArb(
      base: base,
      fragments: fragments,
      allowedNamespaces: _namespaces,
    );

    await baseFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(merged)}\n',
    );
    stdout.writeln('$locale: ${fragments.length}개 프래그먼트 병합 완료');
  }
}
