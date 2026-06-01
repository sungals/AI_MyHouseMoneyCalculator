import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_notification_service.dart';
import '../../router/app_router.dart';

class FirebasePushService {
  FirebasePushService({
    FirebaseMessaging? messaging,
    SupabaseClient? client,
    required LocalNotificationService notificationService,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _client = client ?? Supabase.instance.client,
        _notificationService = notificationService;

  final FirebaseMessaging _messaging;
  final SupabaseClient _client;
  final LocalNotificationService _notificationService;

  bool _started = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  static const _noticePushEnabledKey = 'notice_push_enabled';

  static bool get isNoticePushEnabled {
    return Hive.box('app_settings').get(
      _noticePushEnabledKey,
      defaultValue: true,
    ) as bool;
  }

  Future<void> setNoticePushEnabled(bool enabled) async {
    await Hive.box('app_settings').put(_noticePushEnabledKey, enabled);
    if (enabled) {
      await start();
    } else {
      await stop();
    }
  }

  Future<void> start() async {
    if (_started) return;
    if (!isNoticePushEnabled) {
      _debugLog('Skipping push start: notice push disabled.');
      return;
    }
    _started = true;

    try {
      _debugLog('Starting Firebase push service.');
      // iOS는 권한 요청이 필요하고, Android도 OS 버전에 따라 런타임 권한이 필요할 수 있다.
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await _messaging.getToken();
      if (token == null) {
        _debugLog('Firebase push token is null.');
      } else {
        _debugLog('Firebase push token acquired.');
        await _registerToken(token);
      }

      _tokenRefreshSub = _messaging.onTokenRefresh.listen(_registerToken);
      _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
        // foreground 수신은 시스템 알림으로 자동 표시되지 않으므로 로컬 알림으로 재표시한다.
        showRemoteMessage(message, notificationService: _notificationService);
      });
      _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
        _openNoticeFromMessage,
      );

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _openNoticeFromMessage(initialMessage);
      }
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to start Firebase push service.',
        name: 'FirebasePushService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> stop() async {
    _started = false;

    // 계정 전환/로그아웃 후 중복 리스너가 남지 않도록 stream 구독을 모두 정리한다.
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    await _onMessageSub?.cancel();
    _onMessageSub = null;
    await _onMessageOpenedAppSub?.cancel();
    _onMessageOpenedAppSub = null;

    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _client
            .from('push_tokens')
            .delete()
            .eq('token', token)
            .timeout(const Duration(seconds: 10));
        _debugLog('Firebase push token deleted.');
      }
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to delete Firebase push token.',
        name: 'FirebasePushService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _registerToken(String token) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _debugLog('Skipping token registration: user not authenticated.');
      return;
    }

    final values = {
      'token': token,
      'platform': _platform,
      'user_id': user.id,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await _client
          .from('push_tokens')
          .insert(values)
          .timeout(const Duration(seconds: 10));
      _debugLog('Firebase push token registered.');
    } on PostgrestException catch (error, stackTrace) {
      if (error.code == '23505') {
        // 같은 기기 토큰이 이미 있으면 user/platform/updated_at만 최신 상태로 갱신한다.
        await _client
            .from('push_tokens')
            .update(values)
            .eq('token', token)
            .timeout(const Duration(seconds: 10));
        _debugLog('Firebase push token refreshed.');
        return;
      }

      developer.log(
        'Failed to register Firebase push token.',
        name: 'FirebasePushService',
        error: error,
        stackTrace: stackTrace,
      );
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to register Firebase push token.',
        name: 'FirebasePushService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> showRemoteMessage(
    RemoteMessage message, {
    required LocalNotificationService notificationService,
  }) {
    final title = message.notification?.title ??
        message.data['title'] as String? ??
        '공지사항';
    final body =
        message.notification?.body ?? message.data['body'] as String? ?? '';

    if (body.isEmpty && title == '공지사항') {
      return Future<void>.value();
    }

    return notificationService.showNotice(
      title: title,
      body: body,
      noticeId: message.data['notice_id'] as String?,
    );
  }

  void _openNoticeFromMessage(RemoteMessage message) {
    AppRouter.openNoticeFromPush(message.data['notice_id'] as String?);
  }

  String get _platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }

  void _debugLog(String message) {
    if (!kDebugMode) return;
    debugPrint('[FirebasePushService] $message');
  }
}

final firebasePushServiceProvider = Provider<FirebasePushService>((ref) {
  return FirebasePushService(
    notificationService: ref.watch(localNotificationServiceProvider),
  );
});
