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

enum TimeType { now, later }

extension TimeTypeExtension on TimeType {
  String get displayValue {
    switch (this) {
      case TimeType.now:
        return 'now'.tr();
      case TimeType.later:
        return 'later'.tr();
    }
  }
}

enum ServiceType { water, electric, gas, purchases }

extension ServiceTypeExtension on ServiceType {
  String get displayValue {
    switch (this) {
      case ServiceType.water:
        return 'water'.tr();
      case ServiceType.electric:
        return 'electric'.tr();
      case ServiceType.gas:
        return 'gas'.tr();
      case ServiceType.purchases:
        return 'purchases'.tr();
    }
  }

  int get id {
    switch (this) {
      case ServiceType.water:
        return 1;
      case ServiceType.electric:
        return 2;
      case ServiceType.gas:
        return 3;
      case ServiceType.purchases:
        return 4;
    }
  }
}
