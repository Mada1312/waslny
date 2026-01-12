// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/core/notification_services/service/local_notification_service.dart';
import 'package:waslny/core/preferences/preferences.dart';
import 'package:waslny/core/real-time/realtime_api.dart';
import 'package:waslny/features/driver/home/data/models/driver_home_model.dart';
import 'package:waslny/features/general/chat/cubit/chat_cubit.dart';
import 'package:waslny/features/general/location/cubit/location_cubit.dart';
import 'package:waslny/features/general/price/pricing_widget.dart';
import 'package:waslny/features/main/screens/main_screen.dart';

import '../data/repo.dart';
import 'state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit(this.api) : super(DriverHomeInitial());

  final DriverHomeRepo api;
  bool isDataVerifided = false;
  GetDriverHomeModel? homeModel;
  bool isLoggedOut = false;

  // ================== Polling Timer (للـ Trips فقط) ==================
  Timer? _idlePollingTimer;
  static const Duration _idlePollingInterval = Duration(seconds: 5);

  // ================== Location Timer (مستقل 100%) ==================
  Timer? _locationTimer;
  static const Duration _locationInterval = Duration(seconds: 10);

  // ✅ سيرفر الـ Realtime الجديد
  final RealtimeApiClient _realtimeClient = RealtimeApiClient(
    baseUrl: 'https://realtime.baraddy.com',
  );

  RealtimeApiClient get realtimeClient => _realtimeClient;

  // ✅ LocationCubit reference (تخزين مرة واحدة)
  LocationCubit? _locationCubit;

  String? _captainInternalId; // UUID من Register

  Future<void> getDriverHomeData(
    BuildContext context, {
    bool? isVerify = false,
  }) async {
    if (isLoggedOut) return;

    emit(DriverHomeLoading());
    try {
      final result = await api.getHome();

      if (isLoggedOut) return;

      result.fold((failure) => emit(DriverHomeError()), (data) async {
        if (data.status != 200 && data.status != 201) {
          emit(DriverHomeError());
          return;
        }
        homeModel = data;
        log('6666666666666 ${data.data?.isWebhookVerified}');

        isDataVerifided = homeModel?.data?.user?.isVerified == 1;
        if (homeModel?.data?.user?.isDataUploaded != 1) {
          Navigator.pushNamed(context, Routes.driverDataRoute);
        } else if (homeModel?.data?.user?.isVerified != 1) {
          completeDialog(
            context,
            btnOkText: 'done'.tr(),
            title: 'reviewing_data'.tr(),
            onPressedOk: () async {
              bool shouldExit = await showExitDialog(context);
              log("shouldExit: $shouldExit");
              if (shouldExit) {
                SystemNavigator.pop();
              }
            },
          );
        }

        emit(DriverHomeLoaded());

        // ✅ إذا السواق Online: بدء Realtime
        if (homeModel?.data?.user?.isActive == 1) {
          log('📌 Driver already Online from start - initializing Realtime');
          _registerRealtimeCaptain(context);
          _startLocationTracking(context);
          _startIdlePolling();
        }
      });
    } catch (e) {
      log("Error in getDriverHomeData: $e");
      emit(DriverHomeError());
    }
  }

  // ================== POLLING (Trips فقط) ==================
  void _startIdlePolling() {
    if (isLoggedOut || homeModel?.data?.user?.isActive != 1) {
      log('⏹️ Polling not started: Driver offline');
      _stopIdlePolling();
      return;
    }

    if (_idlePollingTimer != null) {
      log('✅ Polling already running');
      return;
    }

    log('🔄 Starting Polling Timer... (Trips only)');

    _idlePollingTimer = Timer.periodic(_idlePollingInterval, (_) async {
      if (isLoggedOut || homeModel?.data?.user?.isActive != 1) {
        _stopIdlePolling();
        return;
      }

      try {
        final result = await api.getHome();
        if (isLoggedOut) {
          _stopIdlePolling();
          return;
        }

        result.fold((failure) => log("⚠️ Polling error"), (data) {
          try {
            if (_isSameTripData(
              homeModel?.data?.currentTrip,
              data.data?.currentTrip,
            )) {
              return;
            }

            _detectTripChangesAndNotify(
              homeModel?.data?.currentTrip,
              data.data?.currentTrip,
            );

            homeModel = data;
            emit(DriverHomeLoaded());
            log('✅ Trip Updated: ${data.data?.currentTrip?.id ?? "none"}');
          } catch (e) {
            log('⚠️ Polling error: $e');
            homeModel = data;
            emit(DriverHomeLoaded());
          }
        });
      } catch (e) {
        log("❌ Polling error: $e");
      }
    });
  }

  void _stopIdlePolling() {
    _idlePollingTimer?.cancel();
    _idlePollingTimer = null;
    log('⏹️ Polling stopped');
  }

  // ================== REALTIME REGISTER (مرة واحدة) ==================
  Future<void> _registerRealtimeCaptain(BuildContext context) async {
    // 🛡️ Guard: منع تكرار التسجيل
    if (_captainInternalId != null || isLoggedOut) return;

    try {
      // ✅ استخدم Preferences.instance بدل SharedPreferences
      final userData = await Preferences.instance.getUserModel();

      // استخرج البيانات من LoginModel
      final phone = userData.data?.phone;
      final name = userData.data?.name ?? 'Captain';
      final driverId = userData.data?.id ?? 0;

      log(
        '🧪 Realtime guard check | '
        'internalId=$_captainInternalId '
        'phone=$phone '
        'driverId=$driverId',
      );

      // ✅ تحقق من المتطلبات الأساسية
      if (phone == null || phone.isEmpty || driverId == 0) {
        log('❌ Register FAILED: Missing phone=$phone or driverId=$driverId');

        // 🔄 Retry بعد 2 ثانية إذا البيانات مش جاهزة
        Future.delayed(const Duration(seconds: 2), () {
          if (!isLoggedOut) _registerRealtimeCaptain(context);
        });
        return;
      }

      log('📡 Registering Realtime... ID: $driverId, Phone: $phone');

      final regResult = await _realtimeClient.registerCaptain(
        driverId: driverId,
        phone: phone,
        name: name,
        vehicleType: 'car',
      );

      if (regResult.internalId != null && regResult.internalId!.isNotEmpty) {
        _captainInternalId = regResult.internalId;
        log('✅ Realtime REGISTERED: $_captainInternalId');

        // ✅ بمجرد التسجيل الناجح: بدء Location وPolling إذا السائق Online
        if (homeModel?.data?.user?.isActive == 1) {
          _startLocationTracking(context);
          _startIdlePolling();
        }
      } else {
        log('⚠️ Register returned null internalId');
      }
    } catch (e) {
      log('❌ Register ERROR: $e');
    }
  }

  // ================== LOCATION TIMER (مستقل 100%) ==================
  void _startLocationTracking(BuildContext context) {
    // 🛡️ Guard: منع التشغيل المزدوج
    _stopLocationTracking();

    // 🛡️ Guard: تأكد من الشروط
    if (_captainInternalId == null ||
        isLoggedOut ||
        homeModel?.data?.user?.isActive != 1) {
      log(
        '⚠️ Location tracking BLOCKED: '
        'internalId=$_captainInternalId '
        'loggedOut=$isLoggedOut '
        'active=${homeModel?.data?.user?.isActive}',
      );
      return;
    }

    // ✅ تخزين LocationCubit reference مرة واحدة
    _locationCubit = context.read<LocationCubit>();

    log(
      '🛰️ Starting Location Timer (10s interval) with internalId=$_captainInternalId',
    );

    _locationTimer = Timer.periodic(_locationInterval, (_) async {
      if (isLoggedOut ||
          homeModel?.data?.user?.isActive != 1 ||
          _captainInternalId == null ||
          _locationCubit == null) {
        _stopLocationTracking();
        return;
      }

      final location = _locationCubit!.currentLocation;
      if (location == null) {
        log('⚠️ Location is null');
        return;
      }

      // تجاهل القراءات غير الدقيقة
      if (location.accuracy != null && location.accuracy! > 50) {
        log('⚠️ Accuracy too low: ${location.accuracy}');
        return;
      }

      try {
        await _realtimeClient.updateCaptainLocation(
          captainInternalId: _captainInternalId!,
          latitude: location.latitude!,
          longitude: location.longitude!,
          accuracy: location.accuracy ?? 0.0,
          heading: location.heading ?? 0.0,
          speed: location.speed ?? 0.0,
        );
        log(
          '📍 Location sent: Lat=${location.latitude}, Long=${location.longitude}',
        );
      } catch (e) {
        log('❌ Location update failed: $e');
      }
    });
  }

  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _locationCubit = null;
    log('⏹️ Location Timer stopped');
  }

  // ================== تغيير حالة الاتصال ==================
  Future<void> changeActiveStatus(BuildContext context) async {
    if (isLoggedOut) return;

    emit(LoadingChangeOnlineStatusState());
    final res = await api.toggleActive();

    if (isLoggedOut) return;

    res.fold(
      (l) {
        log(l.toString());
        emit(ErrorChangeOnlineStatusState());
      },
      (s) async {
        if (s.status == 200) {
          homeModel?.data?.user?.isActive =
              (homeModel?.data?.user?.isActive == 1) ? 0 : 1;

          successGetBar(s.msg);
          emit(ChangeOnlineStatusState());

          if (homeModel?.data?.user?.isActive == 1) {
            LocalNotificationService.showSuccessNotification(' انت متصل الان');
            log('✅ Driver is now ONLINE');

            // ✅ سجل في السيرفر الجديد (مرة واحدة)
            await _registerRealtimeCaptain(context);

            // ✅ ابدأ إرسال الموقع كل 10 ثوانى
            _startLocationTracking(context);

            // ✅ ابدأ polling للـ Trips كل 5 ثوانى
            _startIdlePolling();
          } else {
            LocalNotificationService.showErrorNotification('انت غير متصل');
            log('🔴 Driver went OFFLINE - stopping all services');

            // ✅ تصفير _captainInternalId لـ clean registration
            _captainInternalId = null;
            _stopIdlePolling();
            _stopLocationTracking();
          }

          getDriverHomeDataSilent();
        } else {
          emit(ErrorChangeOnlineStatusState());
        }
      },
    );
  }

  // ================== Trip Notifications ==================
  void _detectTripChangesAndNotify(
    DriverTripModel? oldTrip,
    DriverTripModel? newTrip,
  ) {
    if (isLoggedOut) return;

    if (oldTrip == null && newTrip != null) {
      log('🚗 NEW TRIP: ${newTrip.id}');
      LocalNotificationService.showNewTripNotification(
        tripId: newTrip.id.toString(),
        captainName: 'لديك رحلة جديدة',
      );
    } else if (oldTrip != null && newTrip == null) {
      log('✅ TRIP ENDED: ${oldTrip.id}');
      LocalNotificationService.showSuccessNotification('تم انهاء الرحلة ✅');
    } else if (oldTrip != null && newTrip != null) {
      if (oldTrip.status != newTrip.status) {
        _handleTripStatusChange(oldTrip, newTrip);
      }

      if (oldTrip.isDriverArrived != newTrip.isDriverArrived &&
          newTrip.isDriverArrived == 1) {
        LocalNotificationService.showCaptainArrivedNotification(
          captainName: newTrip.type ?? 'الكابتن',
        );
      }

      if (oldTrip.isUserAccept != newTrip.isUserAccept &&
          newTrip.isUserAccept == 1) {
        LocalNotificationService.showSuccessNotification('تم قبول الرحلة ✅');
      }

      if (oldTrip.isDriverStartTrip != newTrip.isDriverStartTrip &&
          newTrip.isDriverStartTrip == 1) {
        LocalNotificationService.showSuccessNotification('تم بدء الرحلة 🚗');
      }

      if (oldTrip.isUserStartTrip != newTrip.isUserStartTrip &&
          newTrip.isUserStartTrip == 1) {
        LocalNotificationService.showSuccessNotification(
          'العميل بدء الرحلة 🚀',
        );
      }

      if (oldTrip.isUserChangeCaptain != newTrip.isUserChangeCaptain &&
          newTrip.isUserChangeCaptain == 1) {
        LocalNotificationService.showErrorNotification('المستخدم غيّر السائق');
      }

      if (oldTrip.isDriverAnotherTrip != newTrip.isDriverAnotherTrip &&
          newTrip.isDriverAnotherTrip == 1) {
        LocalNotificationService.showSuccessNotification('لديك رحلة أخرى 📌');
      }
    }
  }

  void _handleTripStatusChange(
    DriverTripModel oldTrip,
    DriverTripModel newTrip,
  ) {
    final statusName = newTrip.statusName ?? '';

    if (statusName.contains('pending') || statusName.contains('جديدة')) {
      LocalNotificationService.showNewTripNotification(
        tripId: newTrip.id.toString(),
        captainName: 'لديك رحلة جديدة',
      );
    } else if (statusName.contains('accepted') ||
        statusName.contains('مقبولة')) {
      LocalNotificationService.showSuccessNotification('تم قبول الرحلة ✅');
    } else if (statusName.contains('in progress') ||
        statusName.contains('قيد التنفيذ')) {
      LocalNotificationService.showSuccessNotification('الرحلة قيد التنفيذ 🚗');
    } else if (statusName.contains('completed') ||
        statusName.contains('مكتملة')) {
      LocalNotificationService.showSuccessNotification('تم انهاء الرحلة ✨');
    } else if (statusName.contains('cancelled') ||
        statusName.contains('ملغاة')) {
      LocalNotificationService.showErrorNotification('تم إلغاء الرحلة ❌');
    }
  }

  bool _isSameTripData(DriverTripModel? oldTrip, DriverTripModel? newTrip) {
    if (oldTrip == null && newTrip == null) return true;
    if (oldTrip == null || newTrip == null) return false;

    try {
      return oldTrip.id == newTrip.id &&
          oldTrip.status == newTrip.status &&
          oldTrip.statusName == newTrip.statusName &&
          oldTrip.isDriverArrived == newTrip.isDriverArrived &&
          oldTrip.isUserStartTrip == newTrip.isUserStartTrip &&
          oldTrip.isDriverStartTrip == newTrip.isDriverStartTrip &&
          oldTrip.isUserAccept == newTrip.isUserAccept &&
          oldTrip.isDriverAccept == newTrip.isDriverAccept &&
          oldTrip.isUserChangeCaptain == newTrip.isUserChangeCaptain &&
          oldTrip.isDriverAnotherTrip == newTrip.isDriverAnotherTrip;
    } catch (e) {
      log('❌ Error comparing trips: $e');
      return false;
    }
  }

  // ================== Global Stop ==================
  void stopPolling() {
    isLoggedOut = true;
    _captainInternalId = null;
    _stopIdlePolling();
    _stopLocationTracking();
    log('🚫 Global stop: All services cleared');
  }

  Future<void> getDriverHomeDataSilent() async {
    if (isLoggedOut) return;
    try {
      final result = await api.getHome();
      if (isLoggedOut) return;
      result.fold((failure) {}, (data) {
        if (data.status == 200 || data.status == 201) {
          homeModel = data;
          emit(DriverHomeLoaded());
        }
      });
    } catch (e) {
      log("Silent error: $e");
    }
  }

  // ================== Trip Actions ==================
  Future<void> startTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    if (isLoggedOut) return;
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.startTrip(id: tripId);
      if (isLoggedOut) return;
      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            LocalNotificationService.showSuccessNotification(
              'تم بدء الرحلة 🚗',
            );
            _stopIdlePolling();
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to start trip");
          }
        },
      );
    } catch (e) {
      log("Error in startTrip: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  Future<void> endTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    if (isLoggedOut) return;

    final trip = homeModel?.data?.currentTrip;
    if (trip == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PricingDialog(
        trip: trip,
        isFemaleDriver: homeModel?.data?.user?.userType == '2',
        onConfirm: () async {
          Navigator.pop(context);
          await _executeEndTripApi(tripId: tripId, context: context);
        },
      ),
    );
  }

  Future<void> _executeEndTripApi({
    required int tripId,
    required BuildContext context,
  }) async {
    if (isLoggedOut) return;

    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());

    try {
      final response = await api.endTrip(id: tripId);

      if (isLoggedOut) return;

      Navigator.pop(context);

      response.fold(
        (failure) {
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());

            LocalNotificationService.showSuccessNotification(
              'تم انهاء الرحلة ✅',
            );

            _stopIdlePolling();

            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);

            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to end trip");
          }
        },
      );
    } catch (e) {
      log("Error in endTrip: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  Future<void> cancleTrip({
    required int tripId,
    required BuildContext context,
  }) async {
    if (isLoggedOut) return;

    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.cancleTrip(id: tripId);

      if (isLoggedOut) return;

      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());
            LocalNotificationService.showErrorNotification('تم إلغاء الرحلة ❌');
            Navigator.pushNamed(context, Routes.mainRoute, arguments: true);
            _stopIdlePolling();
            getDriverHomeData(context);
          } else {
            errorGetBar(response.msg ?? "Failed to cancel trip");
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  Future<void> updateTripStatus({
    required TripStep step,
    required int id,
    required BuildContext context,
    String? receiverId,
    String? chatId,
  }) async {
    if (isLoggedOut) return;

    if (step == TripStep.isDriverArrived) {
      if (context.read<LocationCubit>().currentLocation == null) {
        await context.read<LocationCubit>().checkAndRequestLocationPermission(
          context,
        );
      }
      if (context.read<LocationCubit>().currentLocation == null) {
        errorGetBar("location_required".tr());
        return;
      }
    }
    AppWidget.createProgressDialog(context, msg: "...");
    emit(UpdateTripStatusLoadingState());
    try {
      final response = await api.updateTripStatus(
        id: id,
        step: step,
        arrivalLat: step != TripStep.isDriverArrived
            ? null
            : context.read<LocationCubit>().currentLocation?.latitude,
        arrivalLong: step != TripStep.isDriverArrived
            ? null
            : context.read<LocationCubit>().currentLocation?.longitude,
      );

      if (isLoggedOut) return;

      response.fold(
        (failure) {
          Navigator.pop(context);
          emit(UpdateTripStatusErrorState());
        },
        (response) {
          Navigator.pop(context);
          if (response.status == 200 || response.status == 201) {
            emit(UpdateTripStatusSuccessState());

            if (step == TripStep.isDriverStartTrip) {
              LocalNotificationService.showSuccessNotification(
                'بدأت الرحلة 🚗',
              );
            } else if (step == TripStep.isDriverAccept) {
              LocalNotificationService.showSuccessNotification(
                'تم قبول الرحلة ✅',
              );
            }

            _stopIdlePolling();
            getDriverHomeData(context);

            if (step == TripStep.isDriverArrived) {
              context.read<ChatCubit>().sendMessage(
                isDriverArrived: true,
                chatId: chatId ?? "",
                receiverId: receiverId,
              );
            }
          } else {
            errorGetBar(response.msg ?? "Failed to cancel trip");
          }
        },
      );
    } catch (e) {
      log("Error in cancelShipment: $e");
      emit(UpdateTripStatusErrorState());
    }
  }

  // ================== Driver Data / Images ==================
  int selectedStep = 1;

  changeSelectedStep(int index) {
    selectedStep = index;
    emit(ChangeSelectedIndexState());
  }

  File? vehicleInfoFrontImage;
  File? vehicleInfoBackImage;
  File? driverLicenseImage;
  File? idCardFrontImage;
  File? idCardBackImage;
  File? personalPhotoImage;

  void setImageFile(DriverDataImages imageType, File imageFile) {
    switch (imageType) {
      case DriverDataImages.vehicleInfoFront:
        vehicleInfoFrontImage = imageFile;
        break;
      case DriverDataImages.vehicleInfoBack:
        vehicleInfoBackImage = imageFile;
        break;
      case DriverDataImages.driverLicense:
        driverLicenseImage = imageFile;
        break;
      case DriverDataImages.idCardFront:
        idCardFrontImage = imageFile;
        break;
      case DriverDataImages.idCardBack:
        idCardBackImage = imageFile;
        break;
      case DriverDataImages.personalPhoto:
        personalPhotoImage = imageFile;
        break;
    }
    emit(ImageFileUpdatedState());
  }

  showCameraOrImagePicker(BuildContext context, DriverDataImages imageType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('gallery'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(imageType, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('camera'.tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(imageType, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> compressImage(String path, {int quality = 70}) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.absolute.path}/COMPRESSED_${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final compressedResult = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (compressedResult != null) {
        debugPrint('Original Size: ${await File(path).length()} bytes');
        debugPrint('Compressed Size: ${await compressedResult.length()} bytes');
        return File(compressedResult.path);
      }
    } catch (e) {
      debugPrint('Error during image compression: $e');
    }
    return null;
  }

  Future<void> pickImage(DriverDataImages imageType, bool isCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      final originalPath = pickedFile.path;
      final compressedFile = await compressImage(originalPath, quality: 70);
      final fileToSet = compressedFile ?? File(originalPath);
      setImageFile(imageType, fileToSet);
    }
  }

  List<DriverDataImages> getRequiredImagesForStep(DriverDataSteps step) {
    switch (step) {
      case DriverDataSteps.vehicleInfo:
        return [
          DriverDataImages.vehicleInfoFront,
          DriverDataImages.vehicleInfoBack,
        ];
      case DriverDataSteps.driverLicense:
        return [DriverDataImages.driverLicense];
      case DriverDataSteps.idCard:
        return [DriverDataImages.idCardFront, DriverDataImages.idCardBack];
      case DriverDataSteps.personalPhoto:
        return [DriverDataImages.personalPhoto];
    }
  }

  bool isNextButtonDisabled(DriverDataSteps currentStep) {
    final requiredImages = getRequiredImagesForStep(currentStep);
    bool isUploaded(DriverDataImages image) {
      switch (image) {
        case DriverDataImages.vehicleInfoFront:
          return vehicleInfoFrontImage != null;
        case DriverDataImages.vehicleInfoBack:
          return vehicleInfoBackImage != null;
        case DriverDataImages.driverLicense:
          return driverLicenseImage != null;
        case DriverDataImages.idCardFront:
          return idCardFrontImage != null;
        case DriverDataImages.idCardBack:
          return idCardBackImage != null;
        case DriverDataImages.personalPhoto:
          return personalPhotoImage != null;
      }
    }

    return !requiredImages.every(isUploaded);
  }

  Future<void> updateDeliveryProfile(BuildContext context) async {
    if (isLoggedOut) return;

    if (!context.mounted) return;

    AppWidget.createProgressDialog(context, msg: "...");
    emit(UploadDriverDataLoadingState());

    try {
      final response = await api.updateDeliveryProfile(
        frontNationalId: idCardFrontImage,
        backNationalId: idCardBackImage,
        drivingLicense: driverLicenseImage,
        frontVehicleLicense: vehicleInfoFrontImage,
        backVehicleLicense: vehicleInfoBackImage,
        image: personalPhotoImage,
      );

      if (isLoggedOut) return;

      if (!context.mounted) return;
      Navigator.pop(context);

      response.fold(
        (failure) {
          emit(UploadDriverDataErrorState());
        },
        (response) {
          if (response.status == 200 || response.status == 201) {
            emit(UploadDriverDataSuccessState());
            LocalNotificationService.showSuccessNotification(
              'تم رفع البيانات ✅',
            );

            if (!context.mounted) return;
            completeDialog(
              context,
              btnOkText: 'done'.tr(),
              title: 'review_and_approval'.tr(),
              onPressedOk: () {
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(
                  context,
                  Routes.mainRoute,
                  arguments: true,
                );
              },
            );
          } else {
            errorGetBar(response.msg ?? "Failed to upload data");
          }
        },
      );
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      log("Error in completeShipment: $e");
      emit(UploadDriverDataErrorState());
    }
  }

  @override
  Future<void> close() {
    stopPolling();
    _realtimeClient.dispose();
    return super.close();
  }
}

enum DriverDataImages {
  vehicleInfoFront,
  vehicleInfoBack,
  driverLicense,
  idCardFront,
  idCardBack,
  personalPhoto,
}

enum DriverDataSteps { vehicleInfo, driverLicense, idCard, personalPhoto }
