import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../exports.dart';
import '../../features/general/chat/screens/message_screen.dart';
import '../../features/driver/home/cubit/cubit.dart';
import '../../features/user/home/cubit/cubit.dart';

/// ===============================================================
/// GLOBAL INITIAL MESSAGE
/// ===============================================================
RemoteMessage? initialMessageReceived;

/// ===============================================================
/// BACKGROUND HANDLER (Top-Level)
/// ===============================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.showTripLocalNotification(message);

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('initial_message', jsonEncode(message.data));
  } catch (e) {
    log('❌ Error saving initial message: $e');
  }
}

/// ===============================================================
/// NOTIFICATION SERVICE (Singleton)
/// ===============================================================
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _initialized = false;
  int _idCounter = 0;

  static const String _channelId = 'waslni_trip_sound_v3';

  /// ===============================================================
  /// INIT
  /// ===============================================================
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _loadInitialMessage();
    await _initLocalNotifications();
    await _initFirebaseMessaging();

    log('✅ NotificationService initialized');
  }

  /// ===============================================================
  /// LOAD INITIAL MESSAGE
  /// ===============================================================
  Future<void> _loadInitialMessage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('initial_message');

      if (stored != null) {
        initialMessageReceived = RemoteMessage(
          data: jsonDecode(stored) as Map<String, dynamic>,
        );
        await prefs.remove('initial_message');
      }
    } catch (e) {
      log('❌ Error loading initial message: $e');
    }
  }

  /// ===============================================================
  /// PUBLIC – GET INITIAL MESSAGE (USED IN app.dart)
  /// ===============================================================
  static Future<RemoteMessage?> getInitialMessage() async {
    if (initialMessageReceived != null) {
      return initialMessageReceived;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('initial_message');

      if (stored != null) {
        final data = jsonDecode(stored) as Map<String, dynamic>;
        return RemoteMessage(data: data);
      }
    } catch (e) {
      log('❌ Error getting initial message: $e');
    }

    return null;
  }

  /// ===============================================================
  /// 🔥 FOREGROUND MESSAGE HANDLER
  /// ===============================================================
  void handleForegroundMessage(RemoteMessage message) {
    final roomId = message.data['reference_id']?.toString();
    if (MessageStateManager().isInChatRoom(roomId)) return;

    // ✅ Show in-app banner
    showFCMInAppBanner(message: message);

    // ✅ Refresh relevant screens
    if (message.data['reference_table'] == 'trips') {
      refreshHomeData();
    }
  }

  /// Refresh home data based on user type
  Future<void> refreshHomeData() async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) return;

      // ✅ حل أبسط - استخدم shared prefs مباشرة
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getInt('user_type') ?? 0;
      final isDriver = userType == 1;

      if (isDriver) {
        context.read<DriverHomeCubit>().getDriverHomeData(context);
      } else {
        context.read<UserHomeCubit>().getHome(context);
      }
    } catch (e) {
      log('❌ Error refreshing home data: $e');
    }
  }

  /// ===============================================================
  /// IN-APP BANNER
  /// ===============================================================
  void showFCMInAppBanner({required RemoteMessage message}) {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'اشعار جديد';
    final body =
        message.notification?.body ?? message.data['body'] ?? 'رسالة جديدة';

    _showInAppBanner(
      title: title,
      body: body,
      onTap: () => _handleNavigation(message.data),
    );
  }

  /// ===============================================================
  /// FIREBASE MESSAGING
  /// ===============================================================
  Future<void> _initFirebaseMessaging() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNavigation(message.data);
    });

    // ✅ Foreground listener هنا (مش في main.dart)
    FirebaseMessaging.onMessage.listen((message) {
      handleForegroundMessage(message);
    });
  }

  /// ===============================================================
  /// LOCAL NOTIFICATIONS INIT
  /// ===============================================================
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleNavigation(jsonDecode(details.payload!));
        }
      },
    );

    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              'Trip Requests',
              description: 'Trip alerts',
              importance: Importance.max,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('ringtone'),
            ),
          );
    }
  }

  /// ===============================================================
  /// BACKGROUND / TRIP NOTIFICATION
  /// ===============================================================
  Future<void> showTripLocalNotification(RemoteMessage message) async {
    final title = message.data['title'] ?? '🚗 رحلة جديدة';
    final body = message.data['body'] ?? 'فيه طلب رحلة جديد';

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _notificationDetails(),
      payload: jsonEncode(message.data),
    );
  }

  /// ===============================================================
  /// LOCAL NOTIFICATION
  /// ===============================================================
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    await _local.show(_idCounter++, title, body, _notificationDetails());
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Trip Requests',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('ringtone'),
      ),
      iOS: DarwinNotificationDetails(presentSound: true),
    );
  }

  /// ===============================================================
  /// IN-APP BANNER WIDGET
  /// ===============================================================
  void _showInAppBanner({
    required String title,
    required String body,
    required VoidCallback onTap,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _TopBannerWidget(
        title: title,
        body: body,
        onTap: () {
          entry.remove();
          onTap();
        },
        onClose: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Timer(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }

  /// ===============================================================
  /// NAVIGATION
  /// ===============================================================
  void _handleNavigation(Map<String, dynamic> data) {
    if (data['reference_table'] == 'chat_rooms') {
      navigatorKey.currentState?.pushNamed(
        Routes.messageRoute,
        arguments: MainUserAndRoomChatModel(
          chatId: data['reference_id'] ?? '',
          driverId: data['driver_id'] ?? '',
          receiverId: data['user_id'] ?? '',
          tripId: data['trip_id'] ?? '',
          isDriver: data['user_type'] == '1',
          isNotification: true,
          title: data['user_name'] ?? '',
        ),
      );
    }
  }
}

/// ===============================================================
/// IN-APP BANNER WIDGET
/// ===============================================================
class _TopBannerWidget extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TopBannerWidget({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.95),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// CHAT ROOM STATE MANAGER
/// ===============================================================
class MessageStateManager {
  static final MessageStateManager _instance = MessageStateManager._internal();

  factory MessageStateManager() {
    return _instance;
  }

  MessageStateManager._internal();

  /// chat rooms المفتوحة حاليًا
  final Set<String> _activeChatRooms = {};

  /// عند الدخول لغرفة شات
  void enterChatRoom(String chatId) {
    _activeChatRooms.add(chatId);
    log('🟢 Entered chat room: $chatId');
  }

  /// عند الخروج من غرفة الشات
  void leaveChatRoom(String chatId) {
    _activeChatRooms.remove(chatId);
    log('🔴 Left chat room: $chatId');
  }

  /// هل المستخدم حاليًا داخل غرفة معينة؟
  bool isInChatRoom(String? chatId) {
    if (chatId == null) return false;
    return _activeChatRooms.contains(chatId);
  }
}
