import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/profile/cubit/cubit.dart';
import 'package:waslny/features/general/profile/cubit/state.dart';

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
          appBar: AppBar(
            title: Text('terms_and_conditions'.tr()),
          ),
          body: state is LoadingContactUsState
              ? Center(
                  child: CustomLoadingIndicator(),
                )
              : ListView(
                  children: [
                    Text(cubit.settings?.data?.privacy.toString() ?? '')
                  ],
                ),
        );
      },
    );
  }
}
