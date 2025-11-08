import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart';
import 'package:waslny/features/driver/my_profile/cubit/cubit.dart';
import 'package:waslny/features/driver/trips/cubit/cubit.dart';
import 'package:waslny/features/general/change_password/cubit/change_password_cubit.dart';
import 'package:waslny/features/general/compound_services/cubit/cubit.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/general/chat/screens/message_screen.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/notifications/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/splash/screens/splash_screen.dart';
import 'package:waslny/features/main/cubit/cubit.dart';
import 'package:waslny/features/general/on_boarding/cubit/onboarding_cubit.dart';
import 'package:waslny/features/main/screens/main_screen.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NotificationService notificationService = NotificationService();
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

        // BlocProvider(create: (_) => injector.serviceLocator<ChatCubit>()),
        // BlocProvider(
        //   create: (_) => injector.serviceLocator<NotificationsCubit>(),
        // ),
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
      child: GetMaterialApp(
        supportedLocales: context.supportedLocales,
        navigatorKey: notificationService.navigatorKey,
        locale: context.locale,
        theme: appTheme(),
        themeMode: ThemeMode.light,
        darkTheme: ThemeData.light(),
        // standard dark theme
        localizationsDelegates: context.localizationDelegates,
        debugShowCheckedModeBanner: false,
        title: AppStrings.appName,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        routes: {
          '/': (context) => initialMessageRcieved != null
              ? initialMessageRcieved?.data['reference_table'] == "shipments"
                    ?
                      //  initialMessageRcieved?.data['user_type'].toString() == "0"
                      //       ? UserShipmentDetailsScreen(
                      //           args: UserShipmentDetailsArgs(
                      //             shipmentId:
                      //                 initialMessageRcieved?.data['reference_id']
                      //                     .toString() ??
                      //                 "",
                      //             isFromNotification: true,
                      //           ),
                      //         )
                      //       :
                      // is driver
                      // initialMessageRcieved?.data['is_current'].toString() ==
                      //         "1"
                      //     ?
                      MainScreen(isDriver: true)
                    // :
                    //  DriverShipmentDetailsScreen(
                    //     args: DriverSHipmentsArgs(
                    //       shipmentId:
                    //           initialMessageRcieved?.data['reference_id']
                    //               .toString() ??
                    //           "",
                    //       isNotification: true,
                    //     ),
                    //   )
                    : (initialMessageRcieved?.data['reference_table'] ==
                          "chat_rooms")
                    ? MessageScreen(
                        model: MainUserAndRoomChatModel(
                          chatId: initialMessageRcieved?.data['reference_id']
                              .toString(),
                          driverId: initialMessageRcieved?.data['user_id']
                              .toString(),
                          isDriver: ['user_type'].toString() == "1",
                          isNotification: true,
                          title: initialMessageRcieved?.data['user_name']
                              .toString(),
                        ),
                      )
                    : const SplashScreen()
              : const SplashScreen(),
        },
      ),
    );
  }
}
