import 'package:waslny/app_bloc_observer.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/notification_services/notification_service.dart';
import 'package:waslny/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waslny/injector.dart' as injector;
import '../preferences/preferences.dart';

Future<void> initializationClass() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService notificationService = NotificationService();
  await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  AndroidOptions getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);
  IOSOptions getIOSOptions() =>
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  prefs = await SharedPreferences.getInstance();

  secureStorage = FlutterSecureStorage(
    aOptions: getAndroidOptions(),
    iOptions: getIOSOptions(),
  );
  await notificationService.initialize();

  await injector.setupDependencyInjection();
  await injector.setupCubit();
  await injector.setupRepo();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Bloc.observer = AppBlocObserver();
}
