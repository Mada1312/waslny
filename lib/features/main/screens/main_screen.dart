// import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:waslny/core/exports.dart';

import '../../general/auth/cubit/cubit.dart';
import '../../general/profile/cubit/cubit.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.isDriver});
  final bool isDriver;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late MainCubit cubit;

  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().getAuthData(context);
    cubit = context.read<MainCubit>();
    cubit.changeIndex(0);
    context.read<ProfileCubit>().getSettings(context);

    tabController = TabController(length: 4, vsync: this);
    tabController.animation?.addListener(() {
      final value = tabController.animation!.value.round();
      if (value != cubit.currentIndex && mounted) {
        cubit.changeIndex(value);
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (cubit.currentIndex != 0) {
              cubit.changeIndex(0);
              tabController.animateTo(0);
              return false;
            } else {
              bool shouldExit = await showExitDialog(context);
              if (shouldExit) {
                SystemNavigator.pop();
              }
              return shouldExit;
            }
          },

          child: SafeArea(
            top: false,
            child: Scaffold(
              body: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  widget.isDriver
                      ? cubit.driverScreens[cubit.currentIndex]
                      : cubit.userScreens[cubit.currentIndex],

                  Container(
                    margin: EdgeInsets.only(
                      bottom: 10.w,
                      left: 20.h,
                      right: 20.h,
                    ),
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondPrimary, // Dark green background
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(
                          ImageAssets.home,
                          0,
                          cubit.currentIndex,
                          cubit,
                        ),
                        _buildNavItem(
                          ImageAssets.notifications,
                          1,
                          cubit.currentIndex,
                          cubit,
                        ),
                        _buildNavItem(
                          ImageAssets.messages,
                          2,
                          cubit.currentIndex,
                          cubit,
                        ),
                        _buildNavItem(
                          ImageAssets.myProfile,
                          3,
                          cubit.currentIndex,
                          cubit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // bottomNavigationBar: Container(
              //   margin: EdgeInsets.only(bottom: 10.w, left: 20.h, right: 20.h),
              //   padding: EdgeInsets.all(3.r),
              //   decoration: BoxDecoration(
              //     color: AppColors.secondPrimary, // Dark green background
              //     borderRadius: BorderRadius.circular(100.r),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       _buildNavItem(
              //           ImageAssets.home, 0, cubit.currentIndex, cubit),
              //       _buildNavItem(ImageAssets.notifications, 1,
              //           cubit.currentIndex, cubit),
              //       _buildNavItem(
              //           ImageAssets.messages, 2, cubit.currentIndex, cubit),
              //       _buildNavItem(
              //           ImageAssets.myProfile, 3, cubit.currentIndex, cubit),
              //     ],
              //   ),

              // ),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Custom nav item (using GestureDetector instead of BottomNavigationBarItem)
  Widget _buildNavItem(
    String asset,
    int index,
    int currentIndex,
    MainCubit cubit,
  ) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => cubit.changeIndex(index),
      child: Container(
        padding: EdgeInsets.all(15.sp),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary, // Yellow circle
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondPrimary, // Green border
                  width: 3,
                ),
              )
            : null,
        child: Image.asset(
          asset,
          height: 25,
          width: 25,
          color: isSelected
              ? AppColors
                    .secondPrimary // Dark green icon
              : Colors.white, // Unselected white
        ),
      ),
    );
  }
}
// // import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
// import 'package:waslny/core/exports.dart';

// import '../../general/auth/cubit/cubit.dart';
// import '../../general/profile/cubit/cubit.dart';
// import '../cubit/cubit.dart';
// import '../cubit/state.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key, required this.isDriver});
//   final bool isDriver;

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController tabController;
//   late MainCubit cubit;

//   @override
//   void initState() {
//     super.initState();
//     context.read<LoginCubit>().getAuthData(context);
//     cubit = context.read<MainCubit>();
//     cubit.changeIndex(0);
//     context.read<ProfileCubit>().getSettings(context);

//     tabController = TabController(length: 4, vsync: this);
//     tabController.animation?.addListener(() {
//       final value = tabController.animation!.value.round();
//       if (value != cubit.currentIndex && mounted) {
//         cubit.changeIndex(value);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<MainCubit, MainState>(
//       builder: (context, state) {
//         return WillPopScope(
//           onWillPop: () async {
//             if (cubit.currentIndex != 0) {
//               cubit.changeIndex(0);
//               tabController.animateTo(0);
//               return false;
//             } else {
//               bool shouldExit = await showExitDialog(context);
//               if (shouldExit) {
//                 SystemNavigator.pop();
//               }
//               return shouldExit;
//             }
//           },
//           child: SafeArea(
//             top: false,
//             child: Scaffold(
//               extendBody: true,
//               body: BottomBar(
//                 fit: StackFit.expand,
//                 borderRadius: BorderRadius.circular(100),
//                 duration: const Duration(milliseconds: 400),
//                 curve: Curves.decelerate,
//                 showIcon: false,

//                 width: MediaQuery.of(context).size.width * 0.8,
//                 barColor: AppColors.secondPrimary, // Transparent background
//                 barAlignment: Alignment.bottomCenter,
//                 respectSafeArea: true,

//                 body: (context, controller) {
//                   return widget.isDriver
//                       ? cubit.driverScreens[cubit.currentIndex]
//                       : cubit.userScreens[cubit.currentIndex];
//                 },
//                 child: TabBar(
//                   controller: tabController,

//                   indicatorColor: AppColors.primary,

//                   tabs: [
//                     Tab(
//                       icon: CircleAvatar(
//                         backgroundColor: cubit.currentIndex == 0
//                             ? AppColors.primary
//                             : Colors.transparent,
//                         child: Image.asset(
//                           ImageAssets.home,
//                           height: 25,
//                           width: 25,
//                           color: cubit.currentIndex == 0
//                               ? AppColors.secondPrimary
//                               : AppColors.white,
//                         ),
//                       ),
//                     ),
//                     Tab(
//                       icon: CircleAvatar(
//                         backgroundColor: cubit.currentIndex == 1
//                             ? AppColors.primary
//                             : Colors.transparent,
//                         child: Image.asset(
//                           ImageAssets.notifications,
//                           height: 25,
//                           width: 25,
//                           color: cubit.currentIndex == 1
//                               ? AppColors.secondPrimary
//                               : AppColors.white,
//                         ),
//                       ),
//                     ),

//                     Tab(
//                       icon: CircleAvatar(
//                         backgroundColor: cubit.currentIndex == 2
//                             ? AppColors.primary
//                             : Colors.transparent,
//                         child: Image.asset(
//                           ImageAssets.messages,
//                           height: 25,
//                           width: 25,
//                           color: cubit.currentIndex == 2
//                               ? AppColors.secondPrimary
//                               : AppColors.white,
//                         ),
//                       ),
//                     ),
//                     Tab(
//                       icon: CircleAvatar(
//                         backgroundColor: cubit.currentIndex == 3
//                             ? AppColors.primary
//                             : Colors.transparent,
//                         child: Image.asset(
//                           ImageAssets.myProfile,
//                           height: 25,
//                           width: 25,
//                           color: cubit.currentIndex == 3
//                               ? AppColors.secondPrimary
//                               : AppColors.white,
//                         ),
//                       ),
//                     ),
//                   ],

//                   // indicatorWeight: 0.0001,
//                   indicator: BoxDecoration(),
//                   onTap: (index) {
//                     cubit.changeIndex(index);
//                     tabController.animateTo(index);
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

// }
// //
// // Future<bool> _showExitDialog(BuildContext context) async {
// //   bool exitConfirmed = false;
// //   await AwesomeDialog(
// //     context: context,
// //     animType: AnimType.bottomSlide,
// //     customHeader: Padding(
// //       padding: const EdgeInsets.all(20),
// //       child: Image.asset(
// //         ImageAssets.dialogLogo,
// //         // color: AppColors.primary,
// //         width: 80,
// //         height: 80,
// //       ),
// //     ),
// //     body: Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Text(
// //           "exit_app".tr(),
// //           textAlign: TextAlign.center,
// //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         const SizedBox(height: 10),
// //         Text(
// //           "exit_app_desc".tr(),
// //           textAlign: TextAlign.center,
// //           style: const TextStyle(fontSize: 16),
// //         ),
// //         const SizedBox(height: 20),
// //         Padding(
// //           padding: const EdgeInsets.all(8.0),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Expanded(
// //                 child: ElevatedButton(
// //                   onPressed: () {
// //                     exitConfirmed = true; // تأكيد تسجيل الخروج
// //                     Navigator.of(context).pop(); // إغلاق الـ Dialog
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.secondPrimary,
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8)),
// //                   ),
// //                   child: Text("out".tr(),
// //                       style: getRegularStyle(color: AppColors.primary)),
// //                 ),
// //               ),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                 child: ElevatedButton(
// //                   onPressed: () {
// //                     exitConfirmed = false; // المستخدم لا يريد الخروج
// //                     Navigator.of(context).pop(); // إغلاق الـ Dialog
// //                   },
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.secondPrimary,
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8)),
// //                   ),
// //                   child: Text("cancel".tr(),
// //                       style: getRegularStyle(color: AppColors.primary)),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     ),
// //   ).show();
// //
// //   return exitConfirmed;
// // }

Future<bool> showExitDialog(BuildContext context) async {
  bool exitConfirmed = false;

  await showGeneralDialog(
    context: context,
    barrierLabel: "ExitDialog",
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOut)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          ImageAssets.dialogLogo,
                          width: 80,
                          height: 80,
                        ),
                      ),
                      Text(
                        "exit_app".tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "exit_app_desc".tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  exitConfirmed = true;
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "out".tr(),
                                  style: getRegularStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  exitConfirmed = false;
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "cancel".tr(),
                                  style: getRegularStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );

  return exitConfirmed;
}
