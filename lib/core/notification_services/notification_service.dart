import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:waslny/features/driver/background_services.dart';
import 'package:waslny/features/driver/shipments/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/user/shipments/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../exports.dart';
import '../preferences/preferences.dart';

// String notificationId = "0";
// String notificationType = "";
RemoteMessage? initialMessageRcieved;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  /// Global Key for Navigation
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Firebase Messaging Instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Local Notifications Plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _notificationCounter = 0;

  /// **Initialize Notifications**
  Future<void> initialize() async {
    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
  }

  /// **Firebase Messaging Initialization**
  Future<void> _initializeFirebaseMessaging() async {
    // Handle when app is completely closed and opened via notification
    //! [Kill]
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      initialMessageRcieved = initialMessage;

      //! open
    }

    // Handle notification click when app is in
    //! [ background ]
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Handle notification click when app is in forground
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      initialMessageRcieved = message;

      if (message.data['reference_table'] == "shipments") {
        if (message.data['user_type'].toString() == "0") {
          // User
          navigatorKey.currentState?.pushNamed(Routes.userShipmentDetailsRoute,
              arguments: UserShipmentDetailsArgs(
                shipmentId: message.data['reference_id'].toString(),
              ));
        } else {
          // Driver

          if (message.data['is_current'].toString() == "1") {
            navigatorKey.currentState
                ?.pushNamed(Routes.mainRoute, arguments: true);
          } else {
            navigatorKey.currentState
                ?.pushNamed(Routes.driverShipmentDetailsRoute,
                    arguments: DriverSHipmentsArgs(
                      shipmentId: message.data['reference_id'].toString(),
                    ));
          }
        }
      } else if (message.data['reference_table'] == "chat_rooms") {
        if (message.data['user_type'].toString() == "0") {
          // User
          navigatorKey.currentState?.pushNamed(
            Routes.messageRoute,
            arguments: MainUserAndRoomChatModel(
              chatId: message.data['reference_id'].toString(),
              driverId: message.data['user_id'].toString(),
              isDriver: false,
              isNotification: false,
              title: message.data['user_name'].toString(),
            ),
          );
        } else {
          // Driver
          navigatorKey.currentState?.pushNamed(
            Routes.messageRoute,
            arguments: MainUserAndRoomChatModel(
              chatId: message.data['reference_id'].toString(),
              driverId: message.data['user_id'].toString(),
              isDriver: true,
              isNotification: false,
              title: message.data['user_name'].toString(),
            ),
          );
        }
      }
      // if (message.data['reference_table'] == "edit_profile") {
      //   if (message.data['user_type'].toString() == "1")  {
      //     // Driver
      //     navigatorKey.currentState
      //         ?.pushNamed();
      //   }
      // }
      // if (message.data['reference_table'] == "chat_rooms") {
      //   final roomId = message.data['modal_id']?.toString();
      //   if (roomId != null) {
      //     MessageStateManager().enterChatRoom(roomId);
      //     navigatorKey.currentState?.push(MaterialPageRoute(
      //         builder: (context) => MessageScreen(
      //               model: MainUserAndRoomChatModel(
      //                 driverId: driverId,
      //                 shipmentId: shipmentId,
      //                 chatId: roomToken,
      //                 title: "#${shipmentCode ?? ''}-$name",
      //               ),
      //             )));
      //   }
      // }
    });

    // Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

