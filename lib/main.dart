import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/ads/ad_unit_ids.dart';
import 'core/notifications/firebase_push_service.dart';
import 'core/notifications/local_notification_service.dart';
import 'data/local/calculation_history_store.dart';
import 'data/models/calculation_history.dart';
import 'router/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // 백그라운드 isolate에서도 미인증 유저에게 알림 표시하지 않음
  if (FirebaseAuth.instance.currentUser == null) return;

  final notificationService = LocalNotificationService();
  await notificationService.initialize(
    onSelectNotification: AppRouter.openNoticeFromPush,
  );
  await FirebasePushService.showRemoteMessage(
    message,
    notificationService: notificationService,
  );
}

void main() {
  bootstrap();
}

Future<void> bootstrap({
  bool initializeAds = true,
  bool initializeNotifications = true,
  bool cleanupStalePushToken = true,
  bool resetLoginSkipOnNoSession = true,
  bool clearPersistedSession = false,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (initializeAds && AdUnitIds.hasApplicationId) {
    await MobileAds.instance.initialize();
  }
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Hive box는 router redirect, PIN, 설정 화면, 계산 이력에서 즉시 접근하므로
  // runApp 전에 모두 열어 둔다.
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CalculationHistoryAdapter());
  }
  await Hive.openBox('app_settings');
  await Hive.openBox<CalculationHistory>(CalculationHistoryStore.boxName);

  if (clearPersistedSession) {
    await FirebaseAuth.instance.signOut();
  }

  if (resetLoginSkipOnNoSession &&
      FirebaseAuth.instance.currentUser == null) {
    await Hive.box('app_settings').put('login_skipped', false);
  }

  // 미인증 상태에서 이전 세션에서 등록된 stale 토큰을 DB에서 제거
  if (cleanupStalePushToken &&
      FirebaseAuth.instance.currentUser == null) {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final tokenId = base64Url.encode(utf8.encode(token));
        await FirebaseFirestore.instance
            .collection('push_tokens')
            .doc(tokenId)
            .delete()
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
  }

  final notificationService = LocalNotificationService();
  if (initializeNotifications) {
    await notificationService.initialize();
  }

  runApp(
    ProviderScope(
      overrides: [
        localNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const App(),
    ),
  );
}
