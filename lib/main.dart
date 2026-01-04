import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/init_config/initalization_config.dart';
import 'core/notification_services/notification_service.dart';
import 'core/utils/restart_app_class.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔧 App initialization (DI, Firebase, prefs, etc.)
  await initializationClass();

  // 🔔 Init notification service (foreground + background + channels)
  await NotificationService.instance.initialize();

  // 📩 Background handler بس (foreground في NotificationService)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar', ''), Locale('en', '')],
      path: 'assets/lang',
      saveLocale: true,
      startLocale: const Locale('ar', ''),
      fallbackLocale: const Locale('ar', ''),
      child: const MyAppWithScreenUtil(),
    ),
  );
}

/// ===============================================================
/// ROOT APP WITH ScreenUtil (Responsive لكل الأحجام)
/// ===============================================================
class MyAppWithScreenUtil extends StatelessWidget {
  const MyAppWithScreenUtil({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // ✅ Responsive لكل الأحجام - مش قيمة ثابتة
      designSize: Size(
        MediaQuery.sizeOf(context).width > 400 ? 414 : 375,
        MediaQuery.sizeOf(context).height > 850 ? 896 : 812,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true, // ✅ يضمن الحجم على كل الأجهزة
      builder: (context, child) {
        return HotRestartController(child: const MyApp());
      },
    );
  }
}
