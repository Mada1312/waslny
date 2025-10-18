import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension BuildContextUtils on BuildContext {
  //! context

  //!  Navigation Helpers
  void to(Widget screen) {
    Navigator.push(this, MaterialPageRoute(builder: (_) => screen));
  }

  void back([dynamic result]) {
    Navigator.of(this).pop(result);
  }

  void toAndRemove(Widget screen) {
    Navigator.of(this)
        .pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  void toAndRemoveAll(Widget screen) {
    Navigator.of(this).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  //!  MediaQuery Shortcuts
  double get w => MediaQuery.of(this).size.width;
  double get h => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  Orientation get orientation => MediaQuery.of(this).orientation;

  //!  Theme Accessors
  ThemeData get theme => Theme.of(this);
  Color get primaryColor => theme.primaryColor;
  TextTheme get textTheme => theme.textTheme;

  //!  Localization Helpers
  bool isCurrentLanguageAr() {
    return locale == const Locale('ar');
  }

  //!  UI Utilities
  void showSnackBar(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), duration: duration),
    );
  }

  void dismissKeyboard() {
    FocusScope.of(this).unfocus();
  }

  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  void printDebug(String text) {
    debugPrint(text);
  }
}
