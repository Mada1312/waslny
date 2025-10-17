import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';

import '../../features/general/auth/cubit/state.dart';

class CustomUserInfo extends StatelessWidget {
  const CustomUserInfo({super.key, this.textColor});
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          var cubit = context.read<LoginCubit>();
          return Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 30.h),
                padding: EdgeInsets.all(5.h),
                decoration: BoxDecoration(
                  color: AppColors.second2Primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    60.w.horizontalSpace,
                    Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              cubit.authData?.data?.name ?? 'الاسم',
                              maxLines: 1,
                              style: getSemiBoldStyle(
                                fontSize: 16.sp,
                                color: textColor ?? AppColors.black,
                              ),
                            ),

                            Text(
                              cubit.authData?.data?.address ?? 'القاهره, مصر',
                              maxLines: 1,
                              style: getRegularStyle(
                                fontSize: 12.sp,
                                color: textColor ?? AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CustomNetworkImage(
                  image: cubit.authData?.data?.image ?? "",
                  isUser: true,
                  borderRadius: 100,
                  height: 60.h,
                  width: 60.h,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
