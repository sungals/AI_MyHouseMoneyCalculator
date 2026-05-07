import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_notification_service.dart';

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

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      _debugLog('Starting Firebase push service.');
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
        showRemoteMessage(message, notificationService: _notificationService);
      });
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
    if (!_started) return;
    _started = false;

    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    await _onMessageSub?.cancel();
    _onMessageSub = null;

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
    final body = message.notification?.body ??
        message.data['body'] as String? ??
        '';

    if (body.isEmpty && title == '공지사항') {
      return Future<void>.value();
    }

    return notificationService.showNotice(title: title, body: body);
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
