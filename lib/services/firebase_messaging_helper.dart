import 'dart:async'; // ← أضف هذا السطر
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../helpers/notifications_helper.dart';

class FirebaseMessagingHelper {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // ستريم عالمي عند وصول إشعار جديد (للتحديث الفوري للنقطة الحمراء)
  static final StreamController<void> notificationStreamController = StreamController.broadcast();

  // تهيئة الإشعارات: استدعيها في main بعد Firebase.initializeApp()
  static Future<void> initFCM() async {
    // طلب صلاحيات الإشعار (لأندرويد وiOS)
    await _messaging.requestPermission();

    // تهيئة flutter_local_notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // قناة الإشعار (لأندرويد)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'loom_channel',
      'Loom Notifications',
      description: 'اشعارات loom',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // استقبال إشعارات أثناء عمل التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
      // ← إشعار وصول إشعار جديد (تحديث النقطة الحمراء في الواجهة)
      notificationStreamController.add(null);
    });
  }

  // دالة لجلب FCM Token
  static Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }

  // إظهار إشعار محلي وتخزينه في SharedPreferences
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    // 🟡 حفظ الإشعار محليًا
    await NotificationsHelper.addNotification(
      title: message.notification?.title ?? 'إشعار Loom',
      body: message.notification?.body ?? '',
      date: DateTime.now(),
      type: message.data['type'] ?? 'general',
    );

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'loom_channel',
      'Loom Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title ?? 'إشعار Loom',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }
}
