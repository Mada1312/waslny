import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/core/notification_services/service/fcm_service.dart';
import 'package:waslny/core/notification_services/service/local_notification_service.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart';
import 'package:waslny/features/driver/my_profile/cubit/cubit.dart';
import 'package:waslny/features/driver/trips/cubit/cubit.dart';
import 'package:waslny/features/general/change_password/cubit/change_password_cubit.dart';
import 'package:waslny/features/general/compound_services/cubit/cubit.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/notifications/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/splash/screens/splash_screen.dart';
import 'package:waslny/features/main/cubit/cubit.dart';
import 'package:waslny/features/general/on_boarding/cubit/onboarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_strings.dart';
import 'package:waslny/injector.dart' as injector;
import 'features/user/add_new_trip/cubit/cubit.dart';
import 'features/user/driver_details/cubit/cubit.dart';
import 'features/general/auth/cubit/cubit.dart';
import 'features/general/chat/cubit/chat_cubit.dart';
import 'features/general/splash/cubit/cubit.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Future<void> _initializeNotifications() async {
  //   print("🔄 Start initializing notifications...");

  //   _notificationService = NotificationService();
  //   await _notificationService.initialize();

  //   // ✅ تهيئة Local Notifications للإشعارات في لوحة الإشعارات
  //   try {
  //     await LocalNotificationService.initialize();
  //     print("✅ Local Notifications initialized successfully");
  //   } catch (e) {
  //     print("❌ Error initializing Local Notifications: $e");
  //   }

  //   print("✅ All Notifications initialized");
  // }

  Future<void> _initializeNotifications() async {
    print("🔄 Start initializing notifications...");

    // ✅ هيّا Local Notifications
    try {
      await LocalNotificationService.initialize();
      print("✅ Local Notifications initialized successfully");
    } catch (e) {
      print("❌ Error initializing Local Notifications: $e");
    }

    // ✅ هيّا FCM
    try {
      await FCMService.initializeFCM();
      print("✅ FCM initialized successfully");
    } catch (e) {
      print("❌ Error initializing FCM: $e");
    }

    // ✅ استمع للتغييرات في الـ token
    FCMService.listenToTokenChanges();

    // ✅ هيّا NotificationService (الـ old one - للتوافقية)
    _notificationService = NotificationService();
    await _notificationService.initialize();

    print("✅ All Notifications initialized");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => injector.serviceLocator<SplashCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<OnBoardingCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<LoginCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<MainCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<UserHomeCubit>()),
        BlocProvider(
          create: (_) => injector.serviceLocator<UserTripAndServicesCubit>(),
        ),
        BlocProvider(create: (_) => injector.serviceLocator<DriverHomeCubit>()),
        BlocProvider(
          create: (_) => injector.serviceLocator<DriverTripsCubit>(),
        ),
        BlocProvider(create: (_) => injector.serviceLocator<ProfileCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<AddNewTripCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<LocationCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<ChatCubit>()),
        BlocProvider(
          create: (_) => injector.serviceLocator<NotificationsCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<DriverDetailsCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<ChangePasswordCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<DriverProfileCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<CompoundServicesCubit>(),
        ),
      ],
      child: FutureBuilder<RemoteMessage?>(
        future: NotificationService.getInitialMessage(),
        builder: (context, snapshot) {
          return GetMaterialApp(
            supportedLocales: context.supportedLocales,
            navigatorKey: NotificationService.navigatorKey,
            locale: context.locale,
            theme: appTheme(),
            themeMode: ThemeMode.light,
            darkTheme: ThemeData.light(),
            localizationsDelegates: context.localizationDelegates,
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            routes: {
              '/': (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                final initialMessage = snapshot.data;

                if (initialMessage != null &&
                    initialMessage.data['reference_table'] == "chat_rooms") {
                  final data = initialMessage.data;
                  final isDriver = data['user_type']?.toString() == "1";

                  return MessageScreen(
                    model: MainUserAndRoomChatModel(
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

                return const SplashScreen();
              },
            },
          );
        },
      ),
    );
  }
}
