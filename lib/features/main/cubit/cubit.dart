// ignore_for_file: avoid_unnecessary_containers

import 'package:waslny/core/exports.dart';
import 'package:waslny/features/driver/home/screens/driver_home_screen.dart';
import 'package:waslny/features/driver/shipments/screens/shipments_screen.dart';
import 'package:waslny/features/user/home/screens/user_home_screen.dart';
import 'package:waslny/features/general/notifications/screens/notifications_screen.dart';
import 'package:waslny/features/general/profile/screens/profile_screen.dart';

import '../../general/chat/screens/room_screen.dart';
import '../data/main_repo.dart';
import 'state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit(this.api) : super(MainInitial());

  MainRepo api;

  int currentIndex = 0;
  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeIndexState());
  }

  List<Widget> driverScreens = [
    DriverHomeScreen(),
    NotificationsScreen(isDriver: true),
    AllRoomScreen(),
    ProfileScreen(isDriver: true),
  ];

  List<Widget> userScreens = [
    UserHomeScreen(),

    NotificationsScreen(isDriver: false),
    AllRoomScreen(),

    ProfileScreen(isDriver: false),
  ];
}
