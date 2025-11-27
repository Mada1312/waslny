


abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashNavigateToMain extends SplashState {
  final bool isDriver;

  SplashNavigateToMain({required this.isDriver});
}

class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {}
