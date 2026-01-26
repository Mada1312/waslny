import 'dart:developer' show log;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/get_route_distance.dart';
import 'package:waslny/features/driver/home/cubit/cubit.dart'
    show DriverHomeCubit;
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/navigation/navigation_screen.dart';
import 'package:waslny/features/user/trip_and_services/screens/widgets/call_message.dart';

class CustomsSheduledTripWidet extends StatelessWidget {
  const CustomsSheduledTripWidet({super.key, this.trip});
  final DriverTripModel? trip;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<DriverHomeCubit>();
    final actionTitle = _getActionButtonTitle(trip);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: 15.h),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: AppColors.grey.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.all(15.sp),
          child: Column(
            children: [
              // ✅ Banner يظهر فقط لو Service
              if (trip?.isService == 1) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.amberAccent),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: getSemiBoldStyle(fontSize: 12.sp),
                      children: [
                        const TextSpan(
                          text:
                              'يتم احتساب خدمة شحن مدكور / طلب المشتريات بقيمة (',
                        ),
                        TextSpan(
                          text: '45 جنيهاً',
                          style: getSemiBoldStyle(
                            fontSize: 12.sp,
                            fontweight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(text: ') للمحل الواحد، مع إضافة '),
                        TextSpan(
                          text: '10 جنيهاً',
                          style: getSemiBoldStyle(
                            fontSize: 12.sp,
                            fontweight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(text: ' لكل محل إضافي ضمن نفس الطلب.'),
                      ],
                    ),
                  ),
                ),
                8.h.verticalSpace,
              ],

              // From
              FromToContainer(
                isFrom: true,
                address: trip?.from,
                lat: trip?.fromLat,
                lng: trip?.fromLong,
              ),
              8.h.verticalSpace,

              // To
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: FromToContainer(
                      isFrom: false,
                      address: trip?.serviceToName ?? trip?.to,
                      lat: trip?.toLat,
                      lng: trip?.toLong,
                      isService: trip?.isService == 1,
                    ),
                  ),
                ],
              ),

              // Distance
              if ((trip?.distance?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      10.w.horizontalSpace,
                      Flexible(child: TripDistanceTimeRows(trip: trip)),
                    ],
                  ),
                ),

              // Description
              if (trip?.description != null &&
                  trip!.description!.isNotEmpty) ...[
                12.h.verticalSpace,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.second3Primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.all(12.sp),
                  width: double.infinity,
                  child: Text(
                    trip?.description ?? "",
                    style: getMediumStyle(fontSize: 12.sp),
                  ),
                ),
              ],

              10.h.verticalSpace,

              // Buttons Row
              Row(
                children: [
                  // Accept
                  if (trip?.isDriverAccept == 0 &&
                      trip?.isDriverAnotherTrip == 0)
                    Flexible(
                      child: CustomButton(
                        title: "accept".tr(),
                        onPressed: () {
                          if (trip?.isService == 1) {
                            cubit.updateTripStatus(
                              id: trip?.id ?? 0,
                              step: TripStep.isDriverAccept,
                              context: context,
                            );
                          } else {
                            warningDialog(
                              context,
                              title: "are_you_sure_you_want_to_accept_trip"
                                  .tr(),
                              onPressedOk: () {
                                cubit
                                    .updateTripStatus(
                                      id: trip?.id ?? 0,
                                      step: TripStep.isDriverAccept,
                                      context: context,
                                    )
                                    .then((_) {
                                      _navigateToPickup(context, trip);
                                    });
                              },
                            );
                          }
                        },
                      ),
                    ),
                  10.w.horizontalSpace,

                  // Start Trip / Start Service / Arrived
                  if (trip?.isDriverAccept == 1 &&
                      trip?.isDriverAnotherTrip == 0 &&
                      actionTitle.isNotEmpty) // ✅ الشرط الجديد
                    Flexible(
                      child: CustomButton(
                        title: actionTitle, // ✅ نستخدم المتغيّر
                        isDisabled: trip?.isUserAccept == 0,
                        onPressed: () {
                          _handleStartOrArrive(context, cubit, trip);
                        },
                      ),
                    ),

                  10.w.horizontalSpace,

                  if (trip?.status == 1 && trip?.isDriverAccept == 1)
                    Flexible(
                      child: CustomButton(
                        title: trip?.isService == 1
                            ? "end_service".tr()
                            : "end_trip".tr(),
                        btnColor: AppColors.red,
                        textColor: AppColors.white,
                        isDisabled:
                            trip?.isService == 0 && trip?.isUserStartTrip == 0,
                        onPressed: () {
                          trip?.isService == 1
                              ? cubit.endTrip(
                                  tripId: trip?.id ?? 0,
                                  context: context,
                                )
                              : cubit.endTrip(
                                  tripId: trip?.id ?? 0,
                                  context: context,
                                );
                        },
                      ),
                    ),
                  10.w.horizontalSpace,

                  // Reject
                  if (trip?.isDriverAnotherTrip == 0)
                    Flexible(
                      child: CustomButton(
                        title: "reject".tr(),
                        btnColor: AppColors.secondPrimary,
                        textColor: AppColors.primary,
                        onPressed: () {
                          warningDialog(
                            context,
                            title: "are_you_sure_you_want_to_decline_trip".tr(),
                            onPressedOk: () {
                              cubit.updateTripStatus(
                                id: trip?.id ?? 0,
                                step: TripStep.isDriverAnotherTrip,
                                context: context,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  10.w.horizontalSpace,

                  // Call & Message
                  CustomCallAndMessageWidget(
                    tripId: trip?.id.toString() ?? '',
                    driverId: trip?.driverId.toString(),
                    receiverId: trip?.userId.toString(),
                    isDriver: true,
                    roomToken: trip?.roomToken,
                    phoneNumber: trip?.user?.phone.toString(),
                  ),
                ],
              ),
              80.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  // String _getActionButtonTitle(DriverTripModel? trip) {
  //   if (trip == null) return '';
  //   if (trip.isService == 1 && trip.isDriverArrived == 0)
  //     return "start_service".tr();
  //   if (trip.isService == 0 && trip.isDriverArrived == 0) return "arrived".tr();
  //   if (trip.isDriverStartTrip == 0) return "start_trip".tr();
  //   return '';
  // }
  String _getActionButtonTitle(DriverTripModel? trip) {
    if (trip == null) return '';

    // ✅ SERVICE: زر بدء الخدمة يظهر فقط لو لسه ما بدأهاش
    if (trip.isService == 1) {
      if (trip.isDriverStartTrip == 0) return "start_service".tr();
      return ''; // ✅ بعد ما يبدأ الخدمة -> الزر يختفي
    }

    // ✅ TRIP: قبل الوصول -> وصلّت
    if (trip.isDriverArrived == 0) return "arrived".tr();

    // ✅ بعد الوصول ولسه ما بدأ الرحلة
    if (trip.isDriverStartTrip == 0) return "start_trip".tr();

    return '';
  }

  void _handleStartOrArrive(
    BuildContext context,
    DriverHomeCubit cubit,
    DriverTripModel? trip,
  ) {
    if (trip == null) return;

    log(
      "Action Button Pressed: tripId=${trip.id}, isService=${trip.isService}",
    );

    // ✅ Service: ابدأ الخدمة طالما لسه ما بدأهاش
    if (trip.isService == 1 && trip.isDriverStartTrip == 0) {
      cubit.startTrip(tripId: trip.id ?? 0, context: context);
      return;
    }

    if (trip.isService == 0 && trip.isDriverArrived == 0) {
      // زر وصلت → يحدث API وصول الكابتن
      cubit.updateTripStatus(
        id: trip.id ?? 0,
        step: TripStep.isDriverArrived,
        context: context,
      );
      return;
    }

    if (trip.isDriverStartTrip == 0) {
      cubit.startTrip(tripId: trip.id ?? 0, context: context).then((_) {
        _navigateToDropoff(context, trip);
      });
    }
  }

  void _navigateToPickup(BuildContext context, DriverTripModel? trip) {
    final lat = double.tryParse(trip?.fromLat ?? '');
    final lng = double.tryParse(trip?.fromLong ?? '');

    // ✅ هات driverId من trip
    final dId = trip?.driverId;
    if (dId == null) {
      log("Missing driverId in trip");
      return;
    }

    if (lat != null && lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationScreen(
            destination: ll.LatLng(lat, lng),
            mode: NavigationTargetMode.toPickup,
            driverId: dId, // ✅ مهم
            destinationName: trip?.from ?? "مكان العميل",
          ),
        ),
      );
    } else {
      log("Invalid pickup coords: ${trip?.fromLat}, ${trip?.fromLong}");
    }
  }

  void _navigateToDropoff(BuildContext context, DriverTripModel? trip) {
    final lat = double.tryParse(trip?.toLat ?? '');
    final lng = double.tryParse(trip?.toLong ?? '');

    // ✅ هات driverId من trip
    final dId = trip?.driverId;
    if (dId == null) {
      log("Missing driverId in trip");
      return;
    }

    if (lat != null && lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationScreen(
            destination: ll.LatLng(lat, lng),
            mode: NavigationTargetMode.toDropoff,
            driverId: dId, // ✅ هنا الحل
            destinationName: trip?.serviceToName ?? trip?.to ?? "الوجهة",
          ),
        ),
      );
    } else {
      log("Invalid dropoff coords: ${trip?.toLat}, ${trip?.toLong}");
    }
  }
}

class FromToContainer extends StatelessWidget {
  const FromToContainer({
    super.key,
    required this.isFrom,
    this.address,
    this.lat,
    this.lng,
    this.isService = false,
  });
  final bool isFrom;
  final String? address;
  final String? lat;
  final String? lng;
  final bool isService;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log('lat: $lat, lng: $lng');
        if (lat != null && lng != null) {
          context.read<LocationCubit>().openGoogleMapsRoute(
            double.tryParse(lat ?? '0') ?? 0,
            double.tryParse(lng ?? '0') ?? 0,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondPrimary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.all(12.sp),
        width: double.infinity,
        child: RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          text: TextSpan(
            children: [
              TextSpan(
                text: isFrom
                    ? '${'from'.tr()}: '
                    : isService
                    ? '${'service_to'.tr()}: '
                    : '${'to'.tr()}: ',
                style: getBoldStyle(fontSize: 16.sp, color: AppColors.primary),
              ),
              TextSpan(
                text: address ?? "",
                style: getMediumStyle(fontSize: 12.sp, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//   TripDistanceTimeRows

class TripDistanceTimeRows extends StatefulWidget {
  const TripDistanceTimeRows({super.key, required this.trip});

  final DriverTripModel? trip;

  @override
  State<TripDistanceTimeRows> createState() => _TripDistanceTimeRowsState();
}

class _TripDistanceTimeRowsState extends State<TripDistanceTimeRows> {
  Future<_DistanceDurationResult?>? _captainToPickupFuture;
  Future<_DistanceDurationResult?>? _tripFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepareFuturesIfNeeded();
  }

  @override
  void didUpdateWidget(covariant TripDistanceTimeRows oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldTrip = oldWidget.trip;
    final newTrip = widget.trip;

    // لو الإحداثيات/الحالة اتغيرت، جهّز futures من جديد
    final coordsChanged =
        oldTrip?.fromLat != newTrip?.fromLat ||
        oldTrip?.fromLong != newTrip?.fromLong ||
        oldTrip?.toLat != newTrip?.toLat ||
        oldTrip?.toLong != newTrip?.toLong ||
        oldTrip?.isDriverAccept != newTrip?.isDriverAccept ||
        oldTrip?.isDriverArrived != newTrip?.isDriverArrived;

    if (coordsChanged) {
      _captainToPickupFuture = null;
      _tripFuture = null;
      _prepareFuturesIfNeeded();
    }
  }

  void _prepareFuturesIfNeeded() {
    final trip = widget.trip;
    if (trip == null) return;

    final pickupLat = double.tryParse(trip.fromLat ?? '');
    final pickupLng = double.tryParse(trip.fromLong ?? '');
    final dropLat = double.tryParse(trip.toLat ?? '');
    final dropLng = double.tryParse(trip.toLong ?? '');

    final hasPickup = pickupLat != null && pickupLng != null;
    final hasDrop = dropLat != null && dropLng != null;

    // 1) Captain -> Pickup (بعد القبول وقبل الوصول)
    if (trip.isDriverAccept == 1 && trip.isDriverArrived == 0 && hasPickup) {
      _captainToPickupFuture ??= _buildCaptainToPickupFuture(
        pickupLat: pickupLat!,
        pickupLng: pickupLng!,
      );
    }

    // 2) Trip distance (بعد الوصول)
    if (trip.isDriverArrived == 1 && hasPickup && hasDrop) {
      _tripFuture ??= _buildTripFuture(
        fromLat: pickupLat!,
        fromLng: pickupLng!,
        toLat: dropLat!,
        toLng: dropLng!,
      );
    }
  }

  Future<_DistanceDurationResult?> _buildCaptainToPickupFuture({
    required double pickupLat,
    required double pickupLng,
  }) async {
    final pos = await Geolocator.getCurrentPosition();

    final km = await getRouteDistance(
      pos.latitude,
      pos.longitude,
      pickupLat,
      pickupLng,
    );

    if (km == null) return null;
    final minutes = ((km / 40) * 60).round();
    return _DistanceDurationResult(km: km, minutes: minutes);
  }

  Future<_DistanceDurationResult?> _buildTripFuture({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final km = await getRouteDistance(fromLat, fromLng, toLat, toLng);
    if (km == null) return null;
    final minutes = ((km / 40) * 60).round();
    return _DistanceDurationResult(km: km, minutes: minutes);
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    if (trip == null) return const SizedBox.shrink();

    final showCaptainRow =
        trip.isDriverAccept == 1 && trip.isDriverArrived == 0;
    final showTripRow = trip.isDriverArrived == 1;

    return Column(
      children: [
        if (showCaptainRow)
          FutureBuilder<_DistanceDurationResult?>(
            future: _captainToPickupFuture,
            builder: (context, snap) {
              final r = snap.data;
              return _DistanceTimeBox(km: r?.km, minutes: r?.minutes);
            },
          ),

        if (showTripRow)
          FutureBuilder<_DistanceDurationResult?>(
            future: _tripFuture,
            builder: (context, snap) {
              final r = snap.data;
              return _DistanceTimeBox(km: r?.km, minutes: r?.minutes);
            },
          ),
      ],
    );
  }
}

class _DistanceDurationResult {
  final double km;
  final int minutes;
  _DistanceDurationResult({required this.km, required this.minutes});
}

class _DistanceTimeBox extends StatelessWidget {
  const _DistanceTimeBox({required this.km, required this.minutes});

  final double? km;
  final int? minutes;

  @override
  Widget build(BuildContext context) {
    final distanceText = km == null ? "-- km" : "${km!.toStringAsFixed(1)} km";
    final durationText = minutes == null ? "-- min" : _formatMinutes(minutes!);

    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppColors.secondPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.directions_car, distanceText),
          _buildInfoItem(Icons.access_time, durationText),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.secondPrimary),
        5.w.horizontalSpace,
        Text(text, style: getBoldStyle(fontSize: 12.sp)),
      ],
    );
  }

  static String _formatMinutes(int estimatedMinutes) {
    if (estimatedMinutes >= 60) {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return "${hours}h ${minutes}m";
    }
    return "$estimatedMinutes min";
  }
}
