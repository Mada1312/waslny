import 'package:waslny/core/exports.dart';

enum Gender { male, female }

extension GenderExtension on Gender {
  String get displayValue {
    switch (this) {
      case Gender.male:
        return 'Male'.tr();
      case Gender.female:
        return 'Female'.tr();
    }
  }
}
