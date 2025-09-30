import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';
import '../../general/profile/cubit/cubit.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.isDriver});
  final bool isDriver;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().getAuthData(context);
    context.read<MainCubit>().changeIndex(0);

    context.read<ProfileCubit>().getSettings(context);
  }

  @override
  Widget build(BuildContext context) {
    MainCubit cubit = context.read<MainCubit>();
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (cubit.currentIndex != 0) {
              cubit.changeIndex(0);
              return false;
            } else {
              bool shouldExit = await _showExitDialog(context);
              if (shouldExit) {
                SystemNavigator.pop(); // الخروج من التطبيق بعد التأكيد.
              }
              return shouldExit;
            }
          },
          child: Scaffold(
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.white,
                showUnselectedLabels: true,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.dark2Grey,
                elevation: 10,
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      ImageAssets.home,
                      height: 25.h,
                      width: 25.h,
                      color: cubit.currentIndex == 0
                          ? AppColors.primary
                          : AppColors.dark2Grey,
                    ),
                    label: "home".tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      ImageAssets.notifications,
                      height: 25.h,
                      width: 25.h,
                      color: cubit.currentIndex == 1
                          ? AppColors.primary
                          : AppColors.dark2Grey,
                    ),
                    label: "notifications".tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      ImageAssets.messages,
                      height: 25.h,
                      width: 25.h,
                      color: cubit.currentIndex == 2
                          ? AppColors.primary
                          : AppColors.dark2Grey,
                    ),
                    label: "messages".tr(),
                  ),
                  if (widget.isDriver == true)
                    BottomNavigationBarItem(
                        icon: Image.asset(
                          widget.isDriver
                              ? ImageAssets.shipments
                              : ImageAssets.messages,
                          height: 25.h,
                          width: 25.h,
                          color: cubit.currentIndex == 3
                              ? AppColors.primary
                              : AppColors.dark2Grey,
                        ),
                        label: "shipments".tr()),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      ImageAssets.myProfile,
                      height: 25.h,
                      width: 25.h,
                      color: widget.isDriver == false
                          ? cubit.currentIndex == 3
                              ? AppColors.primary
                              : AppColors.dark2Grey
                          : cubit.currentIndex == 4
                              ? AppColors.primary
                              : AppColors.dark2Grey,
                    ),
                    label: "my_account".tr(),
                  ),
                ],
                // useLegacyColorScheme: false,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  context.read<MainCubit>().changeIndex(index);
                },
              ),
            ),
            body: SafeArea(
              top: false,
              child: widget.isDriver
                  ? cubit.driverScreens[cubit.currentIndex]
                  : cubit.userScreens[cubit.currentIndex],
            ),
          ),
        );
      },
    );
  }
}

Future<bool> _showExitDialog(BuildContext context) async {
  bool exitConfirmed = false;
  await AwesomeDialog(
    context: context,
    animType: AnimType.bottomSlide,
    customHeader: Padding(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        ImageAssets.appIcon,
        color: AppColors.primary,
        width: 80,
        height: 80,
      ),
    ),
    body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "exit_app".tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    exitConfirmed = true; // تأكيد تسجيل الخروج
                    Navigator.of(context).pop(); // إغلاق الـ Dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("out".tr(),
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    exitConfirmed = false; // المستخدم لا يريد الخروج
                    Navigator.of(context).pop(); // إغلاق الـ Dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("cancel".tr(),
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ).show();

  return exitConfirmed;
}
