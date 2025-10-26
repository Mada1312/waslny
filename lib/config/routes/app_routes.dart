import 'package:waslny/features/driver/home/screens/driver_data_screen.dart';
import 'package:waslny/features/driver/trips/screens/trips_screen.dart';
import 'package:waslny/features/general/change_password/screen/change_password.dart';
import 'package:waslny/features/general/not_verified_user.dart';
import 'package:waslny/features/user/home/screens/all_trips_and_services.dart';
import 'package:waslny/features/user/trip_and_services/screens/details/shipment_details_screen.dart';
import 'package:waslny/features/user/trip_and_services/screens/trips_and_services.dart';
import 'package:waslny/features/main/screens/main_screen.dart';
import 'package:waslny/features/general/auth/screens/choose_login_screen.dart';
import 'package:waslny/features/general/on_boarding/screen/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:waslny/features/general/splash/screens/splash_screen.dart';
import '../../core/utils/app_strings.dart';
import 'package:page_transition/page_transition.dart';
import '../../features/user/add_new_trip/screens/add_new_trip.dart';
import '../../features/general/auth/screens/forget_password.dart';
import '../../features/general/auth/screens/login_screen.dart';
import '../../features/general/auth/screens/new_password.dart';
import '../../features/general/auth/screens/register_screen.dart';
import '../../features/general/auth/screens/update_delivery_profile.dart';
import '../../features/general/auth/screens/update_exporter_profile.dart';
import '../../features/general/auth/screens/verify_code.dart';
import '../../features/general/chat/screens/message_screen.dart';
import '../../features/general/profile/screens/contactus_screen.dart';

class Routes {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String signUpRoute = '/SignUpScreen';
  static const String chooseLoginRoute = '/chooseLogin';
  static const String mainRoute = '/main';
  static const String forgetPasswordScreen = '/ForgetPasswordScreen';
  static const String verifyCodeScreen = '/VerifyCodeScreen';
  static const String newPasswordScreen = '/newPasswordScreen';
  static const String onboardingRoute = '/onBoarding';
  static const String userTripsAndServicesRoute = '/userTripsAndServicesRoute';
  static const String userShipmentDetailsRoute = '/userShipmentDetailsRoute';
  static const String driverShipmentDetailsRoute = '/driverShipmentDetails';
  static const String addNewTripRoute = '/addNewTrip';
  static const String updateShipmentRoute = '/updateShipment';
  static const String tutorialVideoScreenRoute = '/TutorialVideoScreen';
  static const String contactUsScreen = '/contactUsScreen';
  static const String editDeliveryProfileRoute = '/editProfileRoute';
  static const String editUserProfileRoute = '/editUserProfileRoute';
  static const String messageRoute = '/messageRoute';
  static const String driverDataRoute = '/driverDataRoute';
  static const String driverTripsRoute = '/driverTripsRoute';
  static const String changePasswordScreen = '/ChangePasswordScreen';
  static const String allTripsScreenRoute = '/allTripsScreenRoute';
    static const String notVerifiedUserRoute = '/notVerifiedUserRoute';

}

class AppRoutes {
  static String route = '';

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initialRoute:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

 case Routes.notVerifiedUserRoute:
        bool isDriver = settings.arguments as bool;
        return PageTransition(
          child: NotVerifiedUserScreen(isDriver: isDriver),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.loginRoute:
        bool isDriver = settings.arguments as bool;
        return PageTransition(
          child: LoginScreen(isDriver: isDriver),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.signUpRoute:
        bool isDriver = settings.arguments as bool;
        return PageTransition(
          child: SignUpScreen(isDriver: isDriver),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );

      case Routes.chooseLoginRoute:
        return PageTransition(
          child: const ChooseLoginScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );

      case Routes.mainRoute:
        bool isDriver = settings.arguments as bool;
        return PageTransition(
          child: MainScreen(isDriver: isDriver),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.forgetPasswordScreen:
        bool isDriver = settings.arguments as bool;
        return PageTransition(
          child: ForgetPasswordScreen(isDriver: isDriver),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.verifyCodeScreen:
        List<dynamic> data = settings.arguments as List<dynamic>;
        return PageTransition(
          child: VerifyCodeScreen(isDriver: data[0], isForgetPassword: data[1]),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.newPasswordScreen:
        bool isDriver = settings.arguments as bool;
        return PageTransition(
          child: NewPasswordScreen(isDriver: isDriver),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.onboardingRoute:
        return PageTransition(
          child: const OnBoardinScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.userTripsAndServicesRoute:
        return PageTransition(
          child: const UserTripsAndServicesScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      // case Routes.userShipmentDetailsRoute:
      //   UserShipmentDetailsArgs args =
      //       settings.arguments as UserShipmentDetailsArgs;
      //   return PageTransition(
      //     child: UserShipmentDetailsScreen(args: args),
      //     type: PageTransitionType.fade,
      //     alignment: Alignment.center,
      //     duration: const Duration(milliseconds: 800),
      //   );
      // case Routes.driverShipmentDetailsRoute:
      //   DriverSHipmentsArgs args = settings.arguments as DriverSHipmentsArgs;
      //   return PageTransition(
      //     child: DriverShipmentDetailsScreen(args: args),
      //     type: PageTransitionType.fade,
      //     alignment: Alignment.center,
      //     duration: const Duration(milliseconds: 800),
      //   );

      case Routes.addNewTripRoute:
        AddTripArgs args = settings.arguments as AddTripArgs;
        return PageTransition(
          child: AddNewTripScreen(args: args),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );

      case Routes.contactUsScreen:
        return PageTransition(
          child: const ContactUsScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.editDeliveryProfileRoute:
        return PageTransition(
          child: const UpdateDeliveryProfile(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.editUserProfileRoute:
        return PageTransition(
          child: const UpdateUserProfile(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.messageRoute:
        MainUserAndRoomChatModel model =
            settings.arguments as MainUserAndRoomChatModel;
        return PageTransition(
          child: MessageScreen(model: model),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.driverDataRoute:
        return PageTransition(
          child: DriverDataScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.driverTripsRoute:
        return PageTransition(
          child: DriverTripsScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.changePasswordScreen:
        return PageTransition(
          child: ChangePasswordScreen(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );
      case Routes.allTripsScreenRoute:
        return PageTransition(
          child: AllTripsScreenRoute(),
          type: PageTransitionType.fade,
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 800),
        );

      default:
        return undefinedRoute(routeName: settings.name);
    }
  }

  static Route<dynamic> undefinedRoute({String? routeName}) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text(routeName ?? AppStrings.noRouteFound)),
      ),
    );
  }
}
