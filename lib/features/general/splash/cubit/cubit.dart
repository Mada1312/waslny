import 'dart:developer';

import 'package:waslny/core/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/preferences/preferences.dart';
import 'state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial()) {
    checkUserStatus();
  }
//test branch
  Future<void> checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // mimic splash delay
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LoginModel? userModel = await Preferences.instance.getUserModel();
    if (prefs.getBool('onBoarding') != null) {
      bool isDriver = false;
      log('userModel: ${userModel.data?.userType}');
      if (userModel.data?.token != null) {
        if (userModel.data?.userType == 0) {
          isDriver = false;
        } else {
          isDriver = true;
        }
        emit(SplashNavigateToMain(isDriver: isDriver));
      } else if (userModel.data?.userType == null) {
        emit(SplashNavigateToLogin());
      } else {
        errorGetBar('%%%%%%% ${userModel.data?.userType}');
      }
    } else {
      emit(SplashNavigateToOnboarding());
    }
  }
}
