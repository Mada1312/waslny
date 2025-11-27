import 'package:waslny/core/exports.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'widgets/trip_widget.dart';

class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  @override
  void initState() {
    context.read<DriverTripsCubit>().getTrips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverTripsCubit, DriverTripsState>(
      builder: (context, state) {
        var cubit = context.read<DriverTripsCubit>();
        return Scaffold(
          appBar: customAppBar(
            context,
            title: 'scheduled_trips'.tr(),
            isCenterTitle: true,
            isDriverBackIcon: true,
          ),
          body: Center(
            child: state is GetTripsErrorState
                ? CustomNoDataWidget(
                    message: 'error_happened'.tr(),
                    onTap: () {
                      cubit.getTrips();
                    },
                  )
                : state is GetTripsLoadingState ||
                      cubit.getTripsModel?.data == null
                ? const CustomLoadingIndicator()
                : cubit.getTripsModel?.data?.isEmpty ?? true
                ? CustomNoDataWidget(message: 'no_trips_yet'.tr())
                : RefreshIndicator(
                    color: AppColors.primary,

                    onRefresh: () async {
                      await cubit.getTrips();
                    },
                    child: ListView.separated(
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: getHorizontalPadding(context),
                          vertical: 3.h,
                        ),
                        child: DriverTripPrServiceItemWidget(
                          withContactWidget: true,
                          trip: cubit.getTripsModel?.data?[index],
                        ),
                      ),
                      separatorBuilder: (context, index) => 20.h.verticalSpace,

                      itemCount: cubit.getTripsModel?.data?.length ?? 0,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
