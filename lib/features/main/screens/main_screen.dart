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
          child: SafeArea(
            top: false,
            child: Scaffold(
              body: cubit.screens[cubit.currentIndex],
              bottomNavigationBar: Container(
                margin: EdgeInsets.only(bottom: 10.w, left: 20.h, right: 20.h),
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

  Future<bool> _showExitDialog(BuildContext context) async {
    bool exitConfirmed = false;
    await AwesomeDialog(
      context: context,
      animType: AnimType.bottomSlide,
      customHeader: Padding(
        padding: const EdgeInsets.all(20),
        child: Image.asset(
          ImageAssets.dialogLogo,
          // color: AppColors.primary,
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
                      backgroundColor: AppColors.secondPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "out".tr(),
                      style: getRegularStyle(color: AppColors.primary),
                    ),
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
                      backgroundColor: AppColors.secondPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "cancel".tr(),
                      style: getRegularStyle(color: AppColors.primary),
                    ),
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
}
