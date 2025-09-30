import 'package:waslny/core/exports.dart';
import 'package:waslny/core/widgets/network_image.dart';
import 'package:waslny/features/general/auth/cubit/cubit.dart';

import '../../features/general/auth/cubit/state.dart';

class CustomUserInfo extends StatelessWidget {
  const CustomUserInfo({
    super.key,
    this.textColor,
  });
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        var cubit = context.read<LoginCubit>();
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomNetworkImage(
              image: cubit.authData?.data?.image ?? "",
              isUser: true,
              borderRadius: 100,
              height: 50.h,
              width: 50.h,
            ),
            10.w.horizontalSpace,
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cubit.authData?.data?.name ?? '',
                  maxLines: 2,
                  style: getSemiBoldStyle(
                    fontSize: 16.sp,
                    color: textColor ?? AppColors.black,
                  ),
                ),
                5.h.verticalSpace,
                Text(
                  cubit.authData?.data?.address ?? '',
                  style: getRegularStyle(
                    fontSize: 14.sp,
                    color: textColor ?? AppColors.grey,
                  ),
                ),
              ],
            ))
          ],
        );
      },
    );
  }
}
