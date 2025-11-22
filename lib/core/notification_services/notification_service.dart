// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:waslny/features/general/chat/screens/message_screen.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../exports.dart';

// RemoteMessage? initialMessageRcieved;

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();

//   factory NotificationService() => _instance;

//   NotificationService._internal();

//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   int _notificationCounter = 0;

//   Future<void> initialize() async {
//     await _initializeFirebaseMessaging();
//     await _initializeLocalNotifications();
//   }

//   /// **Firebase Messaging Initialization**
//   Future<void> _initializeFirebaseMessaging() async {
//     RemoteMessage? initialMessage = await _messaging.getInitialMessage();
//     if (initialMessage != null) {
//       initialMessageRcieved = initialMessage;
//     }

//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       initialMessageRcieved = message;

//       if (message.data['reference_table'] == "chat_rooms") {
//         if (message.data['user_type'].toString() == "0") {
//           // User
//           navigatorKey.currentState?.pushNamed(
//             Routes.messageRoute,
//             arguments: MainUserAndRoomChatModel(
//               chatId: message.data['reference_id'].toString(),
//               driverId: message.data['driver_id'].toString(),
//               receiverId: message.data['driver_id'].toString(),
//               tripId: message.data['trip_id'].toString(),
//               isDriver: false,
//               isNotification: false,
//               title: message.data['user_name'].toString(),
//             ),
//           );
//         } else {
//           // Driver
//           navigatorKey.currentState?.pushNamed(
//             Routes.messageRoute,
//             arguments: MainUserAndRoomChatModel(
//               chatId: message.data['reference_id'].toString(),
//               driverId: message.data['driver_id'].toString(),
//               receiverId: message.data['user_id'].toString(),
//               tripId: message.data['trip_id'].toString(),
//               isDriver: true,
//               isNotification: false,
//               title: message.data['user_name'].toString(),
//             ),
//           );
//         }
//       }
//     });

//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     log('User granted permission: ${settings.authorizationStatus}');

//     FirebaseMessaging.onMessage.listen((message) async {
//       log("Foreground Message Received: ${message.notification?.title}");
//       log("Message Data: ${message.data}");

//       /// Check if the message is from a chat room
//       final roomId = message.data['reference_id']?.toString();

//       if (MessageStateManager().isInChatRoom("0")
//       // &&          message.data['reference_table'] == "chat_rooms"
//       ) {
//         log("Already in chat room $roomId - skipping notification");
//         return;
//       }
//       _showLocalNotification(
//         title: message.notification?.title ?? '',
//         body: message.notification?.body ?? '',
//         payload: jsonEncode(message.data), // message.data.toString(),
//       );
//     });
    
//   }

//   /// **Handles Background Notifications**
//   @pragma('vm:entry-point')
//   static Future<void> _firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     log("Background Message Received: ${message.data}");
//     try {
//       initialMessageRcieved = message;
//     } catch (e) {
//       log("Error starting background location service: $e");
//     }
//   }

  
//   /// **Local Notifications Initialization**
//   Future<void> _initializeLocalNotifications() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestBadgePermission: true,
//           requestSoundPermission: true,
//         );

//     final InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initSettings,

//       ///! [ON CLIECK LOCAL NOTFICATION]
//       onDidReceiveNotificationResponse: (details) {
//         final payload = details.payload;

//         log('Notification payload: $payload userType==>');
//         log('Notification payload: ${details.payload}');
//         try {
//           if (payload != null) {
//             Map<String, dynamic> message = {};
//             message = jsonDecode(payload);

//             initialMessageRcieved = RemoteMessage(data: message);
//             log('Parsed notification payload: $message');
//             if (message['reference_table'] == "chat_rooms") {
//               if (message['user_type'].toString() == "0") {
//                 // User
//                 navigatorKey.currentState?.pushNamed(
//                   Routes.messageRoute,
//                   arguments: MainUserAndRoomChatModel(
//                     chatId: message['reference_id'].toString(),
//                     driverId: message['driver_id'].toString(),
//                     receiverId: message['driver_id'].toString(),
//                     tripId: message['trip_id'].toString(),
//                     isDriver: false,
//                     isNotification: false,
//                     title: message['user_name'].toString(),
//                   ),
//                 );
//               } else {
//                 // Driver
//                 navigatorKey.currentState?.pushNamed(
//                   Routes.messageRoute,
//                   arguments: MainUserAndRoomChatModel(
//                     chatId: message['reference_id'].toString(),
//                     driverId: message['driver_id'].toString(),
//                     receiverId: message['user_id'].toString(),
//                     tripId: message['trip_id'].toString(),
//                     isDriver: true,
//                     isNotification: false,
//                     title: message['user_name'].toString(),
//                   ),
//                 );
//               }
//             }
//           }
//         } catch (e) {
//           log('Error parsing notification payload: $e');
//           // navigatorKey.currentState
//           //     ?.pushNamed(Routes.notificationRoute, );
//         }
//       },
//     );

//     if (Platform.isAndroid) {
//       await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.requestNotificationsPermission();
//     }

//     if (Platform.isIOS) {
//       await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin
//           >()
//           ?.requestPermissions(alert: true, badge: true, sound: true);
//     }
//   }

