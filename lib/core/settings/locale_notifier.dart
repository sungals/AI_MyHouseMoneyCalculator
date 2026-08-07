import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String kLocaleKey = 'locale';

const List<Locale> kSupportedLocales = [Locale('ko'), Locale('en')];

const String _system = 'system';

/// 상태가 null이면 "시스템 설정 따름"을 뜻한다.
class LocaleNotifier extends Notifier<Locale?> {
  /// 전제: `Hive.openBox('app_settings')`가 이 프로바이더보다 먼저 완료되어야 한다.
  /// 앱은 `main.dart`에서 `runApp` 이전에 박스를 열어 이를 보장한다.
  @override
  Locale? build() => _read();

  /// 상태는 즉시 갱신하고 디스크 반영은 비동기로 진행한다.
  /// `Box.put`은 `Future<void>`라서 그냥 두면 실패가 조용히 사라지므로,
  /// 실패를 삼키지 않도록 반드시 기록한다. 이 경우 화면의 언어와
  /// 저장된 값이 어긋나 다음 실행에서 이전 언어로 되돌아간다.
  void setLocale(Locale? locale) {
    state = locale;
    final encoded = locale?.languageCode ?? _system;
    unawaited(
      Hive.box('app_settings').put(kLocaleKey, encoded).catchError(
        (Object error, StackTrace stackTrace) {
          developer.log(
            'Failed to persist locale=$encoded.',
            name: 'LocaleNotifier',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
    );
  }

  Locale? _read() {
    final raw = Hive.box('app_settings').get(kLocaleKey);
    if (raw == null || raw == _system) return null;
    for (final locale in kSupportedLocales) {
      if (locale.languageCode == raw) return locale;
    }
    developer.log(
      'Unexpected locale value: $raw. Falling back to system.',
      name: 'LocaleNotifier',
    );
    return null;
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

/// MaterialApp.localeResolutionCallback에 연결한다.
/// 지원 목록에 없는 기기 로케일은 목록의 첫 항목으로 폴백한다.
///
/// 빈 목록 가드는 방어용이다. 실제 호출자는 항상 비어 있지 않은
/// [kSupportedLocales]를 넘기므로 프로덕션에서는 도달하지 않는다.
/// "빈 목록이 될 수 있는 설정이 어딘가 있나?" 하는 오해를 막기 위해 적어 둔다.
Locale resolveLocale(Locale? deviceLocale, Iterable<Locale> supported) {
  if (deviceLocale != null) {
    for (final locale in supported) {
      if (locale.languageCode == deviceLocale.languageCode) return locale;
    }
  }
  return supported.isEmpty ? const Locale('ko') : supported.first;
}
