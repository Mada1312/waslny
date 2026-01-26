import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waslny/core/notification_services/service/fcm_service.dart';
import 'package:waslny/firebase_options.dart';
import 'app.dart';
import 'core/init_config/initalization_config.dart';
import 'core/utils/restart_app_class.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ ضروري للـ Notifications
  // ✅ هيّا Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ سجل Background Handler
  FirebaseMessaging.onBackgroundMessage(FCMService.handleBackgroundMessage);
  await initializationClass();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar', ''), Locale('en', '')],
      path: 'assets/lang',
      saveLocale: true,
      startLocale: const Locale('ar', ''),
      fallbackLocale: const Locale('ar', ''),
      child: MyAppWithScreenUtil(),
    ),
  );
}

class MyAppWithScreenUtil extends StatelessWidget {
  const MyAppWithScreenUtil({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return HotRestartController(child: const MyApp());
      },
    );
  }
}
