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

enum VehicleType { car, scooter }

extension VehicleTypeExtension on VehicleType {
  String get displayValue {
    switch (this) {
      case VehicleType.car:
        return 'car'.tr();
      case VehicleType.scooter:
        return 'scooter'.tr();
    }
  }
}

enum ServicesType { trips, services }

extension ServicesTypeExtension on ServicesType {
  String get displayValue {
    switch (this) {
      case ServicesType.trips:
        return 'trips'.tr();
      case ServicesType.services:
        return 'services'.tr();
    }
  }
}
