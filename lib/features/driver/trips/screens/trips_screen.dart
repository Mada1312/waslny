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
    context.read<DriverTripsCubit>().getShipments();
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
            title: 'trips'.tr(),
            leading: SizedBox(),
          ),
          body: Center(
            child: state is GetShipmentsErrorState
                ? CustomNoDataWidget(
                    message: 'error_happened'.tr(),
                    onTap: () {
                      cubit.getShipments();
                    },
                  )
                : state is GetShipmentsLoadingState ||
                      cubit.shipmentsModel?.data == null
                ? const CustomLoadingIndicator()
                : cubit.shipmentsModel?.data?.isEmpty ?? true
                ? CustomNoDataWidget(message: 'no_trips'.tr())
                : ListView.separated(
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: getHorizontalPadding(context),
                        vertical: 3.h,
                      ),
                      child: DriverTripPrServiceItemWidget(
                        withContactWidget: true,
                        shipment: cubit.shipmentsModel!.data![index],

                        // shipment: cubit.shipments[index],
                      ),
                    ),
                    separatorBuilder: (context, index) => 20.h.verticalSpace,
                    itemCount: cubit.shipmentsModel?.data?.length ?? 0,
                  ),
          ),
        );
      },
    );
  }
}
