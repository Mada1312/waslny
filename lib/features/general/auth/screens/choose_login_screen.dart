import 'package:waslny/core/exports.dart';

class ChooseLoginScreen extends StatelessWidget {
  const ChooseLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            ImageAssets.login,
            fit: BoxFit.cover,
            height: getHeightSize(context),
            width: getWidthSize(context),
          ),
          Container(
            color: AppColors.background.withOpacity(0.8),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              LoginAsWidget(type: 'driver'),
              LoginAsWidget(type: 'user'),
            ],
          )
        ],
      ),
    );
  }
}

class LoginAsWidget extends StatelessWidget {
  const LoginAsWidget({
    super.key,
    required this.type,
  });

  final String type;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: getHeightSize(context) * 0.3,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24.sp),
          image: DecorationImage(
            image: AssetImage(
              type == 'driver'
                  ? ImageAssets.driverLogin
                  : ImageAssets.userLogin,
            ),
            fit: BoxFit.cover,
          )),
      padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flexible(
          //   fit: FlexFit.tight,
          //   child: Image.asset(
          //     type == 'driver'
          //         ? ImageAssets.driverLogin
          //         : ImageAssets.userLogin,
          //   ),
          // ),
          // SizedBox(height: 20.h),
          CustomButton(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 5,
              ),
              title: type == 'driver'
                  ? "login_as_driver".tr()
                  : "login_as_user".tr(),
              radius: 10.sp,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.loginRoute,
                  arguments: type == 'driver',
                );
              }),
        ],
      ),
    );
  }
}
