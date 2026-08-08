import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationLabels {
  final String noticeChannelName;
  final String noticeChannelDescription;
  final String noticeFallbackTitle;

  const NotificationLabels({
    required this.noticeChannelName,
    required this.noticeChannelDescription,
    required this.noticeFallbackTitle,
  });

  static const fallback = NotificationLabels(
    noticeChannelName: 'Notice',
    noticeChannelDescription: 'New notice alerts',
    noticeFallbackTitle: 'Notice',
  );
}

class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationLabels _labels = NotificationLabels.fallback;

  Future<void> initialize({
    NotificationLabels labels = NotificationLabels.fallback,
    void Function(String? payload)? onSelectNotification,
  }) async {
    _labels = labels;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: (response) {
        onSelectNotification?.call(response.payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        'notices',
        labels.noticeChannelName,
        description: labels.noticeChannelDescription,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showNotice({
    required String title,
    required String body,
    String? noticeId,
  }) {
    return _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      _notificationDetails,
      payload: noticeId,
    );
  }

  String get noticeFallbackTitle => _labels.noticeFallbackTitle;

  NotificationDetails get _notificationDetails => NotificationDetails(
        android: AndroidNotificationDetails(
          'notices',
          _labels.noticeChannelName,
          channelDescription: _labels.noticeChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
}

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);
