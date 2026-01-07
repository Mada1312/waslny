import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:waslny/core/notification_services/service/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ✅ تهيئة FCM
  static Future<void> initializeFCM() async {
    log('🚀 بدء تهيئة FCM...');

    try {
      // طلب إذن الإشعارات من المستخدم
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true, // إشعارات منبثقة
        badge: true, // رقم على أيقونة الـ app
        sound: true, // صوت
        announcement: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      log('✅ إذن الإشعارات: ${settings.authorizationStatus}');

      // احصل على الـ FCM token (هتحتاجه في Backend)
      String? token = await _messaging.getToken();
      log('🔑 FCM Token: $token');

      // احفظ الـ token في الـ SharedPreferences (لاستخدامه في الـ API)
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        log('✅ تم حفظ FCM Token');
      }

      // ✅ استقبال الإشعارات لما الـ app **مفتوح**
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('📬 وصل إشعار والـ app مفتوح!');
        log('العنوان: ${message.notification?.title}');
        log('المحتوى: ${message.notification?.body}');
        log('البيانات: ${message.data}');

        // اعرض الإشعار محلياً
        _handleIncomingMessage(message);
      });

      // ✅ معالجة ضغط المستخدم على الإشعار
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('👆 المستخدم ضغط على الإشعار!');
        log('البيانات: ${message.data}');
        _handleNotificationTap(message);
      });

      // ✅ التحقق من الرسالة الأولية (عند فتح التطبيق من إشعار)
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        log('📱 تم فتح الـ app من إشعار');
        _handleNotificationTap(initialMessage);
      }

      log('✅ FCM تم تهيئته بنجاح');
    } catch (e) {
      log('❌ خطأ في تهيئة FCM: $e');
    }
  }

  // معالجة الإشعار لما الـ app مفتوح
  static void _handleIncomingMessage(RemoteMessage message) {
    final data = message.data;
    final title = message.notification?.title ?? 'إشعار جديد';
    final body = message.notification?.body ?? '';
    final type = data['type'] ?? '';

    log('🔍 نوع الإشعار: $type');

    // تحديد نوع الإشعار وتنفيذ الإجراء المناسب
    switch (type) {
      case 'new_trip':
        LocalNotificationService.showNewTripNotification(
          tripId: data['trip_id'] ?? '',
          captainName: data['captain_name'] ?? 'لديك رحلة جديدة',
        );
        break;

      case 'captain_arrived':
        LocalNotificationService.showCaptainArrivedNotification(
          captainName: data['captain_name'] ?? 'الكابتن',
        );
        break;

      case 'captain_assigned':
        LocalNotificationService.showCaptainAssignedNotification(
          captainName: data['captain_name'] ?? 'الكابتن',
        );
        break;

      case 'captain_accepted':
        LocalNotificationService.showCaptainAcceptedNotification(
          captainName: data['captain_name'] ?? 'الكابتن',
        );
        break;

      case 'trip_started':
        LocalNotificationService.showTripStartedNotification();
        break;

      case 'trip_ended':
        LocalNotificationService.showTripEndedNotification();
        break;

      case 'success':
        LocalNotificationService.showSuccessNotification(body);
        break;

      case 'error':
        LocalNotificationService.showErrorNotification(body);
        break;

      case 'chat':
        LocalNotificationService.showSuccessNotification('رسالة جديدة: $body');
        break;

      default:
        // إشعار عام
        LocalNotificationService.showSuccessNotification(title);
        break;
    }
  }

  // معالجة الإشعار لما الـ app مفتوح (من notification_service)
  static void handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final title = message.notification?.title ?? 'إشعار جديد';
    final body = message.notification?.body ?? '';
    final type = data['type'] ?? '';

    log('🔔 Foreground Message: $type - $title');

    // تحديد نوع الإشعار وتنفيذ الإجراء المناسب
    switch (type) {
      case 'new_trip':
        LocalNotificationService.showNewTripNotification(
          tripId: data['trip_id'] ?? '',
          captainName: data['captain_name'] ?? 'لديك رحلة جديدة',
        );
        break;

      case 'captain_arrived':
        LocalNotificationService.showCaptainArrivedNotification(
          captainName: data['captain_name'] ?? 'الكابتن',
        );
        break;

      case 'captain_assigned':
        LocalNotificationService.showCaptainAssignedNotification(
          captainName: data['captain_name'] ?? 'الكابتن',
        );
        break;

      case 'captain_accepted':
        LocalNotificationService.showCaptainAcceptedNotification(
          captainName: data['captain_name'] ?? 'الكابتن',
        );
        break;

      case 'trip_started':
        LocalNotificationService.showTripStartedNotification();
        break;

      case 'trip_ended':
        LocalNotificationService.showTripEndedNotification();
        break;

      case 'success':
        LocalNotificationService.showSuccessNotification(body);
        break;

      case 'error':
        LocalNotificationService.showErrorNotification(body);
        break;

      case 'chat':
        LocalNotificationService.showSuccessNotification('رسالة جديدة: $body');
        break;

      default:
        LocalNotificationService.showSuccessNotification(title);
        break;
    }
  }

  // معالجة الإشعار لما الـ app مغلق (Background)
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    log('⏱️ إشعار في الخلفية/مغلق: ${message.notification?.title}');
    log('البيانات: ${message.data}');

    try {
      // احفظ الإشعار في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('background_message', jsonEncode(message.data));

      final data = message.data;
      final title = message.notification?.title ?? 'إشعار جديد';
      final body = message.notification?.body ?? '';
      final type = data['type'] ?? '';

      // تحديد نوع الإشعار وتنفيذ الإجراء المناسب
      switch (type) {
        case 'new_trip':
          await LocalNotificationService.showNewTripNotification(
            tripId: data['trip_id'] ?? '',
            captainName: data['captain_name'] ?? 'لديك رحلة جديدة',
          );
          break;

        case 'captain_arrived':
          await LocalNotificationService.showCaptainArrivedNotification(
            captainName: data['captain_name'] ?? 'الكابتن',
          );
          break;

        case 'captain_assigned':
          await LocalNotificationService.showCaptainAssignedNotification(
            captainName: data['captain_name'] ?? 'الكابتن',
          );
          break;

        case 'captain_accepted':
          await LocalNotificationService.showCaptainAcceptedNotification(
            captainName: data['captain_name'] ?? 'الكابتن',
          );
          break;

        case 'trip_started':
          await LocalNotificationService.showTripStartedNotification();
          break;

        case 'trip_ended':
          await LocalNotificationService.showTripEndedNotification();
          break;

        case 'success':
          await LocalNotificationService.showSuccessNotification(body);
          break;

        case 'error':
          await LocalNotificationService.showErrorNotification(body);
          break;

        default:
          await LocalNotificationService.showSuccessNotification(title);
          break;
      }

      log('✅ تم معالجة الإشعار في الخلفية');
    } catch (e) {
      log('❌ خطأ في معالجة الإشعار بالخلفية: $e');
    }
  }

  // معالجة ضغط المستخدم على الإشعار
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    log('📍 معالجة الإشعار عند الضغط: $data');

    // حسب نوع الإشعار → اعمل الحاجة المناسبة
    final type = data['type'] ?? '';
    final referenceTable = data['reference_table'] ?? '';

    if (referenceTable == 'chat_rooms') {
      log('💬 فتح شاشة الدردشة');
      // هنا تنقل للـ chat screen (هيتم في NavigationService)
    } else if (type == 'new_trip') {
      final tripId = data['trip_id'];
      log('🚗 فتح الرحلة: $tripId');
      // هنا تنقل لـ trip details screen
    } else if (type == 'captain_arrived') {
      log('📍 الكابتن وصل - أفتح الـ tracking');
      // هنا تنقل لـ tracking screen
    }
  }

  // احصل على FCM Token (للاستخدام في الـ API)
  static Future<String?> getFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      log('❌ خطأ في الحصول على FCM Token: $e');
      return null;
    }
  }

  // احصل على FCM Token من SharedPreferences (للاستخدام السريع)
  static Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      log('❌ خطأ في الحصول على FCM Token المحفوظ: $e');
      return null;
    }
  }

  // احفظ الـ FCM Token في الـ server (عند تسجيل الدخول)
  static Future<void> saveFCMTokenToServer({
    required String userId,
    required String userType, // 'driver' أو 'customer'
  }) async {
    try {
      String? token = await getFCMToken();
      if (token != null) {
        log('💾 حفظ FCM Token للـ server: $token');
        // هنا تستدعي API لحفظ الـ token
        // await api.saveFCMToken(userId: userId, userType: userType, token: token);
      }
    } catch (e) {
      log('❌ خطأ في حفظ FCM Token: $e');
    }
  }

  // استمع للتغييرات في الـ token (في حالة تجديده)
  static void listenToTokenChanges() {
    _messaging.onTokenRefresh.listen((newToken) {
      log('🔄 تم تحديث FCM Token: $newToken');
      // احفظ الـ token الجديد في الـ server والـ SharedPreferences
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('fcm_token', newToken);
        log('✅ تم حفظ الـ Token الجديد');
      });
      // saveFCMTokenToServer(...);
    });
  }

  // تعطيل الإشعارات (عند تسجيل الخروج)
  static Future<void> disableNotifications() async {
    try {
      await _messaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      log('🔴 تم تعطيل الإشعارات');
    } catch (e) {
      log('❌ خطأ في تعطيل الإشعارات: $e');
    }
  }

  // تفعيل الإشعارات (اختياري)
  static Future<void> enableNotifications() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        log('🟢 تم تفعيل الإشعارات: $token');
      }
    } catch (e) {
      log('❌ خطأ في تفعيل الإشعارات: $e');
    }
  }

  // اطلب الإذن (iOS بشكل خاص)
  static Future<NotificationSettings> requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      log('✅ تم طلب الإذن: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      log('❌ خطأ في طلب الإذن: $e');
      rethrow;
    }
  }
}
