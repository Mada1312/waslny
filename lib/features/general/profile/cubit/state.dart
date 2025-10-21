abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class AppUtilsSuccess extends ProfileState {
  final String message;
  AppUtilsSuccess(this.message);
}

class AppUtilsError extends ProfileState {
  final String error;
  AppUtilsError(this.error);
}

class LoadingContactUsState extends ProfileState {}

class LoadedContactUsState extends ProfileState {}

class ErrorContactUsState extends ProfileState {}

class LoadingCloneTripState extends ProfileState {}

class LoadedCloneTripState extends ProfileState {}

class ErrorCloneTripState extends ProfileState {}

class DateTimeSelected extends ProfileState {}
