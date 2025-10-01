import 'package:waslny/core/exports.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'widgets/shipment_widget.dart';

class DriverShipmentsScreen extends StatefulWidget {
  const DriverShipmentsScreen({
    super.key,
  });

  @override
  State<DriverShipmentsScreen> createState() => _DriverShipmentsScreenState();
}

class _DriverShipmentsScreenState extends State<DriverShipmentsScreen> {
  @override
  void initState() {
    context.read<DriverShipmentsCubit>().getShipments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverShipmentsCubit, DriverShipmentsState>(
        builder: (context, state) {
      var cubit = context.read<DriverShipmentsCubit>();
      return Scaffold(
        appBar:
            customAppBar(context, title: 'trips'.tr(), leading: SizedBox()),
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
                      ? CustomNoDataWidget(
                          message: 'no_trips'.tr(),
                        )
                      : ListView.separated(
                          itemBuilder: (context, index) => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getHorizontalPadding(context),
                              vertical: 3.h,
                            ),
                            child: DriverShipmentItemWidget(
                              withContactWidget: true,
                              shipment: cubit.shipmentsModel!.data![index],

                              // shipment: cubit.shipments[index],
                            ),
                          ),
                          separatorBuilder: (context, index) =>
                              20.h.verticalSpace,
                          itemCount: cubit.shipmentsModel?.data?.length ?? 0,
                        ),
        ),
      );
    });
  }
}
