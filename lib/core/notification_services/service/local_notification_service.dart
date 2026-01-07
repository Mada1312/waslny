import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/app_colors.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(initializationSettings);

    // ✅ طلب صلاحيات Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
  }

  // ✅ إشعار رحلة جديدة
  static Future<void> showNewTripNotification({
    required String tripId,
    required String captainName,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'new_trip_channel',
          'رحلات جديدة',
          channelDescription: 'إشعارات الرحلات الجديدة',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: AppColors.secondPrimary,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      1,
      'لديك رحلة جديدة 🚗',
      'رحلة جديدة',
      notificationDetails,
      payload: 'new_trip_$tripId',
    );
  }

  // ✅ إشعار تعيين كابتن (للعميل)
  static Future<void> showCaptainAssignedNotification({
    required String captainName,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'captain_assigned_channel',
          'تعيين كابتن',
          channelDescription: 'إشعار تعيين الكابتن',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: AppColors.secondPrimary,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      5,
      'تم تعيين كابتن لرحلتك 🚗',
      captainName,
      notificationDetails,
      payload: 'captain_assigned',
    );
  }

  // ✅ إشعار قبول الكابتن للرحلة (للعميل)
  static Future<void> showCaptainAcceptedNotification({
    required String captainName,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'captain_accepted_channel',
          'قبول الكابتن',
          channelDescription: 'إشعار قبول الكابتن للرحلة',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.green,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      6,
      'تم قبول الرحلة من قبل $captainName ✅',
      'الكابتن في الطريق إليك',
      notificationDetails,
      payload: 'captain_accepted',
    );
  }

  // ✅ إشعار وصول الكابتن (للعميل)
  static Future<void> showCaptainArrivedNotification({
    required String captainName,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'captain_arrived_channel',
          'الكابتن وصل',
          channelDescription: 'إشعار وصول الكابتن',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.green,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      7,
      'تم وصول الكابتن ✅',
      'الكابتن وصل للموقع',
      notificationDetails,
      payload: 'captain_arrived',
    );
  }

  // ✅ إشعار بدء الرحلة (للعميل)
  static Future<void> showTripStartedNotification() async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'trip_started_channel',
          'بدء الرحلة',
          channelDescription: 'إشعار بدء الرحلة',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: AppColors.secondPrimary,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      8,
      'تم بدء الرحلة 🚗',
      'الكابتن بدأ الرحلة الآن',
      notificationDetails,
      payload: 'trip_started',
    );
  }

  // ✅ إشعار انهاء الرحلة (للعميل)
  static Future<void> showTripEndedNotification() async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'trip_ended_channel',
          'انهاء الرحلة',
          channelDescription: 'إشعار انهاء الرحلة',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.green,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      9,
      'تم انهاء الرحلة ✅',
      'شكراً لاستخدام وصلنى',
      notificationDetails,
      payload: 'trip_ended',
    );
  }

  // ✅ إشعار كابتن وصل (للكابتن - بدون إشعار للعميل)
  static Future<void> showCaptainArrivedForDriverNotification({
    required String captainName,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'captain_arrived_driver_channel',
          'الكابتن وصل',
          channelDescription: 'إشعار وصول الكابتن',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Colors.green,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      2,
      'تم وصول الكابتن ✅',
      'الكابتن وصل للموقع',
      notificationDetails,
      payload: 'captain_arrived',
    );
  }

  // ✅ إشعار نجاح
  static Future<void> showSuccessNotification(String message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'success_channel',
          'نجحت العملية',
          channelDescription: 'إشعارات النجاح',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: AppColors.secondPrimary,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      3,
      message,
      '',
      notificationDetails,
      payload: 'success',
    );
  }

  // ✅ إشعار خطأ
  static Future<void> showErrorNotification(String message) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'error_channel',
          'خطأ',
          channelDescription: 'إشعارات الأخطاء',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: AppColors.error,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('ringtone'),
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      4,
      message,
      '',
      notificationDetails,
      payload: 'error',
    );
  }
}
