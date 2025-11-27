import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/state.dart';
import 'package:flutter_html/flutter_html.dart';

class PrivacyAndTermsScreen extends StatefulWidget {
  const PrivacyAndTermsScreen({super.key});

  @override
  State<PrivacyAndTermsScreen> createState() => _PrivacyAndTermsScreenState();
}

class _PrivacyAndTermsScreenState extends State<PrivacyAndTermsScreen> {
  @override
  void initState() {
    if (context.read<ProfileCubit>().settings == null) {
      context.read<ProfileCubit>().getSettings(context);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ProfileCubit>();
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('terms_and_conditions'.tr())),
          body: state is LoadingContactUsState
              ? Center(child: CustomLoadingIndicator())
              : Container(
                  color: AppColors.white,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.unSeen,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.sp),
                        topRight: Radius.circular(30.sp),
                      ),
                    ),
                    child: ListView(
                      children: [
                        Html(
                          data: cubit.settings?.data?.privacy.toString() ?? '',
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
