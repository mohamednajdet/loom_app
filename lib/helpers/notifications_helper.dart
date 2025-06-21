import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsHelper {
  static const _key = 'loom_notifications';
  static const _lastSeenKey = 'loom_notifications_last_seen';

  /// إضافة إشعار جديد
  static Future<void> addNotification({
    required String title,
    required String body,
    required DateTime date,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];

    final newNotification = jsonEncode({
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'type': type,
    });

    rawList.insert(0, newNotification);
    if (rawList.length > 30) {
      rawList.removeLast();
    }
    await prefs.setStringList(_key, rawList);
  }

  /// جلب الإشعارات كـ List
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((e) {
      final json = jsonDecode(e);
      return {
        'title': json['title'],
        'body': json['body'],
        'date': DateTime.parse(json['date']),
        'type': json['type'],
      };
    }).toList();
  }

  /// مسح جميع الإشعارات
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// حفظ آخر وقت فتح فيه المستخدم شاشة الإشعارات
  static Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenKey, DateTime.now().toIso8601String());
  }

  /// هل يوجد إشعار جديد لم يُقرأ؟
  static Future<bool> hasUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    final lastSeenStr = prefs.getString(_lastSeenKey);

    if (rawList.isEmpty) return false;
    final latest = jsonDecode(rawList.first);
    final latestDate = DateTime.parse(latest['date']);

    if (lastSeenStr == null) {
      // إذا أول مرة يفتح الإشعارات اعتبرها كلها unread
      return true;
    }
    final lastSeen = DateTime.tryParse(lastSeenStr) ?? DateTime(2000);

    return latestDate.isAfter(lastSeen);
  }
}
