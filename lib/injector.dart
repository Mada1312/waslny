import 'package:waslny/features/driver/home/cubit/cubit.dart';
import 'package:waslny/features/driver/home/data/repo.dart';
import 'package:waslny/features/driver/shipments/cubit/cubit.dart';
import 'package:waslny/features/driver/shipments/screens/data/repo.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/home/data/repo.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/data/repo.dart';
import 'package:waslny/features/general/chat/data/repos/chat_repo.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/location/data/repo.dart';
import 'package:waslny/features/general/notifications/cubit/cubit.dart';
import 'package:waslny/features/general/notifications/data/repo.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/profile/data/repo.dart';

import 'package:waslny/features/main/cubit/cubit.dart';
import 'package:waslny/features/main/data/main_repo.dart';
import 'package:waslny/features/general/on_boarding/cubit/onboarding_cubit.dart';
import 'package:dio/dio.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';
import 'package:waslny/features/general/auth/data/login_repo.dart';
import 'package:waslny/features/general/splash/cubit/cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/base_api_consumer.dart';
import 'core/api/dio_consumer.dart';
import 'features/user/add_new_trip/cubit/cubit.dart';
import 'features/user/add_new_trip/data/repo.dart';
import 'features/user/driver_details/cubit/cubit.dart';
import 'features/user/driver_details/data/repo.dart';
import 'features/general/chat/cubit/chat_cubit.dart';

final serviceLocator = GetIt.instance;
Future<void> setupCubit() async {
  serviceLocator.registerFactory(() => SplashCubit());
  serviceLocator.registerFactory(() => OnBoardingCubit());
  serviceLocator.registerFactory(() => LoginCubit(serviceLocator()));
  serviceLocator.registerFactory(() => MainCubit(serviceLocator()));
  serviceLocator.registerFactory(() => UserHomeCubit(serviceLocator()));
  serviceLocator.registerFactory(
    () => UserTripAndServicesCubit(serviceLocator()),
  );
  serviceLocator.registerFactory(() => DriverHomeCubit(serviceLocator()));
  serviceLocator.registerFactory(() => DriverShipmentsCubit(serviceLocator()));
  serviceLocator.registerFactory(() => ProfileCubit(serviceLocator()));
  serviceLocator.registerFactory(() => AddNewTripCubit(serviceLocator()));
  serviceLocator.registerFactory(() => LocationCubit(serviceLocator()));

  serviceLocator.registerFactory(() => ChatCubit(serviceLocator()));
  serviceLocator.registerFactory(() => NotificationsCubit(serviceLocator()));
  serviceLocator.registerFactory(() => DriverDetailsCubit(serviceLocator()));
}

Future<void> setupRepo() async {
  serviceLocator.registerLazySingleton(() => LoginRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(() => MainRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UserHomeRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => UserShipmentsRepo(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => DriverHomeRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => DriverShipmentsRepo(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => ProfileRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(() => AddNewTripRepo(serviceLocator()));

  serviceLocator.registerLazySingleton(() => ChatRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => NotificationsRepo(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => LocationRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => DriverDetailsRepo(serviceLocator()),
  );
}

Future<void> setupDependencyInjection() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  ///! (dio)
  serviceLocator.registerLazySingleton<BaseApiConsumer>(
    () => DioConsumer(client: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => AppInterceptors());

  // Dio
  serviceLocator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        contentType: "application/x-www-form-urlencoded",
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    ),
  );
}
