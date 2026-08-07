import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:house_money_calculator/core/settings/locale_notifier.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('locale_test');
    Hive.init(tempDir.path);
    await Hive.openBox('app_settings');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('저장된 값이 없으면 null(시스템 따름)이다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeNotifierProvider), isNull);
  });

  test('setLocale이 상태와 Hive를 함께 갱신한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeNotifierProvider.notifier).setLocale(const Locale('en'));

    expect(container.read(localeNotifierProvider), const Locale('en'));
    expect(Hive.box('app_settings').get(kLocaleKey), 'en');
  });

  test('시스템 따름으로 되돌리면 system을 저장한다', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(localeNotifierProvider.notifier);
    notifier.setLocale(const Locale('en'));
    notifier.setLocale(null);

    expect(container.read(localeNotifierProvider), isNull);
    expect(Hive.box('app_settings').get(kLocaleKey), 'system');
  });

  test('저장된 값을 복원한다', () async {
    await Hive.box('app_settings').put(kLocaleKey, 'ko');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeNotifierProvider), const Locale('ko'));
  });

  test('지원하지 않는 값이면 null로 폴백한다', () async {
    await Hive.box('app_settings').put(kLocaleKey, 'ja');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeNotifierProvider), isNull);
  });

  group('resolveLocale', () {
    test('지원 로케일이면 그대로 쓴다', () {
      expect(resolveLocale(const Locale('en'), kSupportedLocales),
          const Locale('en'));
    });

    test('지역 코드가 붙어도 언어 코드로 매칭한다', () {
      expect(resolveLocale(const Locale('en', 'US'), kSupportedLocales),
          const Locale('en'));
    });

    test('미지원 로케일은 ko로 폴백한다', () {
      expect(resolveLocale(const Locale('ja'), kSupportedLocales),
          const Locale('ko'));
    });

    test('기기 로케일이 null이면 ko로 폴백한다', () {
      expect(resolveLocale(null, kSupportedLocales), const Locale('ko'));
    });

    test('폴백은 supported의 첫 항목을 따른다', () {
      const reordered = [Locale('en'), Locale('ko')];

      expect(resolveLocale(const Locale('ja'), reordered), const Locale('en'));
      expect(resolveLocale(null, reordered), const Locale('en'));
    });

    test('supported가 비어 있으면 ko로 폴백한다', () {
      expect(resolveLocale(const Locale('ja'), const []), const Locale('ko'));
      expect(resolveLocale(null, const []), const Locale('ko'));
    });
  });
}
