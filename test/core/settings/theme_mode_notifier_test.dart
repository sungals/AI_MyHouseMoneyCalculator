import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/theme_mode_notifier.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('theme_mode_test');
    Hive.init(tempDir.path);
    await Hive.openBox('app_settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('저장된 값이 없으면 system이다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.system);
  });

  test('setMode가 상태와 Hive를 함께 갱신한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(themeModeNotifierProvider.notifier).setMode(ThemeMode.dark);

    expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    expect(Hive.box('app_settings').get(kThemeModeKey), 'dark');
  });

  test('저장된 값을 복원한다', () async {
    await Hive.box('app_settings').put(kThemeModeKey, 'light');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.light);
  });

  test('알 수 없는 문자열이면 system으로 폴백한다', () async {
    await Hive.box('app_settings').put(kThemeModeKey, 'purple');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.system);
  });

  test('타입이 다른 값이어도 system으로 폴백한다', () async {
    await Hive.box('app_settings').put(kThemeModeKey, 42);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeNotifierProvider), ThemeMode.system);
  });

  test('기존 설정 키를 건드리지 않는다', () async {
    await Hive.box('app_settings').put('login_skipped', true);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(themeModeNotifierProvider.notifier).setMode(ThemeMode.dark);

    expect(Hive.box('app_settings').get('login_skipped'), isTrue);
  });
}
