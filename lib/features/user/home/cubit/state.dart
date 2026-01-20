// abstract class UserHomeState {}

// class UserHomeInitial extends UserHomeState {}

// class UserHomeLoading extends UserHomeState {}

// class UserHomeLoaded extends UserHomeState {}

// class UserHomeError extends UserHomeState {}
// class ChangeRateValueState extends UserHomeState {}
// class AddRateForDriverLoadingState extends UserHomeState {}

// class AddRateForDriverErrorState extends UserHomeState {}

// class AddRateForDriverSuccessState extends UserHomeState {}

import '../data/models/get_home_model.dart';

abstract class UserHomeState {}

class UserHomeInitial extends UserHomeState {}

class UserHomeLoading extends UserHomeState {}

class UserHomeLoaded extends UserHomeState {}

class UserHomeError extends UserHomeState {}

class ChangeRateValueState extends UserHomeState {}

class AddRateForDriverLoadingState extends UserHomeState {}

class AddRateForDriverErrorState extends UserHomeState {}

class AddRateForDriverSuccessState extends UserHomeState {}

/// ✅ ده اللي هيظهر Dialog التقييم/تفاصيل الرحلة (بعد النهاية فقط)
class TripEndedState extends UserHomeState {
  final TripAndServiceModel trip;
  TripEndedState(this.trip);
}
