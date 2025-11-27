import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'onboarding_state.dart';

class OnBoardingCubit extends Cubit<OnboardingState> {
  OnBoardingCubit() : super(OnboardingInitial());
  PageController pageController = PageController(initialPage: 0);
  int numPages = 2;
  double currentPage = 0;

  changePages() {
    currentPage = pageController.page!;
    emit(ChangingPagesState());
  }

  onPageChanged(int page) {
    currentPage = page.toDouble();
    emit(ChangingPagesState());
  }
}
