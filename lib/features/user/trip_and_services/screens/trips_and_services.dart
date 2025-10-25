import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/custom_completed_strips.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';

class UserTripsAndServicesScreen extends StatefulWidget {
  const UserTripsAndServicesScreen({super.key});

  @override
  State<UserTripsAndServicesScreen> createState() =>
      _UserTripsAndServicesScreenState();
}

class _UserTripsAndServicesScreenState
    extends State<UserTripsAndServicesScreen> {
  @override
  void initState() {
    var cubit = context.read<UserTripAndServicesCubit>();
    cubit.getCompletedTripsAndServices(
      context.read<UserHomeCubit>().serviceType!,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserTripAndServicesCubit, UserTripAndServicesState>(
      builder: (context, state) {
        var cubit = context.read<UserTripAndServicesCubit>();
        var cubit2 = context.read<UserHomeCubit>();
        return Scaffold(
          appBar: customAppBar(context, title: 'trips'.tr()),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdownButtonFormField<ServicesType>(
                        items: ServicesType.values,

                        itemBuilder: (item) => item.displayValue,
                        value: cubit2.serviceType,
                        fillColor: AppColors.second2Primary,

                        onChanged: (value) async {
                          setState(() {
                            cubit2.serviceType = value;
                          });
                          await cubit.getCompletedTripsAndServices(
                            cubit2.serviceType!,
                          );
                        },
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
                20.h.verticalSpace,
                Expanded(
                  child: state is ErrorCompletedTripAndServiceState
                      ? Center(
                          child: CustomNoDataWidget(
                            message: 'error_happened'.tr(),
                            onTap: () async {
                              await cubit.getCompletedTripsAndServices(
                                cubit2.serviceType!,
                              );
                            },
                          ),
                        )
                      : state is LoadingCompletedTripAndServiceState ||
                            cubit.completedTripsModel?.data == null
                      ? const Center(child: CustomLoadingIndicator())
                      : CustomTripsAndServicesDataList(
                          homeModel: cubit.completedTripsModel,
                          onRefresh: () async {
                            await cubit.getCompletedTripsAndServices(
                              cubit2.serviceType!,
                            );
                          },
                          serviceType: cubit2.serviceType,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
