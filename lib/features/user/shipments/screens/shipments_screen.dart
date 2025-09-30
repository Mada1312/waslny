import 'package:waslny/core/exports.dart';

import '../cubit/cubit.dart';
import '../cubit/state.dart';
import 'widgets/shipment_statuss.dart';
import 'widgets/shipment_widget.dart';

class UserShipmentsScreen extends StatelessWidget {
  const UserShipmentsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserShipmentsCubit, UserShipmentsState>(
        builder: (context, state) {
      var cubit = context.read<UserShipmentsCubit>();

      return Scaffold(
        appBar: customAppBar(context, title: 'shipments'.tr()),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomShipmentsTypes(),
            20.h.verticalSpace,
            Expanded(
              child: Center(
                child: state is ShipmentsErrorState
                    ? CustomNoDataWidget(
                        message: 'error_happened'.tr(),
                        onTap: () {
                          cubit.getShipments();
                        },
                      )
                    : state is ShipmentsLoadingState ||
                            cubit.shipmentsModel?.data == null
                        ? const Center(child: CustomLoadingIndicator())
                        : cubit.shipmentsModel?.data?.isEmpty == true
                            ? CustomNoDataWidget(
                                message: 'no_shipments'.tr(),
                                onTap: () {
                                  cubit.getShipments();
                                },
                              )
                            : RefreshIndicator(
                                color: AppColors.primary,
                                onRefresh: () async {
                                  await cubit.getShipments();
                                },
                                child: ListView.separated(
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: getHorizontalPadding(context),
                                      vertical: 3.h,
                                    ),
                                    child: ShipmentItemWidget(
                                      shipment:
                                          cubit.shipmentsModel?.data?[index],
                                      isDelivered: cubit.selectedStatus ==
                                          ShipmentsStatusEnum.delivered,
                                    ),
                                  ),
                                  separatorBuilder: (context, index) =>
                                      20.h.verticalSpace,
                                  itemCount:
                                      cubit.shipmentsModel?.data?.length ?? 0,
                                ),
                              ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
