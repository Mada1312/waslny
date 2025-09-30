import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/call_method.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/splash/cubit/state.dart';

import '../cubit/cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<LocationCubit>().checkAndRequestLocationPermission(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToMain) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.mainRoute,
            arguments: state.isDriver,
            (route) => false,
          );
        } else if (state is SplashNavigateToLogin) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.chooseLoginRoute,
            (route) => false,
          );
        } else if (state is SplashNavigateToOnboarding) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.onboardingRoute,
            (route) => false,
          );
        }
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Image.asset(
                ImageAssets.splashBG,
                fit: BoxFit.cover,
                height: getHeightSize(context),
                width: getWidthSize(context),
              ),
              Container(
                color: AppColors.background.withOpacity(0.8),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 50.h,
                    left: 70.w,
                    right: 70.w,
                  ),
                  child: Image.asset(
                    ImageAssets.appIcon,
                    height: 160.h,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  openExternal('https://octopusteam.net/');
                },
                child: Image.asset(ImageAssets.octopusTeamImage,
                    height: getHeightSize(context) * 0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
