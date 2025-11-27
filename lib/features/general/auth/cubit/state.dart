import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginStateInitial extends LoginState {}

class LoadingsendCodeState extends LoginState {}

class LoadingLoginState extends LoginState {}

class ErrorLoginState extends LoginState {}

class LoadedLoginState extends LoginState {}

class LoadingVerifyCodeState extends LoginState {}

class LoadedVerifyCodeState extends LoginState {}

class ErrorVerifyCodeState extends LoginState {}

class LoadedsendCodeState extends LoginState {}

class ErrorsendCodeState extends LoginState {}

class LoadingNewPasswordState extends LoginState {}

class LoadedNewPasswordState extends LoginState {}

class ErrorNewPasswordState extends LoginState {}

class LoadingValidateDataState extends LoginState {}

class LoadedValidateDataState extends LoginState {}

class ErrorValidateDataState extends LoginState {}

class PickImageFromGallaryState extends LoginState {}

class GetAuthDataLoading extends LoginState {}

class GetAuthDataLoaded extends LoginState {}

class GetAuthDataError extends LoginState {}

class LoadingUpadteProfileState extends LoginState {}

class LoadedUpadteProfileState extends LoginState {}

class ErrorUpadteProfileState extends LoginState {}

class OnChangeStatusOfLogin extends LoginState {}