//   AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
//     'your_channel_id_waslny',
//     'your_channel_name_waslny',
//     channelDescription: 'your_channel_description_waslny',
//     importance: Importance.max,
//     priority: Priority.high,
//     icon: '@mipmap/ic_launcher',
//     ticker: 'ticker',
//   );

//   Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       _notificationCounter++,
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//   }
// }

// class MessageStateManager {
//   static final MessageStateManager _instance = MessageStateManager._internal();
//   factory MessageStateManager() => _instance;
//   MessageStateManager._internal();

//   // Track active chat room IDs
//   final Set<String> _activeChatRoomIds = {};

//   // Methods to update state
//   void enterChatRoom(String roomId) {
//     _activeChatRoomIds.add(roomId);
//     log("Entered chat room: $roomId");
//   }

//   void leaveChatRoom(String roomId) {
//     _activeChatRoomIds.remove(roomId);
//     log("Left chat room: $roomId");
//   }

//   // Check if we're in a specific chat room
//   bool isInChatRoom(String? roomId) {
//     return roomId != null && _activeChatRoomIds.contains(roomId);
//   }
// }
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exports.dart';

RemoteMessage? initialMessageRcieved;

/// **Background Message Handler - MUST be top-level function**
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Background Message Received: ${message.data}");
  
  try {
    // Store the message data in SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('initial_message', jsonEncode(message.data));
    log("Stored background message data");
  } catch (e) {
    log("Error storing background message: $e");
  }
}

@pragma('vm:entry-point')
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _notificationCounter = 0;

  Future<void> initialize() async {
    await _loadInitialMessage();
    await _initializeFirebaseMessaging();
    await _initializeLocalNotifications();
  }

  /// **Load initial message from SharedPreferences**
  Future<void> _loadInitialMessage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedMessage = prefs.getString('initial_message');
      
      if (storedMessage != null) {
        final messageData = jsonDecode(storedMessage) as Map<String, dynamic>;
        initialMessageRcieved = RemoteMessage(data: messageData);
        log("Loaded stored message: $messageData");
        
        // Clear the stored message after loading
        await prefs.remove('initial_message');
      }
    } catch (e) {
      log("Error loading initial message: $e");
    }
  }

  /// **Firebase Messaging Initialization**
  Future<void> _initializeFirebaseMessaging() async {
    // Check for message that opened the app from terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      initialMessageRcieved = initialMessage;
      log("Got initial message: ${initialMessage.data}");
    }

    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("Message opened app: ${message.data}");
      _handleNotificationNavigation(message.data);
    });

    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log('User granted permission: ${settings.authorizationStatus}');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) async {
      log("Foreground Message Received: ${message.notification?.title}");
      log("Message Data: ${message.data}");

      /// Check if the message is from a chat room
      final roomId = message.data['reference_id']?.toString();

      if (MessageStateManager().isInChatRoom("0")) {
      // if (MessageStateManager().isInChatRoom(roomId)) {
        log("Already in chat room $roomId - skipping notification");
        return;
      }
      
      _showLocalNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
      );
    });
  }

  /// **Handle notification navigation**
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (data['reference_table'] == "chat_rooms") {
      final isDriver = data['user_type'].toString() == "1";
      
      navigatorKey.currentState?.pushNamed(
        Routes.messageRoute,
        arguments: MainUserAndRoomChatModel(
          chatId: data['reference_id']?.toString() ?? '',
          driverId: data['driver_id']?.toString() ?? '',
          receiverId: isDriver 
              ? (data['user_id']?.toString() ?? '')
              : (data['driver_id']?.toString() ?? ''),
          tripId: data['trip_id']?.toString() ?? '',
          isDriver: isDriver,
          isNotification: true,
          title: data['user_name']?.toString() ?? '',
        ),
      );
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
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        log('Notification tapped with payload: $payload');
        
        try {
          if (payload != null) {
            Map<String, dynamic> data = jsonDecode(payload);
            log('Parsed notification payload: $data');
            
            // Store for app restart scenario
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('initial_message', payload);
            });
            
            _handleNotificationNavigation(data);
          }
        } catch (e) {
          log('Error parsing notification payload: $e');
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

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      _notificationCounter++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// **Get initial message for routing**
  static Future<RemoteMessage?> getInitialMessage() async {
    if (initialMessageRcieved != null) {
      return initialMessageRcieved;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedMessage = prefs.getString('initial_message');
      
      if (storedMessage != null) {
        final messageData = jsonDecode(storedMessage) as Map<String, dynamic>;
        return RemoteMessage(data: messageData);
      }
    } catch (e) {
      log("Error getting initial message: $e");
    }
    
    return null;
  }
}

class MessageStateManager {
  static final MessageStateManager _instance = MessageStateManager._internal();
  factory MessageStateManager() => _instance;
  MessageStateManager._internal();

  final Set<String> _activeChatRoomIds = {};

  void enterChatRoom(String roomId) {
    _activeChatRoomIds.add(roomId);
    log("Entered chat room: $roomId");
  }

  void leaveChatRoom(String roomId) {
    _activeChatRoomIds.remove(roomId);
    log("Left chat room: $roomId");
  }

  bool isInChatRoom(String? roomId) {
    return roomId != null && _activeChatRoomIds.contains(roomId);
  }
}