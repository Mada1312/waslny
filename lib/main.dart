import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app.dart';
import 'core/init_config/initalization_config.dart';
import 'core/utils/restart_app_class.dart';
import 'features/driver/background_services.dart';

//TODO
//!>> make driver details screen
void main() async {
  await initializationClass();
  // تهيئة الـ Background Service
  // await initializeService();
  runApp(EasyLocalization(
      supportedLocales: const [Locale('ar', ''), Locale('en', '')],
      path: 'assets/lang',
      saveLocale: true,
      startLocale: const Locale('ar', ''),
      fallbackLocale: const Locale('ar', ''),
      child: MyAppWithScreenUtil()));
}

class MyAppWithScreenUtil extends StatelessWidget {
  const MyAppWithScreenUtil({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return HotRestartController(child: const MyApp());
      },
    );
  }
}
