import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/state.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/utils/call_method.dart';

class UserFavDriver extends StatefulWidget {
  const UserFavDriver({super.key});

  @override
  State<UserFavDriver> createState() => _UserFavDriverState();
}

class _UserFavDriverState extends State<UserFavDriver> {
  @override
  void initState() {
    context.read<ProfileCubit>().getMainFavUserDriver();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        var cubit = context.read<ProfileCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text('favorites'.tr()),
          ),
          body: (state is LoadingContactUsState && cubit.mainFavModel == null)
              ? Center(
                  child: CustomLoadingIndicator(),
                )
              : cubit.mainFavModel!.data!.isEmpty
                  ? Center(
                      child: Text('no_data'.tr()),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemCount: cubit.mainFavModel!.data!.length,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      itemBuilder: (context, index) {
                        var driver = cubit.mainFavModel?.data?[index];
                        return Container(
                          margin: EdgeInsets.all(5.w),
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: AppColors.gray,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5.r)),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 50.r,
                                      backgroundImage:
                                          NetworkImage(driver?.image ?? ''),
                                    ),
                                    Text(
                                      driver?.name ?? '',
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400),
                                      maxLines: 1,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        phoneCallMethod(driver?.phone ?? '');
                                      },
                                      child: Text(
                                        driver?.phone ?? '',
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.darkGrey,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PositionedDirectional(
                                end: 0,
                                child: InkWell(
                                    onTap: () {
                                      cubit.actionFav(
                                          driver?.driverId?.toString() ?? '');
                                      //! remove form fav
                                    },
                                    child: Icon(
                                      CupertinoIcons.heart_fill,
                                      color: AppColors.red,
                                    )),
                              )
                            ],
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
