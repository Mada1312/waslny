import 'dart:developer';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/real-time/realtime_api.dart';
import 'package:waslny/core/real-time/realtime_service.dart';
import 'package:waslny/core/utils/general_enum.dart';
import 'package:waslny/features/user/add_new_trip/data/models/latest_model.dart';
import 'package:waslny/features/user/home/cubit/cubit.dart';
import 'package:waslny/features/user/trip_and_services/cubit/cubit.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import '../data/models/countries_and_types_model.dart';
import '../data/repo.dart';
import 'state.dart';

class AddNewTripCubit extends Cubit<AddNewTripState> {
  AddNewTripCubit(this.api) : super(AddNewTripInitState());

  AddNewTripRepo api;

  //!TRIP
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController toAddressController = TextEditingController();
  loc.LocationData? fromSelectedLocation;
  loc.LocationData? toSelectedLocation;
  double? distance;

  TimeType? selectedTimeType = TimeType.now;
  ServiceTo? selectedServiceTo = ServiceTo.electric;
  Gender? selectedGenderType = Gender.male;
  VehicleType? selectedVehicleType = VehicleType.car;
  //!TRIP

  TextEditingController selectedDateController = TextEditingController();
  TextEditingController selectedTimeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<GetCountriesAndTruckTypeModelData>? selectedCountriesAtEditProfile;

  // ✅ المتغيرات الجديدة للكباتن
  NearestCaptain? nearestCaptain;

  Future<void> selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat(
        'yyyy-MM-dd',
        'en',
      ).parse(selectedDateController.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      locale: const Locale('ar'),
      firstDate: DateTime.now(),
      lastDate: DateTime(50100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyLarge: getRegularStyle(),
              bodyMedium: getRegularStyle(),
              bodySmall: getRegularStyle(),
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.secondPrimary,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      selectedDateController.text = DateFormat(
        'yyyy-MM-dd',
        'en',
      ).format(pickedDate);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyLarge: getRegularStyle(),
              bodyMedium: getRegularStyle(),
              bodySmall: getRegularStyle(),
            ),
            colorScheme: ColorScheme.light(
              primary: AppColors.secondPrimary,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      selectedTime = pickedTime;
      selectedTimeController.text = pickedTime.format(context);
    }
  }

  // ✅ دالة حساب المسافة بأمان
  double? _calcDistanceKm() {
    final from = fromSelectedLocation;
    final to = toSelectedLocation;

    if (from?.latitude == null || from?.longitude == null) return null;
    if (to?.latitude == null || to?.longitude == null) return null;

    try {
      final meters = const Distance().as(
        LengthUnit.Meter,
        LatLng(from!.latitude!, from.longitude!),
        LatLng(to!.latitude!, to.longitude!),
      );

      // منع القيم الشاذة
      if (meters.isNaN || meters.isInfinite) return null;
      if (meters < 1) return 0.0; // أقل من متر = صفر

      final km = meters / 1000.0;
      // تقريب 2 رقم عشري
      return double.parse(km.toStringAsFixed(2));
    } catch (e) {
      log('❌ خطأ في حساب المسافة: $e');
      return null;
    }
  }

