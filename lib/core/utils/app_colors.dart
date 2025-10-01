import 'package:flutter/material.dart';

import 'hex_color.dart';

class AppColors {

  static Color primary = HexColor('#DFDD00');

  static Color secondPrimary = HexColor('#003D2E');

  static Color lightGrey = HexColor('#F2F2F2');

  static Color greyFieldColor = const Color(0xffF2F2F2);

  static Color darkGrey = HexColor('#373737');
  static Color menuContainer = HexColor('#e6eceb');
  static Color unSeen = HexColor('#b3c5c1');
  // static Color seen = HexColor('#b3c5c1');

  // static Color darkGrey = HexColor('#939393');
  static Color dark2Grey = HexColor('#09183F');
  static Color grey = HexColor('#939393');
  static Color grey2 = HexColor('#D8DDE1');
  static Color red = HexColor('#E6242E');
  static Color green = HexColor('#3B9A00');
  static Color black = Colors.black;
  static Color blackLite = Colors.black12;
  static Color success = Colors.green;
  static Color white = Colors.white;
  static Color error = Colors.red;
  static Color transparent = Colors.transparent;

  static Color gray = Colors.grey;

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lightens(String color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(HexColor(color));
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
