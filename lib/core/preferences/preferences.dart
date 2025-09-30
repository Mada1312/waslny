import 'dart:convert';
import 'dart:developer';
import 'package:waslny/features/general/auth/data/model/login_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../exports.dart';

late SharedPreferences prefs;
late FlutterSecureStorage secureStorage;

class Preferences {
  static final Preferences instance = Preferences._internal();

  Preferences._internal();

  factory Preferences() => instance;

  Future<void> init() async {
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      log('eee ${e.toString()}');
    }
  }

  /// Save user securely
  Future<void> setUser(LoginModel loginModel) async {
    String userJson = jsonEncode(LoginModel.fromJson(loginModel.toJson()));
    await secureStorage.write(key: 'user', value: userJson);
  }

  /// Retrieve user securely
  Future<LoginModel> getUserModel() async {
    String? jsonData = await secureStorage.read(key: 'user');
    if (jsonData != null) {
      return LoginModel.fromJson(jsonDecode(jsonData));
    } else {
      return LoginModel();
    }
  }

  Future<bool> clearUser() async {
    await secureStorage.delete(key: 'user');
    return true;
  }

  /// Save app language using SharedPreferences
  Future<void> savedLang(String local) async {
    await prefs.setString(AppStrings.locale, local);
  }

  /// Get app language using SharedPreferences
  Future<String> getSavedLang() async {
    return prefs.getString(AppStrings.locale) ?? 'ar'; // Default to 'ar'
  }

  /// Save app language using SharedPreferences

  /// Clear all data from secure storage and shared preferences
  Future<void> clearAll() async {
    await secureStorage.deleteAll(); // Clear secure storage
    await prefs.clear(); // Clear shared preferences
  }

  Future<void> setDeviceToken(String token) async {
    try {
      log('=====>> $token');
      await prefs.setString('device_token', token);
    } catch (e) {
      log('=====>> ${e.toString()}');
    }
  }

  /// Get app language using SharedPreferences
  Future<String> getDeviceToken() async {
    return prefs.getString('device_token') ?? 'device_token';
  }

  Future<void> setLocationHours(String hour) async {
    try {
      await prefs.setString('location_hours', hour);
    } catch (e) {
      log('=====>> ${e.toString()}');
    }
  }

  Future<String> getLocationHours() async {
    return prefs.getString('location_hours') ?? '3';
  }
}


// import 'dart:convert';


// import 'package:shared_preferences/shared_preferences.dart';

// import '../models/login_model.dart';

// class Preferences {
//   static final Preferences instance = Preferences._internal();

//   Preferences._internal();

//   factory Preferences() => instance;


//   // Future<void> setFirstInstall() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   prefs.setString('onBoarding', 'Done');
//   // }

//   // Future<String?> getFirstInstall() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? jsonData = prefs.getString('onBoarding');
//   //   return jsonData;
//   // }

//   Future<void> setUser(LoginModel loginModel) async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     preferences.setString(
//         'user', jsonEncode(LoginModel.fromJson(loginModel.toJson())));
//     print(await getUserModel());
//   }
//  Future<void> clearShared()async{
//    SharedPreferences preferences = await SharedPreferences.getInstance();
//    preferences.clear();
//  }
//   Future<LoginModel> getUserModel() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String? jsonData = preferences.getString('user');
//     LoginModel userModel;
//     if (jsonData != null) {
//       userModel = LoginModel.fromJson(jsonDecode(jsonData));
//     } else {
//       userModel = LoginModel();
//     }
//     return userModel;
//   }

// }