  Future<void> addNewTrip(
    BuildContext context, {
    bool isService = false,
  }) async {
    try {
      // 1️⃣ فحص نقطة الانطلاق
      if (fromSelectedLocation?.latitude == null ||
          fromSelectedLocation?.longitude == null) {
        errorGetBar('حدد نقطة الانطلاق أولاً');
        return;
      }

      // 2️⃣ فحص المسافة للرحلات العادية
      if (!isService) {
        if (toSelectedLocation?.latitude == null ||
            toSelectedLocation?.longitude == null) {
          errorGetBar('حدد نقطة الوصول أولاً');
          return;
        }

        final km = _calcDistanceKm();
        if (km == null || km == 0) {
          errorGetBar('المسافة غير صحيحة، راجع نقط البداية والنهاية');
          return;
        }
        distance = km;
        log('📏 المسافة المحسوبة (from-to): $distance كم');
      }

      // 3️⃣ البحث عن أقرب كابتن
      AppWidget.createProgressDialog(context, msg: 'جاري البحث عن كباتن...');
      emit(SearchingNearestCaptainState());

      final realtimeService = RealtimeService();
      final result = await realtimeService.getNearestCaptain(
        lat: fromSelectedLocation!.latitude!,
        lng: fromSelectedLocation!.longitude!,
        radiusMeters: 10000,
      );
      realtimeService.dispose();

      Navigator.pop(context);

      if (result == null || !result.isOnline) {
        errorGetBar('❌ لا يوجد كابتن متاح في نطاق 10 كم');
        emit(NoCaptainAvailableState());
        return;
      }

      // 4️⃣ حساب مسافة القيادة
      AppWidget.createProgressDialog(
        context,
        msg: 'جاري حساب مسافة القيادة...',
      );

      final locationCubit = context.read<LocationCubit>();

      final userLat = fromSelectedLocation!.latitude!;
      final userLng = fromSelectedLocation!.longitude!;
      final captainLat = result.latitude;
      final captainLng = result.longitude;

      final from = LatLng(userLat, userLng);
      final to = LatLng(captainLat, captainLng);

      await locationCubit.getRouteBetweenLocations(from, to);

      final double drivingKm = locationCubit.getRouteDistanceInKilometers();
      final int drivingMinutes = locationCubit.getRouteDurationInMinutes();

      Navigator.pop(context);

      log(
        '🚗 مسافة القيادة: ${drivingKm.toStringAsFixed(1)} كم، $drivingMinutes دقيقة',
      );

      const maxDrivingKm = 10.0;

      if (drivingKm > maxDrivingKm) {
        errorGetBar(
          '❌ الكابتن بعيد بالقيادة\n'
          '📏 ${drivingKm.toStringAsFixed(1)} كم، $drivingMinutes دقيقة',
        );
        emit(NoCaptainAvailableState());
        return;
      }

      // 5️⃣ الكابتن صالح
      nearestCaptain = result;
      emit(NearestCaptainFound(nearestCaptain!));

      // 6️⃣ إرسال الطلب
      AppWidget.createProgressDialog(
        context,
        msg: 'جاري طلب الرحلة من ${result.name}...',
      );
      emit(AddNewTripLoading());

      final res = await api.addNewTrip(
        distance: distance,
        description: descriptionController.text,
        from: fromAddressController.text,
        to: toAddressController.text,
        gender: selectedGenderType?.name == Gender.male.name ? '0' : '1',
        isSchedule: selectedTimeType?.name == TimeType.later.name,
        isService: isService,
        serviceTo: selectedServiceTo?.id.toString(),
        scheduleTime: selectedTimeType?.name == TimeType.later.name
            ? DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(
                DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                ),
              )
            : null,
        vehicleType: selectedVehicleType?.name == VehicleType.car.name
            ? 'car'
            : 'scooter',
        toLat: toSelectedLocation?.latitude,
        toLong: toSelectedLocation?.longitude,
        fromLat: fromSelectedLocation?.latitude,
        fromLong: fromSelectedLocation?.longitude,
      );

      Navigator.pop(context);

      res.fold(
        (l) {
          errorGetBar('❌ خطأ في الطلب: $l');
          emit(AddNewTripError());
        },
        (r) {
          if (r.status == 200 || r.status == 201) {
            successGetBar('✅ تم طلب الرحلة بنجاح من ${nearestCaptain!.name}');
            clearTripData();
            emit(AddNewTripLoaded());
            context.read<UserHomeCubit>().getHome(context);

            // ✅ التحويل للصفحة الرئيسية بعد إنشاء الرحلة
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.mainRoute,
              (route) => false,
              arguments: false,
            );
          } else {
            errorGetBar('❌ ${r.msg}');
            emit(AddNewTripError());
          }
        },
      );
    } catch (e) {
      log('❌ خطأ في الطلب: $e');
      try {
        Navigator.pop(context);
      } catch (_) {}
      errorGetBar('خطأ في الطلب: $e');
      emit(AddNewTripError());
    }
  }

  void clearTripData() {
    descriptionController.clear();
    fromAddressController.clear();
    selectedTimeController.clear();
    toAddressController.clear();
    selectedGenderType = Gender.male;
    selectedTimeType = TimeType.now;
    selectedVehicleType = VehicleType.car;
    selectedServiceTo = ServiceTo.electric;
    toSelectedLocation = null;
    fromSelectedLocation = null;
    selectedDate = null;
    selectedTime = null;
    distance = null;
    nearestCaptain = null;
    selectedDateController.clear();
    log('🧹 تم تنظيف بيانات الرحلة');
  }

  GetMainLastestLocation? latestLocation;

  Future<void> gettMainLastestLocation(bool isService) async {
    try {
      emit(LoadingGetLatestLocation());
      final res = await api.gettMainLastestLocation(isService);
      res.fold(
        (l) {
          errorGetBar(l.toString());
          emit(ErrorGetLatestLocation());
        },
        (r) {
          if (r.status == 200 || r.status == 201) {
            latestLocation = r;
            emit(LoadedGetLatestLocation());
          } else {
            errorGetBar(r.msg.toString());
            emit(ErrorGetLatestLocation());
          }
        },
      );
    } catch (e) {
      log('❌ خطأ في جلب آخر موقع: $e');
      errorGetBar(e.toString());
      emit(ErrorGetLatestLocation());
    }
  }

  void setSelectedLocationToFields(GetMainLastestLocationData item) {
    if (item.isService == 1) {
      fromAddressController.text = item.from ?? '';
      fromSelectedLocation = loc.LocationData.fromMap({
        "latitude": double.tryParse(item.fromLat ?? '0.0') ?? 0.0,
        "longitude": double.tryParse(item.fromLong ?? '0.0') ?? 0.0,
      });
      for (var i in ServiceTo.values) {
        if (i.id == item.serviceTo) {
          selectedServiceTo = i;
        }
      }
      log('✅ تم تعيين خدمة: ${selectedServiceTo?.name}');
    } else {
      fromAddressController.text = item.from ?? '';
      toAddressController.text = item.to ?? '';
      fromSelectedLocation = loc.LocationData.fromMap({
        "latitude": double.tryParse(item.fromLat ?? '0.0') ?? 0.0,
        "longitude": double.tryParse(item.fromLong ?? '0.0') ?? 0.0,
      });

      toSelectedLocation = loc.LocationData.fromMap({
        "latitude": double.tryParse(item.toLat ?? '0.0') ?? 0.0,
        "longitude": double.tryParse(item.toLong ?? '0.0') ?? 0.0,
      });

      // حساب المسافة بأمان
      final km = _calcDistanceKm();
      if (km != null) {
        distance = km;
        log('✅ المسافة من آخر رحلة: $distance كم');
      }
    }

    emit(SuccessSelectedLocationToFields());
  }

  // ✅ دالة تحديث الموقع من البحث
  void updateLocationFromSearch({
    required bool isFromField,
    required String searchName,
    required double lat,
    required double lng,
  }) {
    if (isFromField) {
      fromAddressController.text = searchName;
      fromSelectedLocation = loc.LocationData.fromMap({
        "latitude": lat,
        "longitude": lng,
      });
      log('📍 تم تحديث نقطة الانطلاق: $searchName');
    } else {
      toAddressController.text = searchName;
      toSelectedLocation = loc.LocationData.fromMap({
        "latitude": lat,
        "longitude": lng,
      });
      log('📍 تم تحديث نقطة الوصول: $searchName');
    }

    // حساب المسافة بأمان
    final km = _calcDistanceKm();
    if (km != null) {
      distance = km;
      log('📏 المسافة المحسوبة: $distance كم');
    }

    emit(SuccessSelectedLocationToFields());
  }

  @override
  Future<void> close() {
    fromAddressController.dispose();
    toAddressController.dispose();
    selectedDateController.dispose();
    selectedTimeController.dispose();
    descriptionController.dispose();
    log('🧹 تم تنظيف موارد AddNewTripCubit');
    return super.close();
  }
}
