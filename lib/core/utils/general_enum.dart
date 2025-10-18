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

enum ServiceTo { water, electric, gas, purchases }

extension ServiceTypeExtension on ServiceTo {
  String get displayValue {
    switch (this) {
      case ServiceTo.water:
        return 'water'.tr();
      case ServiceTo.electric:
        return 'electric'.tr();
      case ServiceTo.gas:
        return 'gas'.tr();
      case ServiceTo.purchases:
        return 'purchases'.tr();
    }
  }

  int get id {
    switch (this) {
      case ServiceTo.water:
        return 1;
      case ServiceTo.electric:
        return 2;
      case ServiceTo.gas:
        return 3;
      case ServiceTo.purchases:
        return 4;
    }
  }
}
