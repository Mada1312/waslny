import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/utils/get_route_distance.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/price/pricing_engine.dart';

class CustomFromToWidget extends StatefulWidget {
  const CustomFromToWidget({
    super.key,
    this.from,
    this.to,
    this.fromLat,
    this.fromLng,
    this.toLat,
    this.toLng,
    this.serviceTo,
    required this.isDriverAccepted,
    required this.isDriverArrived,
  });

  final String? from;
  final String? to;
  final String? fromLat;
  final String? fromLng;
  final String? toLat;
  final String? toLng;
  final String? serviceTo;
  final bool isDriverAccepted;
  final bool isDriverArrived;

  @override
  State<CustomFromToWidget> createState() => _CustomFromToWidgetState();
}

class _CustomFromToWidgetState extends State<CustomFromToWidget> {
  bool _routeRequested = false;
  late EtaCountdownController etaController;
  bool etaStarted = false;

  @override
  void initState() {
    super.initState();
    etaController = EtaCountdownController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestRouteIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CustomFromToWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isDriverAccepted && !etaStarted) {
      etaStarted = true;
      startEtaCountdown();
    }

    if (widget.isDriverArrived && etaController.isActive) {
      etaController.stop();
      setState(() {});
    }
  }

  void _requestRouteIfNeeded() {
    if (!_routeRequested &&
        widget.fromLat != null &&
        widget.fromLng != null &&
        widget.toLat != null &&
        widget.toLng != null &&
        widget.serviceTo == null) {
      _routeRequested = true;

      final cubit = context.read<LocationCubit>();
      cubit.getRouteBetweenLocations(
        LatLng(double.parse(widget.fromLat!), double.parse(widget.fromLng!)),
        LatLng(double.parse(widget.toLat!), double.parse(widget.toLng!)),
      );
    }
  }

  void startEtaCountdown() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final clientLat = position.latitude;
      final clientLng = position.longitude;
      final pickupLat = double.tryParse(widget.fromLat ?? '0') ?? 0;
      final pickupLng = double.tryParse(widget.fromLng ?? '0') ?? 0;

      final distanceKm = await getRouteDistance(
        clientLat,
        clientLng,
        pickupLat,
        pickupLng,
      );
      final estimatedMinutes = ((distanceKm ?? 0) / 40 * 60).round();

      etaController.start(estimatedMinutes, () {
        if (mounted) setState(() {});
      });
    } catch (e) {
      print("Error starting ETA countdown: $e");
    }
  }

  @override
  void dispose() {
    etaController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // From
        IntrinsicHeight(
          child: Row(
            children: [
              _buildLocationIconColumn(AppIcons.from),
              10.w.horizontalSpace,
              _buildLocationText(
                "from".tr(),
                widget.from,
                widget.fromLat,
                widget.fromLng,
              ),
            ],
          ),
        ),
        // To
        Row(
          children: [
            MySvgWidget(path: AppIcons.to, width: 25.sp, height: 30.sp),
            10.w.horizontalSpace,
            _buildLocationText(
              widget.serviceTo != null ? "service_to".tr() : "to".tr(),
              widget.serviceTo ?? widget.to,
              widget.toLat,
              widget.toLng,
            ),
          ],
        ),
        // مسافة / وقت / سعر
        _buildRouteInfo(),
        // ETA row
        if (etaController.isActive)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.secondPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 16.sp, color: AppColors.secondPrimary),
                5.w.horizontalSpace,
                Text(
                  "ETA: ${etaController.formatted()}",
                  style: getBoldStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLocationIconColumn(String icon) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 3.sp),
      child: Column(
        children: [
          MySvgWidget(path: icon, height: 20.sp, width: 20.sp),
          5.h.verticalSpace,
          Expanded(
            child: Column(
              children: List.generate(
                5,
                (index) => Expanded(
                  child: Container(width: 2.w, color: AppColors.secondPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationText(
    String label,
    String? address,
    String? lat,
    String? lng,
  ) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          if (lat != null && lng != null) {
            context.read<LocationCubit>().openGoogleMapsRoute(
              double.tryParse(lat) ?? 0,
              double.tryParse(lng) ?? 0,
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: getMediumStyle(fontSize: 14.sp)),
            Text(
              address?.isEmpty ?? true ? "Loading...".tr() : address!,
              maxLines: 2,
              style: getRegularStyle(fontSize: 13.sp, color: Colors.blue),
            ),
            10.h.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    if (widget.fromLat == null ||
        widget.fromLng == null ||
        widget.toLat == null ||
        widget.toLng == null) {
      return const SizedBox.shrink();
    }

    final fromLat = double.tryParse(widget.fromLat!) ?? 0;
    final fromLng = double.tryParse(widget.fromLng!) ?? 0;
    final toLat = double.tryParse(widget.toLat!) ?? 0;
    final toLng = double.tryParse(widget.toLng!) ?? 0;

    return FutureBuilder<double?>(
      future: getRouteDistance(fromLat, fromLng, toLat, toLng),
      builder: (context, snapshot) {
        String distanceText = "-- km";
        String durationText = "-- min";
        String priceText = "--";

        if (snapshot.hasData && snapshot.data != null) {
          final distanceKm = snapshot.data!;
          distanceText = "${distanceKm.toStringAsFixed(1)} km";

          final estimatedMinutes = (distanceKm / 40 * 60).round();
          if (estimatedMinutes >= 60) {
            final hours = estimatedMinutes ~/ 60;
            final minutes = estimatedMinutes % 60;
            durationText = "${hours}h ${minutes}m";
          } else {
            durationText = "$estimatedMinutes min";
          }

          final isFemaleDriver = false;
          final tripPrice = PricingEngine.calculateTripPrice(
            distanceKm: distanceKm,
            isFemaleDriver: isFemaleDriver,
          );
          priceText = "${tripPrice.toStringAsFixed(1)}";
        }

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
              _buildInfoItem(Icons.monetization_on, priceText),
              _buildInfoItem(Icons.directions_car, distanceText),
              _buildInfoItem(Icons.access_time, durationText),
            ],
          ),
        );
      },
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
}

class EtaCountdownController {
  Timer? _timer;
  int remainingSeconds = 0;
  VoidCallback onUpdate = () {};

  void start(int minutes, VoidCallback onUpdateCallback) {
    _timer?.cancel();
    remainingSeconds = minutes * 60;
    onUpdate = onUpdateCallback;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        try {
          if (onUpdate != null) onUpdate();
        } catch (_) {}
      } else {
        _timer?.cancel();
        _timer = null;
        remainingSeconds = 0;
        try {
          if (onUpdate != null) onUpdate();
        } catch (_) {}
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null; // ✅ اجعل الـ timer null
    remainingSeconds = 0;
    onUpdate = () {}; // ✅ اجعل callback فارغ بعد الإيقاف
  }

  String formatted() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  bool get isActive => remainingSeconds > 0;
}
