import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String kThemeModeKey = 'theme_mode';

const String _system = 'system';
const String _light = 'light';
const String _dark = 'dark';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  /// 전제: `Hive.openBox('app_settings')`가 이 프로바이더보다 먼저 완료되어야 한다.
  /// 앱은 `main.dart`에서 `runApp` 이전에 박스를 열어 이를 보장한다.
  @override
  ThemeMode build() => _read();

  /// 상태는 즉시 갱신하고 디스크 반영은 비동기로 진행한다.
  /// `Box.put`은 `Future<void>`라서 그냥 두면 실패가 조용히 사라지므로,
  /// 실패를 삼키지 않도록 반드시 기록한다. 이 경우 화면의 테마와
  /// 저장된 값이 어긋나 다음 실행에서 이전 테마로 되돌아간다.
  void setMode(ThemeMode mode) {
    state = mode;
    unawaited(
      Hive.box('app_settings').put(kThemeModeKey, _encode(mode)).catchError(
        (Object error, StackTrace stackTrace) {
          developer.log(
            'Failed to persist theme_mode=${_encode(mode)}.',
            name: 'ThemeModeNotifier',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
    );
  }

  ThemeMode _read() {
    final raw = Hive.box('app_settings').get(kThemeModeKey);
    if (raw == null) return ThemeMode.system;
    switch (raw) {
      case _light:
        return ThemeMode.light;
      case _dark:
        return ThemeMode.dark;
      case _system:
        return ThemeMode.system;
      default:
        // 손상된 값을 조용히 넘기지 않고 기록한 뒤 기본값으로 되돌린다.
        developer.log(
          'Unexpected theme_mode value: $raw. Falling back to system.',
          name: 'ThemeModeNotifier',
        );
        return ThemeMode.system;
    }
  }

  String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => _light,
        ThemeMode.dark => _dark,
        ThemeMode.system => _system,
      };
}

final themeModeNotifierProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
