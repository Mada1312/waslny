import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/core/utils/app_globals.dart';
import 'package:waslny/core/utils/app_strings.dart';
import 'package:waslny/features/general/splash/screens/splash_screen.dart';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'package:waslny/injector.dart' as injector;
// Cubits
import 'features/general/splash/cubit/cubit.dart';
import 'features/general/on_boarding/cubit/onboarding_cubit.dart';
import 'features/general/auth/cubit/cubit.dart';
import 'features/main/cubit/cubit.dart';
import 'features/user/home/cubit/cubit.dart';
import 'features/user/trip_and_services/cubit/cubit.dart';
import 'features/user/add_new_trip/cubit/cubit.dart';
import 'features/user/driver_details/cubit/cubit.dart';
import 'features/driver/home/cubit/cubit.dart';
import 'features/driver/trips/cubit/cubit.dart';
import 'features/driver/my_profile/cubit/cubit.dart';
import 'features/general/profile/cubit/cubit.dart';
import 'features/general/location/cubit/location_cubit.dart';
import 'features/general/chat/cubit/chat_cubit.dart';
import 'features/general/notifications/cubit/cubit.dart';
import 'features/general/change_password/cubit/change_password_cubit.dart';
import 'features/general/compound_services/cubit/cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService.instance;

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
        BlocProvider(create: (_) => injector.serviceLocator<AddNewTripCubit>()),
        BlocProvider(
          create: (_) => injector.serviceLocator<DriverDetailsCubit>(),
        ),
        BlocProvider(create: (_) => injector.serviceLocator<DriverHomeCubit>()),
        BlocProvider(
          create: (_) => injector.serviceLocator<DriverTripsCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<DriverProfileCubit>(),
        ),
        BlocProvider(create: (_) => injector.serviceLocator<ProfileCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<LocationCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<ChatCubit>()),
        BlocProvider(
          create: (_) => injector.serviceLocator<NotificationsCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<ChangePasswordCubit>(),
        ),
        BlocProvider(
          create: (_) => injector.serviceLocator<CompoundServicesCubit>(),
        ),
      ],
      child: FutureBuilder<RemoteMessage?>(
        future: NotificationService.getInitialMessage(),
        builder: (context, snapshot) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,

            // 🔑 Keys
            navigatorKey: notificationService.navigatorKey,
            scaffoldMessengerKey: rootMessengerKey,

            // 🌍 Localization
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            localizationsDelegates: context.localizationDelegates,

            // 🎨 Theme
            theme: appTheme(),
            themeMode: ThemeMode.light,
            darkTheme: ThemeData.light(),

            // 🧭 Routing
            onGenerateRoute: AppRoutes.onGenerateRoute,

            builder: (context, child) {
              return Scaffold(body: child);
            },

            routes: {
              '/': (context) {
                // ⏳ Loading initial message
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                final initialMessage = snapshot.data;

                // 📩 Open from notification → Chat
                if (initialMessage != null &&
                    initialMessage.data['reference_table'] == 'chat_rooms') {
                  final data = initialMessage.data;
                  final isDriver = data['user_type']?.toString() == '1';

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

                // 🚀 Default
                return const SplashScreen();
              },
            },
          );
        },
      ),
    );
  }
}
