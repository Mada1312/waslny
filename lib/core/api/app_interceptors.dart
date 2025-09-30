import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/general/splash/screens/splash_screen.dart';
import '../preferences/preferences.dart';
import '../utils/app_strings.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[AppStrings.contentType] = AppStrings.applicationJson;
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(response, ResponseInterceptorHandler handler) {
    debugPrint(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
    if (response.statusCode == 401) {
      Preferences.instance.clearUser().then((value) {
        Get.to(const SplashScreen());
      });
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    log('errrrrrrrrrrrrrrrror......................................');
    debugPrint(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    if (err.response!.statusCode == 401 || err.response!.statusCode == 407) {
      Preferences.instance.clearUser().then((value) {
        Get.to(const SplashScreen());
      });
    }
    log('......................................');

    ///
    super.onError(err, handler);
  }
}
