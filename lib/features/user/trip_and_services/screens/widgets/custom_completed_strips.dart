import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/features/user/home/data/models/get_home_model.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/completed_trip_and_service_widget.dart';

// Import your other dependencies (models, enums, packages)
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTripsAndServicesDataList extends StatelessWidget {
  // 1. Data from your Cubit
  final GetUserHomeModel? homeModel;
  final ServicesType? serviceType;

  // 2. The refresh action
  final VoidCallback onRefresh;
  final bool isDriver;

  // 3. Constructor
  const CustomTripsAndServicesDataList({
    super.key,
    required this.homeModel,
    required this.serviceType,
    required this.onRefresh,
    required this.isDriver,
  });

  // --- Internal Helper Logic ---

  // Checks if the current type is 'trips'
  bool get _isTrips => serviceType?.name == ServicesType.trips.name;

  // Checks if the current type is 'services'
  bool get _isServices => serviceType?.name == ServicesType.services.name;

  // Gets the correct list (trips or services) based on the type
  List<dynamic>? get _currentList {
    if (_isTrips) {
      return homeModel?.data?.trips;
    }
    if (_isServices) {
      return homeModel?.data?.services;
    }
    return null; // No type selected
  }

  // Checks if the *selected* list is empty
  bool get _isCurrentListEmpty => _currentList?.isEmpty ?? true;

  // Gets the correct "no data" message
  String get _noDataMessage {
    if (_isTrips) {
      return 'no_trips'.tr();
    }
    if (_isServices) {
      return 'no_serices'.tr();
    }
    return ''; // Default empty message
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // 1. Check if the currently selected list is empty
    if (_isCurrentListEmpty) {
      // Show the "No Data" widget
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.h),
          child: CustomNoDataWidget(
            message: _noDataMessage,
            onTap: onRefresh, // Use the callback
          ),
        ),
      );
    }

    // 2. If we have data, show the ListView
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: (kBottomNavigationBarHeight + 5).h),
      physics: const NeverScrollableScrollPhysics(),

      // We pass the list item from our '_currentList'
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.h),
        child: CompletedTripOrServiceItemWidget(
          isDriver: isDriver,
          tripOrService: _currentList![index],
        ),
      ),

      separatorBuilder: (context, index) => 0.h.verticalSpace,

      // Count is simply the length of our determined list
      itemCount: _currentList?.length ?? 0,
    );
  }
}
