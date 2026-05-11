import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/supabase_config.dart';
import 'core/notifications/firebase_push_service.dart';
import 'core/notifications/local_notification_service.dart';
import 'data/local/calculation_history_store.dart';
import 'data/models/calculation_history.dart';
import 'router/app_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 백그라운드 isolate에서도 미인증 유저에게 알림 표시하지 않음
  if (Supabase.instance.client.auth.currentSession == null) return;

  final notificationService = LocalNotificationService();
  await notificationService.initialize(
    onSelectNotification: AppRouter.openNoticeFromPush,
  );
  await FirebasePushService.showRemoteMessage(
    message,
    notificationService: notificationService,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Hive.initFlutter();
  Hive.registerAdapter(CalculationHistoryAdapter());
  await Hive.openBox('app_settings');
  await Hive.openBox<CalculationHistory>(CalculationHistoryStore.boxName);

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // 미인증 상태에서 이전 세션에서 등록된 stale 토큰을 DB에서 제거
  if (Supabase.instance.client.auth.currentSession == null) {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await Supabase.instance.client
            .from('push_tokens')
            .delete()
            .eq('token', token)
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
  }

  final notificationService = LocalNotificationService();
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const App(),
    ),
  );
}