//! [Forground ]
    FirebaseMessaging.onMessage.listen((message) async {
      print("Foreground Message Received: ${message.notification?.title}");
      print("Message Data: ${message.data}");

      /// Check if the message is from a chat room
      final roomId = message.data['reference_id']?.toString();

      if (MessageStateManager().isInChatRoom("0") &&
          message.data['reference_table'] == "chat_rooms") {
        log("Already in chat room $roomId - skipping notification");
        return;
      }
      _showLocalNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data), // message.data.toString(),
      );
      if (message.data['reference_table'] == "shipments" &&
          message.data['user_type'].toString() == "1" &&
          message.data['is_loaded'].toString() == "1") {
        try {
          bool isPermissionGranted = await _checkPermissions();
          if (isPermissionGranted) {
            // await BackgroundLocationService.startService();
          } else {
            // Optionally log or handle the denied state
            log("Location permission not granted; cannot start background service.");
          }
        } catch (e) {
          log("Error starting background location service: $e");
        }
      } else if (message.data['reference_table'] == "shipments" &&
          message.data['user_type'].toString() == "1" &&
          message.data['is_delivered'].toString() == "1") {
        try {
          // await BackgroundLocationService.stopService();
        } catch (e) {
          log("Error starting background location service: $e");
        }
      }
    });
    await _getToken();
  }

  /// **Handles Background Notifications**
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    initialMessageRcieved = message;
    if (message.data['reference_table'] == "shipments" &&
        message.data['user_type'].toString() == "1" &&
        message.data['is_loaded'].toString() == "1") {
      try {
        bool isPermissionGranted = await _checkPermissions();
        if (isPermissionGranted) {
          // await BackgroundLocationService.startService();
        } else {
          // Optionally log or handle the denied state
          log("Location permission not granted; cannot start background service.");
        }
      } catch (e) {
        log("Error starting background location service: $e");
      }
    } else if (message.data['reference_table'] == "shipments" &&
        message.data['user_type'].toString() == "1" &&
        message.data['is_delivered'].toString() == "1") {
      try {
        // await BackgroundLocationService.stopService();
      } catch (e) {
        log("Error starting background location service: $e");
      }
    }
    print("Background Message Received: ${message.notification?.title}");
  }

  /// **Fetches and Stores FCM Token**

  Future<String?> _getToken() async {
    try {
      Preferences.instance.init();
      // Request permission (if needed)
      await _messaging.requestPermission();
      // Get the device token
      String? deviceToken = await _messaging.getToken();
      log("token ====>> $deviceToken");
      // Save the token to preferences
      await Preferences.instance.setDeviceToken(deviceToken ?? '');
      return deviceToken;
    } catch (e) {
      log("Error getting token: $e");
      return null;
    }
  }

  /// **Local Notifications Initialization**
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,

      ///! [ON CLIECK LOCAL NOTFICATION]
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;

        log('Notification payload: $payload userType==>');
        log('Notification payload: ${details.payload}');
        try {
          if (payload != null) {
            Map<String, dynamic> message = {};
            message = jsonDecode(payload);

            initialMessageRcieved = RemoteMessage(data: message);
            log('Parsed notification payload: $message');

            if (message['reference_table'] == "shipments") {
              if (message['user_type'].toString() == "0") {
                // User
                navigatorKey.currentState
                    ?.pushNamed(Routes.userShipmentDetailsRoute,
                        arguments: UserShipmentDetailsArgs(
                          shipmentId: message['reference_id'].toString(),
                        ));
              } else {
                // Driver
                if (message['is_current'].toString() == "1") {
                  navigatorKey.currentState
                      ?.pushNamed(Routes.mainRoute, arguments: true);
                } else {
                  navigatorKey.currentState
                      ?.pushNamed(Routes.driverShipmentDetailsRoute,
                          arguments: DriverSHipmentsArgs(
                            shipmentId: message['reference_id'].toString(),
                          ));
                }
              }
            } else if (message['reference_table'] == "chat_rooms") {
              if (message['user_type'].toString() == "0") {
                // User
                navigatorKey.currentState?.pushNamed(
                  Routes.messageRoute,
                  arguments: MainUserAndRoomChatModel(
                    chatId: message['reference_id'].toString(),
                    driverId: message['user_id'].toString(),
                    isDriver: false,
                    isNotification: false,
                    title: message['user_name'].toString(),
                  ),
                );
              } else {
                // Driver
                navigatorKey.currentState?.pushNamed(
                  Routes.messageRoute,
                  arguments: MainUserAndRoomChatModel(
                    chatId: message['reference_id'].toString(),
                    driverId: message['user_id'].toString(),
                    isDriver: true,
                    isNotification: false,
                    title: message['user_name'].toString(),
                  ),
                );
              }
            }
          }
        } catch (e) {
          log('Error parsing notification payload: $e');
          // navigatorKey.currentState
          //     ?.pushNamed(Routes.notificationRoute, );
        }
      },
    );

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
    'your_channel_id_waslny',
    'your_channel_name_waslny',
    channelDescription: 'your_channel_description_waslny',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    ticker: 'ticker',
  );

  /// **Shows a Local Notification**
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
        _notificationCounter++, title, body, notificationDetails,
        payload: payload);
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('Notification with ID $id canceled');
  }

  static Future<bool> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final locationAlwaysStatus = await Permission.locationAlways.status;
    // Optionally check notification permission if needed

    if (locationStatus.isDenied || locationAlwaysStatus.isDenied) {
      return false;
    }
    return true;
  }
}

class MessageStateManager {
  static final MessageStateManager _instance = MessageStateManager._internal();
  factory MessageStateManager() => _instance;
  MessageStateManager._internal();

  // Track active chat room IDs
  final Set<String> _activeChatRoomIds = {};

  // Methods to update state
  void enterChatRoom(String roomId) {
    _activeChatRoomIds.add(roomId);
    log("Entered chat room: $roomId");
  }

  void leaveChatRoom(String roomId) {
    _activeChatRoomIds.remove(roomId);
    log("Left chat room: $roomId");
  }

  // Check if we're in a specific chat room
  bool isInChatRoom(String? roomId) {
    return roomId != null && _activeChatRoomIds.contains(roomId);
  }
}
