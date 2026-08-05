import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String kThemeModeKey = 'theme_mode';

const String _system = 'system';
const String _light = 'light';
const String _dark = 'dark';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => _read();

  void setMode(ThemeMode mode) {
    state = mode;
    Hive.box('app_settings').put(kThemeModeKey, _encode(mode));
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
